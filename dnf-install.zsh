#!/bin/zsh

emulate -L zsh

dataFile=${0:r}-perlmodules.lst

modList=($(grep -v '^#' $dataFile))

dnf install "$@" "perl("$^modList")"
