#! /bin/sh

#
##
##
#

git commit -a -m "$(uname -s -r -n) at $(date +%Y.%m.%d\ %H:%M:%S\ %z)"
git push -u origin master 2> /dev/null || {
   echo 'Would you like to force update and lose all history ? (n/y):\c'
   read ans
   case "$ans" in
      y) git push -f -u origin master
         ;;
      n) true
         ;;
      *)exit 1
         ;;
   esac
}


