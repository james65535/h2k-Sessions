# CNA H2K Session Week 2

This session walks through the basics of container networking with Docker.  Last session we learned about namespacing and experimented with filesystem namespacing and mounts.  To confirm our knowledge, can a container run a different distribution of Linux than from the host OS?  Why is the answer possible?

## Fun with container networking

### Namespacing for Networking Quick Re-Cap

"Each network interface (physical or virtual) is present in exactly 1 namespace and can be moved between namespaces." - https://en.wikipedia.org/wiki/Linux_namespaces

1. Create a network namespace for a process, in this case bash

```
unshare -n /bin/bash
ip a
exit
```

### Prep for this session

2. Use an existing Linux host with Docker or download Photon OS as a VM for fusion or workstation: https://github.com/vmware/photon/wiki/Downloading-Photon-OS

3. Inside the Photon OS, install ping and start the Docker Daemon

```
tdnf install iputils # for ping
systemctl start docker # to start the docker daemon
```

### Iptables

4. Show current Iptables ruleset

```
iptables -L
docker run -dp 8443:80 nginx
iptables -L
docker ps # get container name
docker kill <container name>
```

### What is the networking for a container?

5. Use Docker info to display available network drivers

`docker info`

### Docker Bridge Network

Bridge (native linux capability - https://wiki.linuxfoundation.org/networking/bridge)

6. Example of container running in a Linux bridge

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

7. These network interfaces are virtual ethernet interfaces and are created in pairs.  These could even be created manually.

```
ip link add vethA type veth peer name vpeerA
ip a
ip link delete vethA
```

8. Can we pass traffic from containers on the same bridge beyond just the exposed port?

```
docker run -itp 9001:9001 centos /bin/bash
docker run -itp 9002:9002 centos /bin/bash # from host
ifconfig # from container 1
ifconfig # from container 2
ping <container2IP> # from container 1
exit # from container 1
exit # from container 2
```

9. Docker handles DNS a certain way for bridged container (https://docs.docker.com/v17.09/engine/userguide/networking/default_network/configure-dns/)

```
docker run -it vmware/photon2 /bin/bash
vi /etc/hosts # from container
```

Positives/Negatives
- Single host only

### Docker Overlay Network

Encapsulates network packets using VXLAN to create an overlay network which can span multiple docker hosts.

10. We can create docker networks using the overlay driver but first we need to enable swarm mode

```
docker swarm init # if not already enabled
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
- Uses NAT for communication outside of overlay network

### Docker MACVLAN Network

Creates sub interfaces on a network interface.  Allows containers to be assigned IP addresses directly. (https://docs.docker.com/network/macvlan/)

Supports two modes:
- Bridge
- 802.1q Trunk which can be an l3 or l2 bridge

11. Create a docker network using the MACVLAN Driver

```
ip a
docker network create -d macvlan --subnet=192.168.20.0/24 --gateway=192.168.20.1 --ip-range=192.168.20.0/25 -o parent=eth0 macvlan-net # These need to be addresses from the physical network
docker network ls
docker run -it --network=macvlan-net vmware/photon2 /bin/bash
ifconfig
```


Positives/Negatives
- Matches external IP to container
- There may be a short limit to pool of MAC addresses on the host
- Its possible to flood a VLAN with a large number of MAC addresses
