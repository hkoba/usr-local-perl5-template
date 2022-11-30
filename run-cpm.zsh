#!/bin/zsh

emulate -L zsh

error=0

#========================================

# /usr/local
binDir=$(cd $0:h && print $PWD)

# /usr/local/perl5/bin
copiedBin=$binDir/bin

# /usr/local/bin
localBin=$binDir:h/bin

cpm=$localBin/cpm

sudo=()
cpm_sudo=()
if ((UID != 0)); then
    sudo=(sudo)
    cpm_sudo=(--sudo)
fi

#========================================

zparseopts -D -K n=o_dryrun v=o_verbose R=o_rebuild y=o_yes

function x {
    print "# $@"
    if (($#o_dryrun)); then return; fi
    "$@" || exit $?
}

function xx {
    print "# $@"
    "$@" || exit $?
}

#========================================

cd $binDir

[[ -x $cpm ]] || o_rebuild=(-R)

if (($#o_rebuild)); then
    o_changes=()
else
    o_changes=(-c)
fi

if (($#o_rebuild)); then

    xx $binDir/symlinks.zsh record $o_dryrun

    x $sudo rm -rf $binDir/lib64/perl5/auto/**/*.(so|bs)(N)
    x $sudo rm -rf $binDir/{lib64,share}/perl5/*(N)

    xx $sudo $binDir/dnf-install.zsh $o_yes $o_dryrun
fi

if (($#o_rebuild)); then
    x curl -fsSL --compressed --output $copiedBin/cpm https://git.io/cpm
    x $sudo chmod +x $copiedBin/cpm
fi

# cpm の symlink を確実にする
if [[ ! -L $localBin/cpm ]]; then
    x $sudo ln -vnsfr $copiedBin/cpm $localBin/cpm
fi

if (($#o_rebuild)); then
    xx $sudo $binDir/make-symlink.zsh $o_dryrun
fi

# 予め入れておかないと cpm による install がコケるものを列挙
if (($#o_rebuild)); then
    prereqFn=prereq.lst
    if [[ -r $prereqFn ]]; then
        x $cpm install $cpm_sudo -g $(< $prereqFn) || exit 1
    fi
fi

x $cpm install $cpm_sudo -g "$@" || error=1

xx $binDir/symlinks.zsh record $o_dryrun

xx $sudo $binDir/slurp_bin_installed.zsh $o_dryrun

if ((error)); then
    echo cpm failed
    exit 1
else
    echo DONE
fi
