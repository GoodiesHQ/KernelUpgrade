#!/bin/bash

# Reset
Reg='\e[0m'		# Text Reset
Black='\e[0;30m'	# Black
Red='\e[0;31m'		# Red
Green='\e[0;32m'	# Green
Yellow='\e[0;33m'	# Yellow
Blue='\e[0;34m'		# Blue
Purple='\e[0;35m'	# Purple
Cyan='\e[0;36m'		# Cyan
White='\e[0;37m'	# White

NOW=$(date +%h%d_%H-%m-%S)
FOLDER="Build_${NOW}"
OUTPUT="kernel_${NOW}.tar.xz"
DEPENDENCIES="gcc make fakeroot libncurses5 libncurses5-dev kernel-package build-essential"
UPDATENEEDED=0
PLUS="${Cyan}[+]${Reg}"

print_kernels(){
	echo "Kernels Available from https://www.kernel.org:"
	TOTAL1=""
	TOTAL2=""
	COUNT=0
	for ver in $(curl -s https://kernel.org | grep "Download complete tarball" | cut -d '.' -f 2- | cut -d '"' -f 1); do
		TOTAL="${TOTAL}\nhttps://www.$ver"
	done
	echo -ne "\n"
	for ver in $(echo -e $TOTAL); do
		((COUNT++))
		printf ' %-3s Linux %-15s' "${COUNT})" "`echo ${ver##*'/'}|cut -d - -f 2- | sed 's/.tar.xz//g'`"
		[ $((COUNT%3)) -eq 0 ] && echo -e -n '\n'
	done
	COUNT=0
	echo -n -e "\n\nSelect your desired kernel: "
	read INPUT
	echo "THIS IS A TEST"
	if ! [ $INPUT -eq $INPUT 2>/dev/null ]; then
		echo "Input must be an integer."
		exit 0
	fi
	echo ""
	echo "Continuing"
	for ver in $(echo -e $TOTAL); do
		echo "${ver}"
		((COUNT++))
		if [ $COUNT -eq $INPUT ]; then
			echo -e "${PLUS} Downloading Kernel"
			echo -e "\_ Saving as ${Cyan}${OUTPUT}${Reg}"
			curl -# -o "$OUTPUT" ${ver}
		fi
	done
}

update(){
	echo -e "${PLUS} Dependencies"
	printf "%-20s" "\_ Updating APT"
	sudo apt-get update 1>/dev/null 2>/dev/null
	echo -e "${Green}Complete${Reg}"
	printf "%-20s" "\_ Installing"
	sudo apt-get install -y $DEPENDENCIES 1>/dev/null 2>/dev/null
	echo -e "${Green}Complete${Reg}\n"
	return 1
}
check_deps(){
	for dep in $(echo ${DEPENDENCIES} | tr ' ' $'\n'); do
		printf '\t%-24s' "${dep}"
		if ! [ -z "`dpkg-query -W 2>&1 | grep $dep`" ]; then
			echo -e "${Green}Found${Reg}"
		else
			echo -e "${Red}Not Found${Reg}"
			UPDATENEEDED=1
		fi
	done
	echo ""
	if [ $UPDATENEEDED -eq 1 ]; then
		update
	fi
}
cleanup(){
	popd
	sudo rm $OUTPUT -f
}

if [ "$#" -gt 1 ]; then
	usage
fi
if [ "$#" -eq 1 ]; then
	if ! [[ -f "$1" ]]; then
		echo "$1 is not a file or does not exist." >&2
		exit 1
	fi
	OUTPUT=$1
else
	echo -e "If you have a local kernel archive, pass it as an argument to use it.\n"
	print_kernels
fi

echo -e "${PLUS} Checking Dependencies"
check_deps

echo -e "${PLUS} Creating a directory to build your kernel from source."
mkdir $FOLDER 2>/dev/null || { echo "You cannot create a directory here." >&2; exit 1; }
echo -e "    Directory Created:\t${Cyan}${FOLDER}${Reg}\n"

echo "${OUTPUT} ~ ${FOLDER}"

echo -e "${PLUS} Extracting your kernel. This may take a while depending on your hardware."
tar xf $OUTPUT -C ./$FOLDER || { echo "An error occured while extracting the archive." >&2; exit 1; }
EXTRACTED=$(ls $FOLDER/)
echo -e "    Extracted Folder:\t${Cyan}${FOLDER}/${EXTRACTED}${Reg}\n"

pushd $FOLDER/linux*

echo -e "${PLUS} Running \"make -s menuconfig\". Follow the instructions."
sudo make -s menuconfig 2>/dev/null || { echo "Error occured while running \"make menuconfig\". I can't help you."; exit 1; }

echo -e "${PLUS} Cleaning the source tree and reseting kernel-package parameters."
sudo make-kpkg clean 1>/dev/null 2>/dev/null || { echo "Error occurred while running \"make-kpkg clean\". I can't help you."; exit 1; }
echo -e "\_ ${Green}Cleaned${Reg}"

read -p "[?] Would you like to build the kernel now? This will take a while (y/N):" -n 1 -r
if [[ ! $REPLY  =~ ^[Yy]$ ]]; then
	echo -e "\n\nYou can build it later with:\nfakeroot make-kpkg --initrd --revision=1.0.0 kernel_image kernel_headers"
else
	echo -e "\n\n${PLUS} Compiling your kernel!"
	sudo fakeroot make-kpkg --initrd --revision=1.0.0 kernel_image kernel_headers || { echo "Something happened during the compilation process, but I can't help you."; exit 1; }
	sudo dpkg -i ../*.deb
fi
cleanup
echo -e "${Green}[%] Complete${Reg}"
