#! /bin/sh

#
##
#

plat="$(uname)"
urlLinux='https://raw.github.com/bitbyteme/.bin/master/installer.ub.bash'
urlMac='https://raw.github.com/bitbyteme/bin/master/installer.lion.bash'
if [ "$plat" = 'Linux' ]; then
   python -c "import urllib2; print urllib2.urlopen('$urlLinux').read()"|sh
elif [ "$plat" = 'Darwin' ]; then
   python -c "import urllib2; print urllib2.urlopen('$urlMac').read()"|sh
fi


