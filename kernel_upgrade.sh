#!/bin/bash
if [ "$#" -ne 1 ]; then
	echo "Usage: $0 [linux kernel tarball]" >&2
	exit 1
fi
if ! [[ -e "$1" ]]; then
	echo "$1 does not exist." >&2
	exit 1
fi
if ! [[ -f "$1" ]]; then
	echo "$1 is not a file." >&2
fi
echo "[+] Creating a directory to build your kernel from source."
mkdir MyNewKernel 2>/dev/null || { echo "You cannot create a directory here." >&2; exit 1; }
echo "[+] Extracting your kernel. This may take a while depending on your hardware."
tar xf $1 -C ./MyNewKernel || { echo "An error occured while extracting the archive." >&2; exit 1; }
cd MyNewKernel/linux*
echo "[+] Running \"make menuconfig\". Follow the instructions."
make menuconfig -s 2>/dev/null || { echo "Error occured while running \"make menuconfig\". I can't help you."; exit 1; }
echo "[+] Cleaning the source tree and reseting kernel-package parameters."
make-kpkg clean 1>/dev/null 2>/dev/null || { echo "Error occurred while running \"make-kpkg clean\". I can't help you."; exit 1; }
read -p "[?] Would you like to build the kernel now? This will take a while (y/N):" -n 1 -r
if [[ ! $REPLY  =~ ^[Yy]$ ]]; then
	echo -e "\n\nYou can build it later with:\nfakeroot make-kpkg --initrd --revision=1.0.0 kernel_image kernel_headers"
	exit 0
else
	echo -e "\n\n[+] Compiling your kernel!"
	fakeroot make-kpkg --initrd --revision=1.0.0 kernel_image kernel_headers || { echo "Something happened during the compilation process, but I can't help you."; exit 1; }
	dpkg -i ../*
fi
