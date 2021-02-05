#!/bin/bash
pkill -f bitbake


if [ -d sources ] ; then
cp -rf ../meta-mygo ./sources/
source poky/oe-init-build-env rpi-estei-build
bitbake rpi-basic-image

else
wget https://dl.google.com/go/go1.15.2.linux-amd64.tar.gz 
tar -xvf go1.15.2.linux-amd64.tar.gz
mv go /usr/local 
export GOROOT=/usr/local/go 
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
git clone -b pyro git://git.yoctoproject.org/poky.git
mkdir sources
cd sources
git clone -b pyro git://git.openembedded.org/meta-openembedded
git clone -b pyro https://github.com/agherzan/meta-raspberrypi.git
cd ..
source poky/oe-init-build-env rpi-estei-build
bitbake-layers add-layer ../sources/meta-raspberrypi  
bitbake-layers add-layer ../sources/meta-openembedded/meta-oe/
bitbake-layers add-layer ../sources/meta-openembedded/meta-python/
bitbake-layers add-layer ../sources/meta-openembedded/meta-networking
bitbake-layers add-layer ../sources/meta-mygo
echo 'MACHINE ?= "raspberrypi3"' >>/home/builder/WORK/rpi-estei-build/conf/local.conf
echo 'ENABLE_UART = "1"' >>/home/builder/WORK/rpi-estei-build/conf/local.conf
echo 'INHERIT += "extrausers"' >>/home/builder/WORK/rpi-estei-build/conf/local.conf
echo 'EXTRA_USERS_PARAMS = "usermod -P pjiang root;useradd -P user user;"' >>/home/builder/WORK/rpi-estei-build/conf/local.conf
echo 'DISTRO:="pjiang"'>> /home/builder/WORK/rpi-estei-build/conf/local.conf
bitbake rpi-basic-image
fi



