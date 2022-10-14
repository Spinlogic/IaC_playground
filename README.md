# IaC playground

This repo allows you to define a network of Ubuntu linux servers using linux containers and use it to practice IaC tools such as  [Ansible](https://www.ansible.com/) or [Terraform](https://www.terraform.io/). But the can also be used to play around with the likes of orchestrators like [docker swarm](https://docs.docker.com/engine/swarm/) or [Kubernetes](https://kubernetes.io/).

It is loosely based on the [codespace](https://github.com/codespaces-io/codespaces.git) project (not to confuse with [Github Codespaces](https://github.com/features/codespaces)), which builds a network of linux (CentOS 7) servers using docker containers to practice with different IaC tools ([Ansible](https://www.ansible.com/), [Chef](https://www.chef.io/) or [Puppet](https://puppet.com/))


# First things first 

The first thing needed is docker image of Ubuntu with enough configuration to be accesible from outside via ssh using encryption keys instead of user/pwd, which is the way in which real world works in practice. The provided Dockerfile is used for this.

*I won't explain here how to create encryption keys for ssh. This is well covered in this [Digital Ocean tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys-on-ubuntu-22-04)), and in many other places.*

## Build and run an Ubuntu server on Docker

The build the docker image, enter:

```
sudo docker build -t iacplayground --build-arg username=ubuntu --build-arg userpwd=mypassword .
```
feel free to use any *username* and *password* that you want. In this example, I used *ubuntu* for username and *mypassword* for password. These are the user credentials that you will need later to login to the Ubuntu servers created from this image.

*Note that the name of the image is **iacplayground**. You can change that also, but your will need to remember to change it also in later commands.* 

Run container:

```
sudo docker run -i -d --name iacplg1 iacplayground
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

To connect to the server, you will need the private key created before. I used the following command in my ubuntu desktop:

```
ssh -i /mnt/hgfs/shared/ubuntutest.pem ubuntu@172.17.0.2
```

where:
- /mnt/hgfs/shared/ubuntutest.pem is the path to my private key, and
- 172.17.0.2 is the IP address of the Docker container instantiated above. You can use *docker inspect iacplayground* to find out the IP address of your server in the network created by Docker.


**MORE TO COME SOON ...**
