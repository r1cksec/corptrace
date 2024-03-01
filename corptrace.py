from argparse import RawTextHelpFormatter
import argparse
import json
import os
import signal
import subprocess
import threading
import time


"""Load JSON content of module configuration file.

pathToModuleConfig = The path to the configuration file.
"""
def loadModules(pathToModuleConfig):
    with open(pathToModuleConfig, "r", encoding="utf-8") as file:
        return json.load(file)


"""Return a list of strings.
Each string in this list represents a <variable> of the syntax string.
These syntax strings are read from the modules.json file.

syntax = The syntax of the command of the given module.
removeOutFile = If this value is set to 1, the list will not contain:
<outputFile>
"""
def getVariablesFromString(syntax, removeOutFile):
    possRequiredVars = []
    splittedSyntax = syntax.split("<")

    for currSpl in splittedSyntax:
        if (">" in currSpl):
            variableOfTempl = currSpl.split(">")
            possRequiredVars.append(variableOfTempl[0])

    # get all undefined variables inside json config of modules
    requiredVars = []

    # add if json key for module does not exist
    for var in possRequiredVars:
        try:
            # check if json key exists
            if (currModule[var]):
                continue
        except:
            requiredVars.append(var)

    if (removeOutFile == 1):
        if ("outputFile" in requiredVars):
            requiredVars.remove("outputFile")

        if ("outputDirectory" in requiredVars):
            requiredVars.remove("outputDirectory")

    return requiredVars


"""Return a list of strings that will be added to argumentParser.
These strings are defined in the modules.json file within the syntax key.
For each module, the values set in <variable> are defined as arguments.
The variable outputFile will not be added to the argumentParser.
"""
def getArgsOfJson():
    availableModules = loadModules(pathToScriptDir + "/build/modules.json")

    # define arguments given by json config
    allJsonArgs = []
    
    for currModule in availableModules:
        # get all undefined arguments of module (do not include <outputFile> and <outputDirectory>)
        allRequiredVars = getVariablesFromString(currModule["syntax"], 1)
    
        for currArg in allRequiredVars:
            allJsonArgs.append(currArg)
    
    # remove duplicated undefined variables
    uniqJsonArgs = sorted(set(allJsonArgs))
 
    return uniqJsonArgs


"""Catch user interrupt (ctrl + c).

sig = The type of signal, that should be catched.
frame = The function that should be executed.
"""
def signal_handler(sig, frame):
    print ("\nCatched keyboard interrupt, exit programm!")

    try:
        print ("Remove empty directories and files before leaving...")
        if (args.execute):
            # remove empty directories
            for directory in os.scandir(args.output):
                if os.path.isdir(directory) and not os.listdir(directory):
                    os.rmdir(directory)

        print("Done")
        exit(0)

    except:
        exit(0)


"""Return a json object
that contains modules which matches the arguments given by the user.
"""
def getMatchingModules():
    # read all modules from json file
    allModules = loadModules(pathToScriptDir + "/build/modules.json")
    matchingModules = []

    for module in allModules:
        # flag used to skip the current module
        skipModule = "0"

        # skip excluded modules given by user
        if (args.excludeModules != "NULL"):
            for currExcludedMod in args.excludeModules:
                if (currExcludedMod in module["name"]):
                    skipModule = "1"
                    break

            if (skipModule == "1"):
                continue

        # only execute included modules given by user
        skipModule = "1"

        if (args.includeModules != "NULL"):
            for currIncludedMod in args.includeModules:
                if (currIncludedMod in module["name"]):
                    skipModule = "0"
                    break

            if (skipModule == "1"):
                continue

        # get all undefined arguments of current module (do not include <outputFile> and <outputDirectory>)
        requiredArgsOfModule = getVariablesFromString(module["syntax"], 1)
        skipModule = "0"

        # skip modules that need an argument, that has not been given by user
        for currUndefArg in requiredArgsOfModule:
            if (vars(args)[currUndefArg] == "NULL"):
                skipModule = "1"
                break

        # execute only modules with lower equals risk level given by user
        if (int(module["riskLevel"]) > int(args.riskLevel)):
            skipModule = "1"

        if (skipModule == "1"):
            continue
        else:
            matchingModules.append(module.copy())

    return matchingModules


