# usr-local-perl5-template for Fedora/CentOS/RHEL

This is a template to manage CPAN modules for system perl under /usr/local/perl5 with git.


## SYNOPSIS

```sh
dnf install zsh perl git

git clone https://github.com/hkoba/usr-local-perl5-template.git /usr/local/perl5

cd $_

# EDIT cpanfile and dnf-install-perlmodules.lst

# Then

./run-cpm.zsh
```
