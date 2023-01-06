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
Furthermore it is possible to skip an exceptional string.
This exceptional string: 'outputFile'
will not be added to the list of strings.

syntax = The syntax of the command of the given module.
removeExpArgs = If this value is set to 1, it will be checked
whether string belongs to the exceptional strings.
"""
def getVariablesFromString(syntax, removeExpArgs):
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

    if (removeExpArgs == 1):
        # define exceptional arguments
        exceptionalArgument = "outputFile"

        # remove exceptional variables from json arguments
        if (exceptionalArgument in requiredVars):
            requiredVars.remove(exceptionalArgument)

    return requiredVars


"""Return a list of strings that will be added to argumentParser.
These strings are defined in the modules.json file within the syntax key.
For each module, the values set in <variable> are defined as arguments.
The variable outputFile will not be added to the argumentParser.
"""
def getArgsOfJson():
    availableModules = loadModules(pathToScriptDir + "/modules.json")

    # define arguments given by json config
    allJsonArgs = []
    
    for currModule in availableModules:
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
    allModules = loadModules(pathToScriptDir + "/modules.json")
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

        # get all undefined arguments of current module
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

        # add additional arguments given by to the output path
        modOutput = pathToModDir + "/" + thisModule["name"]

        for currArg in argumentsOfModule:
            # skip <outputFile>
            if (currArg == "outputFile"):
                continue

            # special case for path variables
            if ("file" in currArg.lower()):
                basenameOfFile = os.path.basename(vars(args)[currArg])
                exeString = exeString.replace("<" + currArg + ">", 
                                              vars(args)[currArg])
                modOutput = modOutput + "_" + basenameOfFile.replace(":","-")

            else:
                # replace remaining arguments
                exeString = exeString.replace("<" + currArg + ">", 
                                              vars(args)[currArg])
                bufModOut = vars(args)[currArg].replace("/","")
                modOutput = modOutput + "_" + bufModOut.replace(":","-")

        # insert outputFile
        modOutput = modOutput.replace(" ","-")
        exeString = exeString.replace("<outputFile>", modOutput)

        # check if tool has already been executed
        if (os.path.exists(modOutput)):
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
                # skip error code 1
                # since trufflehog and gitleaks return code 1 on success
                if (exc.returncode == 1):
                    print(f"{bcolor.green}###[DONE]###\t{bcolor.ends} "
                          + self.moduleName)
                    return(0)

                else:
                    print(f"{bcolor.red}###[ERROR]###\t{bcolor.ends} " 
                      + self.command)
                    return(1)


"""MAIN

"""
# define and configure static arguments
argumentParser = argparse.ArgumentParser(description="""Automatic reconaissance.
Use at your own risk.
I do not take any responsibility for your actions!

Basic usage:
Print matching modules for a given domain:
./thot.py -o /tmp/output -d example.com

Execute modules for given domain:
./thot.py -o /tmp/output -d example.com -e

Only execute modules that contains at least one of the given substring in their name:
./thot.py -o /tmp/output -d example.com -im amass -ir 192.168.1.3-9 -e

Execute modules up to risk level 4, use 8 threads and increase timeout to 35 minutes:
./thot.py -o /tmp/output -d example.com -rl 4 -ta 8 -t 2100 -an AS8560

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

argumentParser.add_argument("-t",
                            "--timeout",
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

## will contain the running threads
threads = []

# count finished modules
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

