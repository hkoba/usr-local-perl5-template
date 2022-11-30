#!/bin/zsh

emulate -L zsh

modListFile=${0:r}-perlmodules.lst
rpmListFile=${0:r}-rpm.lst

modList=($(grep -v '^#' $modListFile)) || exit 1
pkgList=("perl("$^modList")")

pkgList+=($(grep -v '^#' $rpmListFile)) || exit 1

dnf install "$@" $pkgList
