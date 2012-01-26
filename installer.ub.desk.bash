#! /bin/bash

#
##
#

echo 'import urllib2; print urllib2.urlopen("https://raw.github.com/tomatoNuts/dotfiles/master/bin/installer.ub.server.bash").read()' | python | bash

pkgsExtra='vim-nox zsh ' 
sudo apt-get -y install $pkgsExtra

