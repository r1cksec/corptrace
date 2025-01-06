FROM debian:latest

ENV USER=corptrace
# Install git
RUN apt-get update && \
    apt-get install -y git build-essential autoconf python3 dnsutils bind9-dnsutils

RUN mkdir -p /home/corptrace && \
    cd /home/corptrace && \
     git clone https://github.com/r1cksec/corptrace.git .
    
WORKDIR /home/corptrace

#COPY . .

RUN sed -i 's/sudo //g' install.sh

#RUN bash install.sh -force

# sudo docker build -t corptrace -f corptrace.dockerfile .
#  docker run -it corptrace