"""Return a list of lists.
These lists contain all final commands that will be executed.
Commands that have already been executed will not be executed again.
This function will fill the syntax key of the modules.json file accordingly.

allExecutableModules = All modules that will be executed.
"""
def createCommandFromTemplate(allExecutableModules):
    allCommands = []

    for thisModule in allExecutableModules:
        pathToModDir = args.output + "/" + thisModule["name"]

        # create directories for modules
        if (args.execute):
            if (not os.path.isdir(pathToModDir)):
                os.makedirs(pathToModDir)

        argumentsOfModule = getVariablesFromString(thisModule["syntax"], 0)

        # the command that will be appended to list of commands
        exeString = thisModule["syntax"]
        
        # used to create the name of the output
        moduleOutName = thisModule["name"]

        # replace each argument of current module
        for currArg in argumentsOfModule:
            # skip <outputFile> and <outputDirectory>
            if (currArg != "outputFile" and currArg != "outputDirectory"):
                # replace argument in syntax
                exeString = exeString.replace("<" + currArg + ">", 
                                              vars(args)[currArg])
                moduleOutName = moduleOutName + "-" + vars(args)[currArg]

        # remove unwanted chars from output
        moduleOutName = moduleOutName.replace(" ","-")
        moduleOutName = moduleOutName.replace("|","-")
        moduleOutName = moduleOutName.replace("<","-")
        moduleOutName = moduleOutName.replace(">","-")
        moduleOutName = moduleOutName.replace(":","-")
        moduleOutName = moduleOutName.replace("&","-")
        moduleOutName = moduleOutName.replace("/","-")
        moduleOutName = moduleOutName.replace(".","-")

        # full path to module output
        moduleOutPath = pathToModDir + "/" + moduleOutName 
        moduleOutFile = pathToModDir + "/" + moduleOutName 

        # create additional directory if module uses <outputDirectory>
        if ("<outputDirectory>" in exeString):
            if (args.execute):
                if (not os.path.isdir(moduleOutPath)):
                    os.makedirs(moduleOutPath)
 
            # replace <outputDirectory> in syntax
            exeString = exeString.replace("<outputDirectory>", moduleOutPath)
            moduleOutFile = moduleOutPath + ".txt" 
        
        # replace <outputFile> in syntax
        exeString = exeString.replace("<outputFile>", moduleOutFile)
        
        # check if tool has already been executed
        if (os.path.exists(moduleOutFile)):
            print(f"{bcolor.yellow}###[DUPLICATE]###\t{bcolor.ends} "
                  + thisModule["name"])
        else:
            allCommands.append([exeString, thisModule["name"]])

    return allCommands


"""Return exit status for executed command.
Create thread and execute given tool.

threading.Thread = The command that will be executed inside a shell.
moduleName = The name of the module 
that will be printed after successfull execution.
"""
class threadForModule(threading.Thread):
    def __init__(self, command, moduleName):
        threading.Thread.__init__(self)
        self.command = command
        self.moduleName = moduleName

    def run(self):
        # check if modules should only be printed
        if (args.execute):
            try:
                # run command in new shell and wait for termination
                subprocess.check_output(self.command, shell=True, 
                                        timeout=float(args.timeout))
                print(f"{bcolor.green}###[DONE]###\t{bcolor.ends} "
                      + self.moduleName)
                return(0)

            except subprocess.CalledProcessError as exc:
                # print error message
                print(f"{bcolor.red}###[ERROR]###\t{bcolor.ends} " + self.command)
                return(1)


"""MAIN

"""
# define and configure static arguments
argumentParser = argparse.ArgumentParser(description="""Automatic OSINT/Recon.
Use at your own risk.
I do not take any responsibility for your actions!

Basic usage:
Print matching modules for a given domain:
python3 corptrace.py -o /tmp/out -d r1cksec.de

Execute modules for given github user:
python3 corptrace.py -o /tmp/out -u r1cksec -e

Print syntax of modules for given file containing domains:
python3 corptrace.py -o /tmp/out -f /tmp/domains -v

Only execute modules that contain at least one of the given substring in their name:
python3 corptrace.py -o /tmp/out -c 'companyName' -im shodan -e

Execute modules up to risk level 3, use 8 threads and increase timeout to 35 minutes:
python3 corptrace.py -o /tmp/out -rl 3 -ta 8 -to 2100 -i '192.168.1.1/24' -e

""", formatter_class=RawTextHelpFormatter)

argumentParser.add_argument("-o",
                            "--output",
                            dest = "output",
                            help = "path to output directory",
                            required = "true")


