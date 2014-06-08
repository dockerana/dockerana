dockerana
=========

pitch:

initial setup :

ubuntu 14.04:

official install from http://docs.docker.io/installation/ubuntulinux/#ubuntu-trusty-1404-lts-64-bit

```
$ sudo apt-get update
$ sudo apt-get install docker.io
$ sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
$ sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
```

make these changes :

