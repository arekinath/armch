Armch (arch for ARM)
====================

This is my attempt to bring pacman and some of the Archlinux base over to ARM
for the mini2440 board.

I'm using it with scratchbox2 (http://maemo.gitorious.org/scratchbox2)
and ct-ng (http://ymorin.is-a-geek.org/projects/crosstool)

Startup stuff
-------------

Armch uses the busybox init instead of Arch's sysvinit. The default inittab simply runs /etc/rc.sysinit and then starts monit and a login shell on the first UART.

Monit (http://www.mmonit.com/monit) is a service monitoring and maintenance utility. Monitrc files for openssh, dbus and connman are included in their respective packages (and will automagically start upon first run).

Building
--------

1. Install scratchbox2 and ct-ng
2. Customise ct-ng.config to your needs
3. Customise the top of build.sh to point to your installation
4. Run 'sh build.sh'
5. Come back in a few hours :)

Deploying to a rootfs
---------------------

1. Create /var/lib/pacman and /etc/pacman.conf (on target)
2. Move your .pkg.tar.* files from the build tree into one directory
3. Use repo-add to create a pacman repository
4. Add the repo to /etc/pacman.conf
5. Start with 'pacman --root /mnt/target --config /mnt/target/etc/pacman.conf --arch arm -S ct-toolchain busybox filesystem'
6. Then start using pacman to install whatever else you want (s3c-init would be a good idea, as well as udev and pacman itself)
7. If you install native pacman to the target, make sure to re-edit the /etc/pacman.conf to get the repo back in.