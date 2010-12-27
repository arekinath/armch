#!/bin/sh

# path to the pkgbuilds and this file
armch_path=`pwd`

# config files
ctng_config="ct-ng.config"
makepkg_config="makepkg.conf"

# config and destination dir for ct-ng
xtools_dir="$HOME/x-tools"
# if you want to change this you'll have to change it in the ct-ng.config
# and also in makepkg.conf
xtools_target="arm-s3c-linux-gnueabi"

# root dir for the sb2 image
root_dir="$HOME/arm-root"

# scratchbox2 target
#sb2_target="ARM-MINI"
sb2_target="ARM"

# paths for things
# defaults are just to use which
ctng=`which ct-ng`
host_pacman=`which pacman`
host_fakeroot=`which fakeroot`
makepkg=`which makepkg`

sb2=`which sb2`
sb2_bin=`dirname $sb2`
sb2_init="${sb2_bin}/sb2-init"

# include functions
source $armch_path/functions.sh

# now the big bit:
# list of actual actions to take

st "Starting toolchain build"
ct_ng_build

st "Creating root directory"
setup_root_dir
genconf_nofakeroot $armch_path/makepkg.conf

st "Installing toolchain package"
host_makepkg "core/ct-toolchain"

st "Installing base filesystem"
host_makepkg "core/iana-etc"
host_makepkg "core/filesystem"

st "Creating scratchbox"
create_scratchbox

st "Installing deps for fakeroot"
nofakeroot_makepkg "core/ncurses"
nofakeroot_makepkg "core/busybox"
nofakeroot_makepkg "core/fakeroot"

do_makepkg "core/ncurses"
do_makepkg "core/busybox"
do_makepkg "core/fakeroot"

st "Installing deps for pacman"
do_makepkg "core/libtool"
cleanup_sb_libtool
do_makepkg "core/bzip2"
do_makepkg "core/db"
do_makepkg "core/m4"
do_makepkg "core/flex"
do_makepkg "core/attr"
do_makepkg "core/acl"
do_makepkg "core/readline"
do_makepkg "core/bash"
do_makepkg "core/zlib"
do_makepkg "core/xz"
do_makepkg "core/expat"
do_makepkg "core/libarchive"
do_makepkg "core/openssl"
do_makepkg "core/libfetch"
do_makepkg "core/pacman"
redo_pacman_config

st "Installing base utils"
do_makepkg "core/cracklib"
do_makepkg "core/dhcpcd"
do_makepkg "core/dialog"
do_makepkg "core/expat"
do_makepkg "core/file"
do_makepkg "core/gdbm"
do_makepkg "core/inetutils"
do_makepkg "core/iptables"
do_makepkg "core/libgpg-error"
do_makepkg "core/libgcrypt"
do_makepkg "core/libusb"
do_makepkg "core/libusb-compat"
do_makepkg "core/nano"
do_makepkg "core/openssh"
do_makepkg "core/pcre"
do_makepkg "core/tcl"
do_makepkg "core/wget"
do_makepkg "core/usbutils"
do_makepkg "core/util-linux-ng"

st "Installing deps for udev"
do_makepkg "extra/libffi"
do_makepkg "core/sqlite3"
do_makepkg "extra/python2"
do_makepkg "extra/gperf"
do_makepkg "extra/libxml2"
do_makepkg "extra/libxslt"
do_makepkg "core/glib2"
do_makepkg "core/module-init-tools"
do_makepkg "core/udev"

st "Installing deps for connman"
do_makepkg "core/dbus-core"
do_makepkg "extra/connman"

st "Installing base system"
do_makepkg "core/s3c-static-dev"
do_makepkg "extra/monit"
do_makepkg "core/s3c-init"
do_makepkg "extra/ruby"
do_makepkg "core/ca-certificates"

st "Installing touchscreen and qt"
do_makepkg "fbui/tslib"
do_makepkg "fbui/qt-embedded"
