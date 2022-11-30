#!/bin/zsh

emulate -L zsh

modListFile=${0:r}-perlmodules.lst
rpmListFile=${0:r}-rpm.lst
rebuildRpmListFile=${0:r}-rebuild.rpm.lst

#========================================

zparseopts -D -K n=o_dryrun R=o_rebuild

function x {
    print "# $@"
    if (($#o_dryrun)); then return; fi
    "$@" || exit $?
}

#========================================

modList=($(grep -v '^#' $modListFile))
pkgList=("perl("$^modList")")

pkgList+=($(grep -v '^#' $rpmListFile))

if (($#o_rebuild)); then
    pkgList+=($(grep -v '^#' $rebuildRpmListFile))
fi

if (($#pkgList)); then
    x dnf install "$@" $pkgList
else
    echo Nothing installed.
fi
