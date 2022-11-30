#!/bin/zsh

#----------------------------------------
# Reset options
# zsh の動作オプションを揃える

emulate -L zsh

set -eu

# setopt YOUR_FAVORITE_OPTIONS_HERE

setopt extended_glob

#----------------------------------------
# Set variables for application directory
# スクリプトをインストール個所に依存させないための変数を用意

# $0            = ~/bin/mytask
# $realScriptFn = /somewhere/myapp/bin/myscript.zsh
# binDir        = /somewhere/myapp/bin
# appDir        = /somewhere/myapp

realScriptFn=$(readlink -f $0); # macOS/BSD の人はここを変更
binDir=$realScriptFn:h
# appDir=$binDir:h

#----------------------------------------
# Parse primary options
# オプションの解析

o_dryrun=() o_quiet=() o_xtrace=() o_help=()
o_version=()

zparseopts -D -K \
           n=o_dryrun -dry-run=o_dryrun \
           q=o_quiet -quiet=o_quiet \
           x=o_xtrace \
           h=o_help      -help=o_help \
           -version:=o_version

if (($#o_xtrace)); then set -x; fi

#----------------------------------------
# Utility functions
# いつも使う関数をここで。(source しても良い)

function x {
    if (($#o_dryrun || !$#o_quiet)); then
        print -R '#' ${(q-)argv}
    fi
    if (($#o_dryrun)); then
        return;
    fi
    "$@" || exit $?
}

function die { echo 1>&2 $*; exit 1 }

#----------------------------------------
# Define subcommands here
# サブコマンドはここで定義する

function cmd_version {
    if (($#o_version)); then
        print ${o_version[2]#=}
    else
        /usr/bin/perl -MConfig -le 'print $Config{PERL_VERSION}'
    fi
}

function cmd_record {
    local ver; ver=$(cmd_version)

    if (($#o_dryrun)); then
        die "Dry-run モードは未実装です"
    fi

    local kind dn
    for kind in share lib64; do
        dn=$kind/perl5/5.$ver
        [[ -d $dn ]] || {
            echo 1>&2 $dn は存在しないのでスキップします
            continue
        }
        () {
            x cp $1 $binDir/symlinks_$kind.lst
        } =(cd $dn && find -type l |
                 xargs perl -e '
                   print join "\t", $_, qx(readlink -f $_) for @ARGV
                 '
        )
    done
}

function cmd_link {
    local ver; ver=$(cmd_version)

    cd $binDir

    local kind fn destPrefix realDest dest src
    for kind in share lib64; do
        destPrefix=$kind/perl5/5.$ver
        for dest src in $(< $binDir/symlinks_$kind.lst); do
            realDest=$destPrefix/$dest
            [[ -d $realDest:h ]] || x mkdir -p $realDest:h
            x ln -vnsfr $src $realDest || break
        done
    done
}

function cmd_help {
    if ((ARGC)); then
        echo 1>&2 $*
    fi
    cat 1>&2 <<EOF
Usage: ${realScriptFn:t} [-h] [-n] SUBCOMMAND ...
EOF
    exit 1
}

#----------------------------------------
# Finally, dispatch given subcommand (or show help)
# 実際の実行

if (($#o_help)) || ! ((ARGC)); then
    cmd_help "$@"
fi

cmd=$1; shift

if (($+functions[cmd_$cmd])); then
    cmd_$cmd "$@"
else
    cmd_help "No such subcommand: $cmd"
fi
