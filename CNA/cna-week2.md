# CNA H2K Session Week 2

This session walks through the basics of container networking with Docker.  Last session we learned about namespacing and experimented with filesystem namespacing and mounts.  To confirm our knowledge, can a container run a different distribution of Linux than from the host OS?  Why is the answer possible?

## Fun with container networking

### Namespacing for Networking Quick Re-Cap

1. Create a network namespace for a process, in this case bash

```
unshare -n /bin/bash
ip a
exit
```

### Prep for this session

2. Use an existing Linux host with Docker or download Photon OS as a VM for fusion or workstation: https://github.com/vmware/photon/wiki/Downloading-Photon-OS

3. Inside the Photon OS, install ping

`tdnf install iputils (for ping)`

### Iptables

4. Show current Iptables ruleset

```
iptables -L
docker run -dp 8443:80 nginx
iptables -L
docker kill
```

### What is the networking for a container?

`docker info`

### Docker Bridge Network

Bridge (native linux capability - https://wiki.linuxfoundation.org/networking/bridge)

5. Example of container running in a Linux bridge

```
docker run -itp 9000:9000 vmware/photon2 /bin/bash
ifconfig # from container
ip a # from host
brctl show
brctl show docker0
brctl showmacs docker0
docker network ls
docker network inspect bridge
exit # from container
```

6. Can we pass traffic from containers on the same bridge beyond just the exposed port?

```
docker run -itp 9001:9001 centos /bin/bash
docker run -itp 9002:9002 centos /bin/bash # from host
ifconfig # from container 1
ifconfig # from container 2)
ping container2IP # from container 1
exit # from container 1
exit # from container 2
```

7. Docker handles DNS a certain way for bridged container (https://docs.docker.com/v17.09/engine/userguide/networking/default_network/configure-dns/)

```
docker run -it vmware/photon2 /bin/bash
vi /etc/hosts # from container
```

Positives/Negatives
- Single host only

### Docker Overlay Network

8. We can create docker networks using the overlay driver but first we need to enable swarm mode

```
docker swarm init
docker network create --attachable -d overlay overlay-net
docker network ls
docker run --network=overlay-net  --name=test1 nginx
docker run --network=overlay-net  --name=test2 nginx
docker network inspect overlay-net
docker kill test1
docker kill test2
```

Positives/Negatives
- Multi host
- Uses NAT outside of overlay network

### Docker MacVLAN Network


Positives/Negatives
- Matches external IP to container
