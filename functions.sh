#!/bin/sh

# functions
function fail {
  echo "==> Aborting: $1"
  exit 1
}

function st {
	echo "==> $1"
}

function new_log {
	rm -f $armch_path/.build
	touch $armch_path/.build
}

function log_done {
  echo "$1" >> $armch_path/.build
}

function not_logged {
  local v=`cat $armch_path/.build | grep "$1"`
	if [[ -n "$v" ]]; then
		return 1
	else
		return 0
	fi
}

function ct_ng_build {
  if not_logged "ct_ng_build"; then
		mkdir -p $xtools_dir
		cd $xtools_dir
		cp $armch_path/ct-ng.config .config
		$ctng oldconfig || fail "ct-ng oldconfig failed"
		$ctng build || fail "ct-ng build failed"
		log_done "ct_ng_build"
	fi
}

function cleanup_sb_libtool {
	rm -fr $HOME/.scratchbox2/$sb2_target/{bin,lib,include,share}
}

function setup_root_dir {
  if not_logged "setup_root_dir"; then
		rm -fr $root_dir
		mkdir -p $root_dir/var/lib/pacman
		mkdir -p $root_dir/etc
		cp $armch_path/makepkg.conf $root_dir/etc/makepkg.conf
		log_done "setup_root_dir"
	fi
}

function redo_pacman_config {
	cd $root_dir/etc
	sudo mv makepkg.conf.pacorig makepkg.conf
}

function host_makepkg {
	if not_logged "host_makepkg $1"; then
		cd $armch_path/$1
		rm -fr src pkg *.pkg.*
		$makepkg --config /tmp/nofakeroot.conf --nodeps || fail "makepkg failed in $1"
		sudo $host_pacman -f --noconfirm -v --nodeps --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
		log_done "host_makepkg $1"
	fi
}

function create_scratchbox {
  if not_logged "create_scratchbox"; then
		cd $root_dir
		$sb2_init $sb2_target $xtools_dir/$xtools_target/bin/*-gcc || fail "could not init scratchbox"
		log_done "create_scratchbox"
	fi
}

function genconf_nofakeroot {
	cat $1 | sed 's/[^!]fakeroot/!fakeroot/g' > /tmp/nofakeroot.conf
}

function nofakeroot_makepkg {
	if not_logged "nofakeroot_makepkg $1"; then
		cd $armch_path/$1
		rm -fr src pkg *.pkg.*
		$sb2 $makepkg --config /tmp/nofakeroot.conf || fail "makepkg failed in $1"
		sudo $host_pacman -f --noconfirm -v --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
		log_done "nofakeroot_makepkg $1"
	fi
}

function do_makepkg {
	if not_logged "makepkg $1"; then
		cd $armch_path/$1
		rm -fr src pkg *.pkg.*
		$sb2 $makepkg || fail "makepkg failed in $1"
		sudo $host_pacman -f --noconfirm -v --root $root_dir --arch arm -U $armch_path/$1/*.pkg.* || fail "could not install $1"
		log_done "makepkg $1"
	fi
}
