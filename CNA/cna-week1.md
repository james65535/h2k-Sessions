# Fun with container images

## Create Container
docker run -it vmware\photon2 /bin/bash

## Create test dir
cd /root
mkdir testfolder
echo "hi" > /root/test2/testfile
exit

## List container name
docker ps -a

## If I issue a docker run command do I see the file?
docker run -it vmware\photon2 /bin/bash

## List all docker containers
docker ps -a

## Lets check out the filesystem of this container
docker commit <container> <repo>:<tag>

## Grab image name
docker images ls

## Export this image
mkdir extract
docker save <imageid> > /root/extract/ci.tar
cd /root/extract
tar -xf ci.tar

## Lets take a look at some metadeta
cat <sha>.json

## Lets inspect these tarfiles
cd <sha>
tar -xf layer.tar
ls

## Lets inspect the other tarfile
cd <sha>
tar -xf layer.tar
ls root
cat root/testfolder/testfile

## How are these folders used? Linux filesystem mounts provide a namespace for folders and files

## List mounts???
ls
mount

##  The following command allows a process to disassociate parts of its execution context that are currently being shared with other processes).  Create another term window:
unshare -m bash
mkdir /root/testspace
cd /root/testspace
mkdir /root/temp/mymount
mount --bind /root/extract/4cb6c59452ec6ebccb44d0c1776d8dd51b121255e482f058fd3c97ee530c91c2/root/testfolder/ /root/temp/mymount/

## Can previous term window see the contents of mymount?
ls /root/temp/mymount

## Fun with union filesystems

## Check storage driver
docker info

## Lets verify mounts, lower dir and current dir
docker run -it vmware/photon2 /bin/bash
mount | grep overlay

## Do multiple containers of the same image share the same lowerdir?  In another term window:
docker run -it vmware/photon2 /bin/bash
mount | grep overlay
exit

## where is all this stuff stored?  The following as the image layers:
ls /var/lib/docker/overlay2

## The diff folder in each layer folder contains the layers contents, merged is the union of diff and lower
## When a write occurs to an existing file for the first time a copy_up command is issued to move from lower to current
## When a file is deleted within a container, a whiteout file is created in the current layer.  The underlying images are read only so not affected

# Running containers

## How isolated are containers?

## On term 1
docker run redis

## On term 2
ps aux | grep redis
tdnf install psmisc
pstree -alhps <redis docker pid>

## What happens when we issue a kill command on the containerised process?
kill -9 <pid>


## UTS Namespace

### On term 1
docker run -it vmware/photon2 /bin/bash
hostname

### On term 2
hostname

## IPC Namespace

### On term 1
ipcs

### On term 2
ipcs

## PID Namespace

### On term 1
ps -A

### On term 2
ps -A

## Network Namespace

### On term 1
ifconfig
exit
unshare -n bash
ifconfig
exit


### On term 2
ifconfig


# Putting it all together

## runC and containerc

# Relevant links
- https://en.wikipedia.org/wiki/Operating-system-level_virtualization
- https://en.wikipedia.org/wiki/Hypervisor
- https://en.wikipedia.org/wiki/Linux_namespaces
