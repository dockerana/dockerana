[dockerana](http://dockerana.com/)
=========

* [Docker hackathon slides](http://dockerana.com/slides.html)
* [Docker dockercon14 slides](http://dockerana.com/demo.html)

Overview:

* time series docker instrumentation and visualization
* built/tested as drop-in on Ubuntu Trusty at the moment, need to test on boot2docker
* need to test across multiple hosts (whisper/elasticsearch/etc)

<img src="http://thecabin.net/sites/default/files/bigfoot.jpg">

#### Initial setup :

* Obligatory disclaimer about logs & disk space... upstart will rotate/etc; but growth of backend, will just keep going. Don't let your docker host run out of space!
* Everything in this setup assumes ipv4 only at this point (FIXME)

Instructions below are for Ubuntu 14.04, assuming a vanilla/patched
install with rsyslog running.

Official install from http://docs.docker.io/installation/ubuntulinux/#ubuntu-trusty-1404-lts-64-bit

```
sudo apt-get update
sudo apt-get install -y docker.io
sudo ln -sf /usr/bin/docker.io /usr/local/bin/docker
sudo sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
```

Update to a current docker:

```
cd /tmp
wget https://get.docker.io/builds/Linux/x86_64/docker-latest -O docker
sudo mv docker /usr/bin/docker.io
sudo chown root:root /usr/bin/docker.io
sudo chmod 755 /usr/bin/docker.io
```

Make these changes:

(FIXME deal with situation where pre-existing docker_opts exist/ordering/etc)

```
printf "\n# Added for dockerana log aggregation\nDOCKER_OPTS=\" -D\"\n" | sudo tee -a /etc/default/docker.io > /dev/null
sudo perl -pi -e 's/(\"\$DOCKER\" -d \$DOCKER_OPTS)/$1 2>&1 | logger -t docker\n\tnetstat --interfaces -c | logger -t netstat &/' /etc/init/docker.io.conf

```

Go ahead and re-start docker:

```
sudo service docker.io restart
```

To build dockerana:

```
git clone https://github.com/dockerana/dockerana.git
cd dockerana
./build
```

To start:

```
./start
```

To stop:

```
./stop
```

Screenshots:

<img src="https://github.com/dockerana/dockerana/raw/master/documentation/screenshots/1.png">
<img src="https://github.com/dockerana/dockerana/raw/master/documentation/screenshots/2.png">
<img src="https://github.com/dockerana/dockerana/raw/master/documentation/screenshots/3.png">
