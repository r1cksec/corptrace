FROM debian:latest

ENV USER=thoth
# Install git
RUN apt-get update && \
    apt-get install -y git build-essential autoconf python3

RUN mkdir -p /home/thoth && \
    cd /home/thoth && \
    git clone https://github.com/T-s3c/thoth.git .
    
WORKDIR /home/thoth

# sudo docker build -t thoth -f thoth.dockerfile .
#  docker run -it thoth

