#! /bin/sh

#
##
#


echo "testing numpy"
echo 'import numpy; numpy.test("full")' 2>/dev/null || {
   err=1
   echo "EE($err): numpy test failed." ; exit $err
}
echo 'press ^C to quit or enter to test scipy. \c'; read 

python -c 'import scipy; scipy.test("full")' 2>/dev/null || {
   err=2
   echo "EE($err): scipy test failed." ; exit $err
}
exit 0




