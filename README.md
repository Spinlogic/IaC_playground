# IaC playground

Create a network of Ubuntu linux servers using linux containers and practice IaC tools such as  [Ansible](https://www.ansible.com/) or [Terraform](https://www.terraform.io/) on it. With some effort, it can also be used to play around with orchestrators such as [docker swarm](https://docs.docker.com/engine/swarm/) or [Kubernetes](https://kubernetes.io/).

This work is loosely based on [codespace](https://github.com/codespaces-io/codespaces.git) (not to be confused with [Github Codespaces](https://github.com/features/codespaces)), which builds a network of linux (CentOS 7) servers on docker containers to practice with different IaC tools ([Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/) or [Puppet](https://puppet.com/))


# First things first 

This repo works on all linux distros that supports Docker and Ansible. Docker installation is a pre-requisite. Follow the instructions [here](https://docs.docker.com/engine/install/) to install the latest version of docker in your machine.

The first thing that we need is a docker image of Ubuntu with enough configuration to be accesible from outside via ssh using encryption keys instead of user/pwd, which is the way in which real world works in practice. The provided Dockerfile takes care of this.

*I won't explain here how to create encryption key pairs for ssh. This is well covered in this [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04)), and in many other places.*

## Build and run an Ubuntu server on Docker

Build the docker image with:

```
docker build -t iacplayground --build-arg username=ubuntu --build-arg userpwd=mypassword --build-arg publickeypath=./publickey.pub .
```
Use any *username* and *password* that you want, and the *public key* that you generated for this project.  

*Note that the tag of the image is **iacplayground**. You can change that also, but remember to change it also in other commands below.* 

To test that everything works correctly: 

1. Run container:

```
docker run -i -d --name iacplg1 iacplayground
```

2. Connect to the container from a terminal in the host:

```
ssh -i /full_path_to_private_key your_username@container_ip_address
```
You can use *docker inspect iacplayground* to find out the *container_ip_address* in the default Docker network.

**Important points**

- Before building the Docker image using Dockerfile, you must create a pair of public / private encryption keys.
- The config file for SSH is copied into the image. Modify it as needed for your case. 
- The *username* and *password" that you defined is the sudo user that Ansible will use to execute tasks on the server. 
- Each line in the Dockerfile creates a layer in the Docker image. I have made some optimisations to reduce the number of layers, but feel free to make more. E.g. The WORKDIR, EXPOSE and ENTRYPOINT lines can be removed (i.e. a redunction of three images), since they can be defined in the *docker-compose* file.

# Deploy a cluster

The provided *docker-compose.yml* can be used to deploy a cluster of multiple ubuntu servers. Just type:

```
docker compose up -d
```

*Dockerised" ubuntu servers have their own IP addresses and are all reachable among them and from the host machine. Their IP addresses are defined in the *docker-compose.yml* and will be used also in the ansible inventory.

***NOTE:** Since, for [practical reasons](https://github.com/moby/moby/issues/11185), it is not possible to build an image that exposes all ports, you will need to expose the ports for each container in the docker-compose file. Just edit the docker-compose.yml as needded for your case to expose the needed port in each ubuntu server (service).*


# Infrastructure as Code (IaC)

A this point, we have cluster of multiple ubuntu servers that can be used to practice with IaC tools. We will try only with Ansible, but feel free to test other ones.

## Ansible examples

I included a collection of playbooks that can be used as starting point:

- Operations: playbooks that run operational tasks, such as pinging the servers or updating packages and ubuntu distribution.
- Test: small playbooks to test specific functionality before adding to larger playbooks.
- Provisioning: playbooks that provision services. These are the ones that you need to write to build your solution :-)<br>I provide an example that builds a docker swarm (yes, Docker in Docker!)

# Documentation references

- [Ansible](https://docs.ansible.com/ansible/latest/user_guide/index.html)
- [Docker CLI](https://docs.docker.com/reference/)
- [Dockerfile](https://docs.docker.com/engine/reference/builder/)
- [Docker compose file](https://docs.docker.com/compose/compose-file/)