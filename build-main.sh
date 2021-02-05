#!/bin/bash -x


if [ "x$OUTPUT_DIR" = "x" ]; then 
	DATE_TIME=`date +%Y-%m-%d-%H-%M-%S`
	OUTPUT_DIR="sdcard/UTC-$DATE_TIME"
fi

if [ "x$BMN" = "x" ]; then 
	BMN=buildmachine
fi
if [ "x$DHOME" = "x" ]; then 
	DHOME=dockerhome
fi
BMODE=${1:-KEEP}

export BMN
export DHOME
export OUTPUT_DIR


#test if docker is installed
test=$(sudo docker --version | grep version | tr -d "[:space:]" | wc -w)
if [ "x$test" = "x0" ]; then 
	echo "No docker installed on this host. Please install docker first. ( https://docs.docker.com/engine/install/ubuntu/ )"
	exit 1
fi


if [ "$BMODE" == "CLEAN" ]; then 
echo "running docker cleanup"
sudo docker stop $BMN || command_failed=1
sudo docker rm -f $BMN || command_failed=1
sudo rm -r $DHOME || command_failed=1
else
echo "continue build"
fi


mkdir -p $DHOME 
mkdir -p sdcard 

echo "creating docker build machine"
sudo docker run -v /dev:/dev --privileged --hostname="Docker$(hostname)" -t -d --mount src="$(pwd)/$DHOME",target=/home,type=bind --name $BMN ubuntu:xenial 

echo "setting up packages... (this may take a while)"
cat <<EOF |sudo docker exec --interactive $BMN bash -e
sysctl fs.inotify.max_user_watches=1048576
rm /bin/sh
ln /bin/bash /bin/sh
apt-get update > /dev/null
apt-get -q install --yes texinfo gawk chrpath python3 python python3-pip git locales curl awscli unzip rpm make gcc g++ diffstat bzip2 wget cpio sudo libjansson4 libjansson-dev net-tools tcpdump cmake libssl-dev udisks2 bsdmainutils> /dev/null
apt-get install --yes --reinstall ca-certificates

echo "Creating builder user"
useradd -m -s /bin/sh builder
echo builder:password | chpasswd
usermod -aG sudo builder
adduser builder sudo
echo 'mesg y' > /etc/profile
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
echo "builder ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
EOF


sudo docker cp /mydrive/build/docker_build/build_pi.sh     $BMN:/home/builder/build_pi.sh
sudo docker cp /mydrive/build/docker_build/meta-mygo     $BMN:/home/builder/

echo "setting up git access"
sudo docker exec $BMN locale-gen --purge en_US.UTF-8 
cat <<EOF |sudo docker exec --interactive $BMN bash  -e
echo -e 'LC_ALL="en_US.UTF-8"\nLC_CTYPE="en_US.UTF-8"\nLANGUAGE="en_US.UTF-8"\nLANG=en_US.UTF-8\n' > /etc/default/locale
echo -e 'LC_ALL="en_US.UTF-8"\nLC_CTYPE="en_US.UTF-8"\nLANGUAGE="en_US.UTF-8"\nLANG=en_US.UTF-8\n' > /home/builder/.bashrc
source /home/builder/.bashrc
su - builder
exit $?
EOF

if [ $? -ne 0 ]; then  exit 1 ; fi



echo "getting repo"
cat <<EOF |sudo docker exec -w /home/builder --interactive $BMN bash -e

	su - builder

	mkdir -p /home/builder/WORK 
	cd /home/builder/WORK
	export LC_ALL=en_US.UTF-8
	export LANG=en_US.UTF-8
	export LANGUAGE=en_US.UTF-8 
        cp -f ../build_pi.sh ./build_pi.sh
        ./build_pi.sh

EOF



if [ $? -ne 0 ]; then 
  exit 1
fi

if [ -e $(pwd)/$DHOME/builder/WORK/builderror ]; then
  exit 1
fi


BMODE=${1:-KEEP}
if [ "$BMODE" == "CLEAN" ]; then 
echo "running docker cleanup"
sudo docker stop $BMN || command_failed=1
sudo docker rm -f $BMN || command_failed=1
sudo rm -r $DHOME || command_failed=1
else
echo "continue build"
fi

