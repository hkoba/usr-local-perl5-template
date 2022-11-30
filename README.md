# usr-local-perl5-template for Fedora/CentOS/RHEL

This is a template to manage CPAN modules for system perl under /usr/local/perl5 with git.

See [this article](https://hkoba.github.io/perl/adv2022/book/)(in Japanese) for details.

## SYNOPSIS

```sh
dnf install zsh perl git

git clone https://github.com/hkoba/usr-local-perl5-template.git /usr/local/perl5

cd $_

# EDIT cpanfile and dnf-install-perlmodules.lst

# Then

./run-cpm.zsh
```
