# CNA H2K Session Week 1

This session walks through the effects of namespacing.  The end result should give some context around containers and how they differ from Virtual Machines.

## Fun with container images

1. Create Container

`docker run -it vmware\photon2 /bin/bash`

2. Create test dir

```
cd /root
mkdir testfolder
echo "hi" > /root/test2/testfile
exit
```

3. List container name

`docker ps -a`

4. If I issue a docker run command do I see the file?

`docker run -it vmware\photon2 /bin/bash`

5. List all docker containers

`docker ps -a`

6. Lets check out the filesystem of this container

`docker commit <container> <repo>:<tag>`

7. Grab image name

`docker images ls`

8. Export this image

```
mkdir extract
docker save <imageid> > /root/extract/ci.tar
cd /root/extract
tar -xf ci.tar
```

9. Lets take a look at some metadeta

`cat <sha>.json`

10. Lets inspect these tarfiles

```
cd <sha>
tar -xf layer.tar
ls
```

11. Lets inspect the other tarfile

```
cd <sha>
tar -xf layer.tar
ls root
cat root/testfolder/testfile
```

12. How are these folders used? Linux filesystem mounts provide a namespace for folders and files

```
ls
mount
```

13. The following command allows a process to disassociate parts of its execution context that are currently being shared with other processes).  Create another term window:

```
unshare -m bash
mkdir /root/testspace
cd /root/testspace
mkdir /root/temp/mymount
mount --bind /root/extract/<sha>/root/testfolder/ /root/temp/mymount/
```

14. Can previous term window see the contents of mymount?

`ls /root/temp/mymount`

15. Fun with union filesystem - Check storage driver

`docker info`

16. Lets verify mounts, lower dir and current dir

```
docker run -it vmware/photon2 /bin/bash
mount | grep overlay
```

17. Do multiple containers of the same image share the same lowerdir?  In another term window:

```
docker run -it vmware/photon2 /bin/bash
mount | grep overlay
exit
```

18. where is all this stuff stored?  The following as the image layers:

`ls /var/lib/docker/overlay2`

- The diff folder in each layer folder contains the layers contents, merged is the union of diff and lower
- When a write occurs to an existing file for the first time a copy_up command is issued to move from lower to current
- When a file is deleted within a container, a whiteout file is created in the current layer.  The underlying images are read only so not affected

# Running containers

## How isolated are containers?

1. On term 1

`docker run redis`

2. On term 2

```
ps aux | grep redis
tdnf install psmisc
pstree -alhps <redis docker pid>
```

3. What happens when we issue a kill command on the containerised process?

`kill -9 <pid>`

## UTS Namespace

1. On term 1

```
docker run -it vmware/photon2 /bin/bash
hostname
```

2. On term 2

`hostname`

## IPC Namespace

1. On term 1

`ipcs`

2. On term 2

`ipcs`

## PID Namespace

1. On term 1

`ps -A`

2. On term 2

`ps -A`

## Network Namespace

1. On term 1

```
ifconfig
exit
unshare -n bash
ifconfig
exit
```

2. On term 2

`ifconfig`

# Putting it all together

## runC and containerc

# Relevant links
- https://en.wikipedia.org/wiki/Operating-system-level_virtualization
- https://en.wikipedia.org/wiki/Hypervisor
- https://en.wikipedia.org/wiki/Linux_namespaces
