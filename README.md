# IaC playground

This repo allows you to define a network of Ubuntu linux servers using linux containers and practice IaC tools such as  [Ansible](https://www.ansible.com/) or [Terraform](https://www.terraform.io/) with it. With some effort, it can also be used to play around with orchestrators such as [docker swarm](https://docs.docker.com/engine/swarm/) or [Kubernetes](https://kubernetes.io/).

It is loosely based on the [codespace](https://github.com/codespaces-io/codespaces.git) project (not to be confused with [Github Codespaces](https://github.com/features/codespaces)), which builds a network of linux (CentOS 7) servers on docker containers to practice with different IaC tools ([Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/) or [Puppet](https://puppet.com/))


# First things first 

This repo is bullt and tested in an ubuntu desktop system, but should work on any linux distro that supports docker. Docker installation is a pre-requisite. Follow the instructions [here](https://docs.docker.com/engine/install/) to install the latest version of docker in your machine.

The first thing that we need is a docker image of Ubuntu with enough configuration to be accesible from outside via ssh using encryption keys instead of user/pwd, which is the way in which real world works in practice. The provided Dockerfile takes care of this.

*I won't explain here how to create encryption keys for ssh. This is well covered in this [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04)), and in many other places.*

## Build and run an Ubuntu server on Docker

To build the docker image, enter:

```
docker build -t iacplayground --build-arg username=ubuntu --build-arg userpwd=mypassword .
```
Use any *username* and *password* that you want. In this example, I used *ubuntu* for username and *mypassword* for password. These are the user credentials that you will need later to login to the Ubuntu servers created from this image.

*Note that the name of the image is **iacplayground**. You can change that also, but remember to change it also in other commands below.* 

Run container:

```
docker run -i -d --name iacplg1 iacplayground
```
And, voilà!, you have a minimal ubuntu server running in a docker container.

**Important points**

- Before building the Docker image using Dockerfile, you must create a pair of public / private encryption keys.
- In the Dockerfile, the public encryption key (named publickey.pub) is copied to */home/$username/authorized_keys*. The private key will be needed later to connect to ubuntu servers created from this Dockerfile. The path of the public key can be passed as argument *publickeypath* when building the docker image.
- The config file for SSH is copied into the image. This file is provided in the repo for information. You can use it or customise your own. 
The one provided disable login using credentials (username and password) and only allows connections using encryption keys. It also imposes some other limitations.
- In this docker build, user *ubuntu* with password *mypassword* is the sudo user that Ansible will use to execute tasks on the server. 
- Since each line in the Dockerfile creates a layer in the Docker image, I have packed as many commands as possible in each line. This is just an optimisation that, hopefully, will not make it too difficult to follow how the ubuntu image is built.


## Connect via SSH to the ubuntu server

To connect to the server, you need the private key created before. I used the following command in my ubuntu desktop (host of the dockerised ubuntu):

```
ssh -i /mnt/hgfs/shared/ubuntutest.pem ubuntu@172.17.0.2
```

where:
- /mnt/hgfs/shared/ubuntutest.pem is the path to my private key, and
- 172.17.0.2 is the IP address of the Docker container instantiated above. You can use *docker inspect iacplayground* to find out the IP address of your server in the default network that Docker uses.

# Deploy a cluster

The provided *docker-compose.yml* can be used to deploy a cluster of multiple ubuntu servers. Just type:

```
docker compose up -d
```

each *dockerised" ubuntu server has its own IP address and is reachable from the host machine. All this info is inside the *docker-compose.yml* and will be used as input to the ansible inventory.

***NOTE:** Since, for [practical reasons](https://github.com/moby/moby/issues/11185), it is not possible to build an image that exposes all ports, you will need to expose the ports for each container in the docker-compose file. Just edit the docker-compose.yml as needded for your case to expose the needed port in each ubuntu server (service).*


# Infrastructure as Code (IaC)

A this point, we have cluster of multiple ubuntu servers that can be used to practice with IoC tools. We will try only with Ansible, but feel free to test other IaC tools.
