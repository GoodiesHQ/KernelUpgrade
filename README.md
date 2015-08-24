# KernelUpgrade
This is a very simple bash script to automate the process of upgrading your kernel on Debian.

### Requirements
Typical kernel upgrade stuff.
<ul>
<li>gcc</li>
<li>make</li>
<li>fakeroot</li>
<li>libncurses5-dev</li>
<li>build-essentials</li>
</ul>
And whatever else you get an error on. I'm not building this checking nonsense into the script. It's too simple to actually put work into.

### Example Usage - Upgrade to Kernel 4.1.6

```
sudo su
mkdir /tmp/build && cd /tmp/build
curl -# -O https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.1.6.tar.xz
./kernel_upgrade.sh linux-4.1.6.tar.xz
```
