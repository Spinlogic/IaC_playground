# IaC playground

Create a network of Ubuntu linux servers using linux containers and practice IaC tools such as  [Ansible](https://www.ansible.com/) or [Terraform](https://www.terraform.io/) on it. With some effort, it can also be used to play around with orchestrators such as [docker swarm](https://docs.docker.com/engine/swarm/) or [Kubernetes](https://kubernetes.io/).

This work is loosely based on [codespaces](https://github.com/codespaces-io/codespaces.git) (not to be confused with [Github Codespaces](https://github.com/features/codespaces)), which builds a network of linux (CentOS 7) servers on docker containers to practice with different IaC tools ([Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/) or [Puppet](https://puppet.com/))


# First things first 

This repo works on all OSs that support Docker. Docker installation is a pre-requisite. Follow the instructions [here](https://docs.docker.com/engine/install/) to install the latest version of docker in your machine. 

All the docker containers created run on the host machine. The host machine shall have the IaC tool installed. In my case, the host is ubuntu linux and the IaC tool is Ansible. I have not tried with others. 

The first thing that we need is a docker image of Ubuntu with enough configuration to be accesible from outside via ssh using encryption keys instead of user/pwd, which is the way in which real world works in practice. The provided Dockerfile takes care of this.

*I won't explain here how to create encryption key pairs for ssh. This is well covered in this [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04)), and in many other places.*



## Build and run an Ubuntu server on Docker

Build the docker image with:

```
docker build -t iacplayground .
```
if the default credentials and the key pair provided are good enough for you. If not, you can build the image with your preferred credentials and key pair with the following command:

```
docker build -t iacplayground --build-arg username=myusername --build-arg userpwd=mypassword --build-arg publickeypath=./publickey.pub .
```
*Note that the tag of the image is **iacplayground**. You can change that also, but remember to change it also in other commands below.* 

To test that everything works correctly: 

1. Run container:

```
docker run -i -d --name iacplg1 iacplayground
```

2. Connect to the container from a terminal in the host:

***Note:** You will have to uncomment the "WORKDIR /home/$username", "EXPOSE 22" and "ENTRYPOINT service ssh restart && bash" lines in Dockerfile for this to work.*

```
ssh -i /full_path_to_private_key your_username@container_ip_address
```
You can use *docker inspect iacplayground* to find out the *container_ip_address* in the default Docker network.

**Important points**

- If you do not want to use the test key pair provided, then you must create a pair of public / private encryption keys before building the Docker image.
- The config file for SSH is copied into the image. Modify it as needed for your case. 
- Ansible will use the credentials that you defined for sudo access to execute tasks on the server (inside each container). 
- Each line in the Dockerfile creates a layer in the Docker image. I have made some optimisations to reduce the number of layers, like commenting WORKDIR, EXPOSE and ENTRYPOINT lines (i.e. a redunction of three images), since they are defined in the *docker-compose* file. Feel free to make additional optimisations.

# Deploy a cluster

The provided *docker-compose.yml* can be used to deploy a cluster of multiple ubuntu servers. Just type:

```
docker compose up -d
```

*Dockerised" ubuntu servers have their own IP addresses and are all reachable among them and from the host machine. Their IP addresses are defined in the *docker-compose.yml* and will be used also in the ansible inventory.

***NOTE:** for the reason explained [here](https://github.com/moby/moby/issues/11185), it is not practical to build an image that exposes all ports. You will need to expose the ports for each service in the docker-compose file that shall be reachable to other services (running in other containers). You will also need to map service ports to ports on the host machine for services that reachable from the external world (other machines in your network or even the Internet).*

# Infrastructure as Code (IaC)

A this point, we have cluster of multiple ubuntu servers that can be used to practice with IaC tools. We will try only with Ansible, but feel free to test other ones.

## Ansible examples

This repo includes a collection of playbooks that can be used as starting point:

- Operations: playbooks that run operational tasks, such as pinging the servers or updating packages and ubuntu distribution.
- Test: small playbooks to test specific functionality before adding to larger playbooks.
- Provisioning: playbooks that provision services. These are the ones that you need to write to build your solution :-)<br>I provide an example that builds a docker swarm (yes, Docker in Docker!)

This playbooks are commented where needed, so you can understand what they do.

# Documentation references

- [Ansible](https://docs.ansible.com/ansible/latest/user_guide/index.html)
- [Docker CLI](https://docs.docker.com/reference/)
- [Dockerfile](https://docs.docker.com/engine/reference/builder/)
- [Docker compose file](https://docs.docker.com/compose/compose-file/)