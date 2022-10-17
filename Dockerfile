FROM ubuntu:latest

ARG username=ubuntu
ARG userpwd=password123
ARG publickeypath=./publickey.pub

RUN apt update; apt install openssh-server -y; useradd -p $(echo $userpwd | openssl passwd -1 -stdin) -m $username -s /bin/bash;  mkdir /var/run/sshd 
COPY $publickeypath /home/$username/.ssh/authorized_keys
COPY ./sshd_config  /etc/ssh/sshd_config
RUN apt upgrade -y; apt install sudo; echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; chmod -R go= /home/$username/.ssh; chown -R $username:$username /home/$username/.ssh; chmod a-x /home/$username/.ssh/authorized_keys; usermod -a -G sudo $username;

WORKDIR /home/$username

# Expose ssh port (the next line can be removed if the SSH port is exposed with the docker-compose file)
EXPOSE 22
# Expose all other ports needed for this project
# EXPOSE ...

# Entrypoint (the next line can be removed if the entrypoint is defined in the docker-compose file)
ENTRYPOINT service ssh restart && bash
