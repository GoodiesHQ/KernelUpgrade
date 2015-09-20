#KernelUpgrade

####Simple Bash script to install a shiny new Kernel.

This script will simply parse https://www.kernel.org for the newest kernels and will allow you to download, compile, and install the kernel image and its headers with ease. It will randomly generate both a file and folder name in which the building process will take place. Note that the process may take up to several hours depending on the hardware.

##Usage
	user@server:~$ git clone https://github.com/GoodiesHQ/KernelUpgrade.git
	user@server:~$ cd KernelUpgrade
	user@server:~/KernelUpgrade$ chmod +x KernelUpgrade.sh
	user@server:~/KernelUpgrade$ sudo bash KernelUpgrade.sh
	
Alternatively, if you have a locally stored Linux Kernel archive in some kind of .tar format, you can use that as your argument.

	user@server:~/KernelUpgrade$ sudo bash KernelUpgrade.sh linux-4.2.tar.xz
