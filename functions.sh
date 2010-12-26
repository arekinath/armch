#!/bin/sh

# functions
function fail {
  echo "==> Aborting: $1"
  exit 1
}

function st {
	echo "==> $1"
}

function ct_ng_build {
	mkdir -p $xtools_dir
	cd $xtools_dir
	cp $armch_path/ct-ng.config .config
	$ctng oldconfig || fail "ct-ng oldconfig failed"
	$ctng build || fail "ct-ng build failed"
}

function cleanup_sb_libtool {
	rm -fr $HOME/.scratchbox2/$sb2_target/{bin,lib,include,share}
}

function setup_root_dir {
	rm -fr $root_dir
	mkdir -p $root_dir/var/lib/pacman
}

function host_makepkg {
	cd $armch_path/$1
	rm -fr src pkg *.pkg.*
	$makepkg --nodeps || fail "makepkg failed in $1"
	sudo $host_pacman -f --noconfirm -v --nodeps --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
}

function create_scratchbox {
	cd $root_dir
	$sb2_init $sb2_target $xtools_dir/$xtools_target/bin/*-gcc || fail "could not init scratchbox"
}

function genconf_nofakeroot {
	cat $1 | sed 's/[^!]fakeroot/!fakeroot/g' > /tmp/nofakeroot.conf
}

function nofakeroot_makepkg {
	cd $armch_path/$1
	rm -fr src pkg *.pkg.*
	$sb2 $makepkg --config /tmp/nofakeroot.conf || fail "makepkg failed in $1"
	sudo $host_pacman -f --noconfirm -v --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
}

function do_makepkg {
	cd $armch_path/$1
	rm -fr src pkg *.pkg.*
	$sb2 $makepkg || fail "makepkg failed in $1"
	sudo $host_pacman -f --noconfirm -v --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
}
