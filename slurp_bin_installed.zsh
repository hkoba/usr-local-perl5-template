#!/bin/zsh

emulate -L zsh

cd $0:h || exit 1

zparseopts -D -K n=o_dryrun

function x {
    print "# $@"
    if (($#o_dryrun)); then return; fi
    "$@" || exit $?
}

find -name .packlist|xargs grep -h '^/usr/local/bin'|while read fn; do
    dstFn=bin/$fn:t
    if [[ -r $fn && ! -e $dstFn ]]; then
        x cp -vu $fn $dstFn
        x ln -vnsfr $dstFn $fn
    fi
done
