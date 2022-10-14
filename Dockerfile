FROM ubuntu:latest

ARG username=ubuntu
ARG userpwd=ubuntu
ARG publickeypath=./publickey.pub

RUN apt update; apt updgrade -y; apt install sudo; apt install openssh-server -y; useradd -p $(echo $userpwd | openssl passwd -1 -stdin) -m $username -s /bin/bash; usermod -a -G sudo ubuntu; mkdir /var/run/sshd
COPY $publickeypath /home/$username/.ssh/authorized_keys
COPY ./sshd_config  /etc/ssh/sshd_config
RUN chmod -R go= /home/$username/.ssh; chmod a-x /home/$username/.ssh/authorized_keys; chown -R $username:$username /home/$username/.ssh; echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/ubuntu

EXPOSE 22

ENTRYPOINT service ssh restart && bash