argumentParser.add_argument("-e",
                            "--execute", 
                            dest = "execute",
                            help = "execute matching commands",
                            action = "store_true")

argumentParser.add_argument("-v",
                            "--verbose",
                            dest = "verbose",
                            help = "print full command",
                            action = "store_true")

argumentParser.add_argument("-to",
                            "--timeOut",
                            dest="timeout",
                            help = "maximal time that a single thread"
                                 + " is allowed to run"
                                 + " in seconds (default 1200)",
                            default = "1200")

argumentParser.add_argument("-rl",
                            "--riskLevel",
                            dest = "riskLevel",
                            help = "set maximal riskLevel for modules"
                                   + " (possible values 1-4, 2 is default)",
                            default = "2")

argumentParser.add_argument("-ta",
                            "--threadAmount",
                            dest = "threadAmount",
                            help = "the amount of parallel running threads"
                                   + " (default 5)",
                            default = "5")

argumentParser.add_argument("-em",
                            "--exludeModules",
                            dest = "excludeModules",
                            nargs = "*",
                            help = "modules that will be excluded "
                                   + "(exclude ovewrites include)",
                            default = "NULL")

argumentParser.add_argument("-im",
                            "--includeModules",
                            dest = "includeModules",
                            nargs = "*",
                            help = "modules that will be included",
                            default = "NULL")

# get path to directory that contains the json config
pathToScript = os.path.realpath(__file__)
pathToScriptDir  = os.path.dirname(pathToScript)
argsFromJsonConf = getArgsOfJson()

# add arguments of json file to argumentParser
allCapitalLetters = []
for currJsonArg in argsFromJsonConf:
    capitalLetters = currJsonArg[0]

    for char in currJsonArg:
        if (char.isupper()):
            capitalLetters = capitalLetters + char     
    try:
        argumentParser.add_argument("-" + capitalLetters.lower(),
                                    "--" + currJsonArg,
                                    dest=currJsonArg,
                                    default="NULL")
        allCapitalLetters.append("-" + capitalLetters + " " + currJsonArg)

    except:
        print("Error in modules.json - "
              + "collision for config argument name (args): " + currJsonArg)
        print("Argparse conflicting option string: --"
              + currJsonArg + "/-" + capitalLetters)
        exit(1)

args = argumentParser.parse_args()

# if set to 0 passed arguments of user are wrong
argumentFlag = "0"

for currArg in argsFromJsonConf:
    if (vars(args)[currArg] != "NULL"):
        argumentFlag = "1"
        break

if (argumentFlag == "0"):
    print("Error, at least one of the following arguments is required:")
    print(allCapitalLetters)
    exit(1)

# catch ctrl + c
signal.signal(signal.SIGINT, signal_handler)

# define colors for printing to stdout
class bcolor:
    purple = '\033[95m'
    blue = '\033[94m'
    green = '\033[92m'
    yellow = "\033[1;33m"
    red = '\033[91m'
    ends= '\033[0m'

# get a list with modules that matches the arguments given by user
executableModules = getMatchingModules()

# create commands from template
commandsToExecute = createCommandFromTemplate(executableModules)

# this variable will contain the running threads
threads = []

# used to print amount of modules count finished modules
amountOfExecModules = len(commandsToExecute)
counter = 1

for runCommand in commandsToExecute:
    # execute modules inside parallel threads
    if (args.execute):
        if (args.verbose):
            print(f"{bcolor.blue}###[START]###\t{bcolor.ends} "
                  + runCommand[0] + " - " + str(counter)
                  + "/" + str(amountOfExecModules))
        else:
            print(f"{bcolor.blue}###[START]###\t{bcolor.ends} "
                 + runCommand[1] + " - " + str(counter)
                  + "/" + str(amountOfExecModules))

        counter += 1

        while 1:
            # run 5 threads in parallel
            if (threading.active_count() <= int(args.threadAmount)):
                currThread = threadForModule(runCommand[0], runCommand[1])
                threads.append(currThread)
                currThread.start()
                break

            else:
                time.sleep(3)

    else:
        if (args.verbose):
            print(runCommand[0])
        else:
            print(runCommand[1])

# wait for all modules to finish
for x in threads:
    x.join()

if (args.execute):
    # remove empty directories
    for directory in os.scandir(args.output):
        if os.path.isdir(directory) and not os.listdir(directory):
            os.rmdir(directory)

# print overview
os.system("bash " + pathToScriptDir + "/ressources/scripts/print-overview.sh " + args.output)

