#!/bin/zsh

emulate -L zsh

setopt extended_glob

# binDir: /usr/local/perl5
# libDir: /usr/local

binDir=$(cd $0:h && print $PWD)
libDir=$binDir:h

#========================================

zparseopts -D -K n=o_dryrun
function x {
    echo "#" $*
    ((! $#o_dryrun)) || return 0
    "$@" || exit $?
}

#----------------------------------------

function perl_installsite_dirs {
    setopt interactivecomments
    # ↑ To avoid 'command not found: #' in interactive zsh

    # List installsite{arch,lib},
    # removing their trailing version part (like /5.36).
    perl -MConfig -le '
          print "$_\t"
          , $Config{q(installsite).$_} =~ s,/[.\d]+$,,r
          for qw(arch lib)
   ' || return $?
}

typeset -A destDirs
destDirs=($(perl_installsite_dirs)) || exit 1

#========================================

errors=0
for k d in arch lib64 lib share; do
    dst=$destDirs[$k]
    src=$binDir/$d/perl5
    if [[ -d $dst && ! -L $dst ]]; then
        echo 1>&2 "Please remove real directory $dst first!"
        ((errors++))
    fi
    x ln -vnsrf $src $dst
done
if ((errors)); then echo "Stopped"; exit 1; fi

for d in bin etc; do
    dst=$libDir/$d
    src=$binDir/$d
    for f in $src/*(-*.N,-/N); do
        x ln -vnsrf $f $dst
    done
done

() {
    d=zfunc
    dst=$libDir/share/zsh/site-functions
    src=$binDir/$d
    [[ -d $dst ]] || x mkdir -p $dst
    for f in $src/*(-*.N); do
        x ln -vnsrf $f $dst
    done
}
