#! /bin/sh

#! /bin/sh

# Copyright <year> <copyright holder>. All rights reserved.

# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are 
# met:

#    1. Redistributions of source code must retain the above copyright 
#       notice, this list of conditions and the following disclaimer.

#    2. Redistributions in binary form must reproduce the above copyright 
#       notice, this list of conditions and the following disclaimer in the 
#       documentation and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ''AS IS'' AND ANY EXPRESS 
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
# DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# The views and conclusions contained in the software and documentation are 
# those of the authors and should not be interpreted as representing 
# official policies, either expressed or implied, of <copyright holder>.

#
## This installer assumes a clean Lion Mac OSX 10.7.x install. 
#
echo 'a'

function fn_basic(){
   # Xcode.
   if ! which 'gcc-4.2' &>/dev/null; then
      open -a 'Install Xcode' &>/dev/null || {
         err=1
         echo "EE($err): Can't install Xcode, need to download it from"
         echo "AppStore first, then try again." 
         exit $err
      }
      echo 'After Xcode is done installing, run me again.'
      exit 0 
   fi
}

function fn_gcc(){
  echo 'gcc' 

}

exit 0


function fn_install_brew(){

   # little "hack". The intention is to not have a process being 
   # stuck because of authentication issues. 
   # Remember, sudo only applies to  the process and its child processes
   # that are initiated by sudo.
   sudo echo '\c'

   # homebrew
   if ! which brew &>/dev/null; then
      brewURL='https://raw.github.com/gist/323731' 
      /usr/bin/ruby -e "$(curl -fsSL $brewURL)" && 
      brew update || { 
         err=2
         echo "EE($err): Problem installing/updating homebrew."; exit $err 
      }
   fi
   export PATH="/usr/local/bin:$PATH"
}

function fn_python(){
   if ! [ "$(which python)" = '/usr/local/bin/python' ]; then
      # python deps
      err=4
      tmp00='readline
sqlite
gdbm
pkg-config'
      for dep in $tmp00; do
         brew list | grep "$dep" &>/dev/null && continue 

         brew install --verbose "$dep" || { 
            echo "EE($err): python's dependency $dep didn't install."
            exit $err
         }
         dep="$(echo "$dep" | sed -e 's;gdbm;dbm;' -e 's;sqlite;&3;')"
         
         # testing python libraries. 
         if ! [ "$dep" = 'pkg-config' ]; then 
            # skipping testing pkg-config
            if ! python -c "import $dep"; then
               echo "EE($err): python dependency $dep failed test." | 
                  sed -e 's;dbm;g&;' -e 's;sqlite3;sqlite;' 
               exit $err   
            fi
         fi
      done

      # installing python
      [ "$(which python)" = '/usr/local/bin/python' ] ||
         brew install --verbose python --framework --universal
   
      # symlinking new python into Lion's framework path
      tmp00='/Users/bitbyte/Library/Python/2.7/lib/python/site-packages'
      mkdir -p "$tmp00"
      ln -s ~/.pythonrc "$tmp00/usercustomize.py" &>/dev/null
   
      frameOld='Frameworks/Python.framework/Versions/Current'
      frameNew="/usr/local/Cellar/python/2.7.2/$frameOld"
      if ! [ -h "/System/Library/$frameOld-bak" ]; then
         sudo mv "/System/Library/$frameOld" "/System/Library/$frameOld-bak" 
         sudo ln -s "$frameNew" "/System/Library/$frameOld" || {
            echo "EE($err): symlinking framework."; exit $err
         }
      fi
   fi
   export PATH="/usr/local/share/python:$PATH"
   
   # pip
   if ! which pip &>/dev/null; then
      err=6
      easy_install pip || { echo "EE($err): pip failed."; exit $err ;}
   fi

}

function fn_pylab(){
   #gfortran
   if ! which gfortran &>/dev/null; then
      err=7
      brew install --verbose gfortran || { 
         echo "EE($err): gfortran failed."; exit $err
      } 
   fi
   
   # numpy
   if ! python -c 'import numpy' &>/dev/null; then
      err=8
      tmp00='git+https://github.com/numpy/numpy#egg=numpy'
      pip install -e "$tmp00" || { 
         echo "EE($err): numpy failed."; exit $err 
      }
      #pip install numpy || { echo "EE($err): numpy failed."; exit $err ;}
   fi

   export CC="gcc-4.2"
   export CXX="g++-4.2"
   export FFLAGS="-ff2c"
   
   # scipy
   if ! python -c 'import scipy' &>/dev/null; then
      err=9
      tmp00='git+https://github.com/scipy/scipy#egg=scipy'
      pip install -e "$tmp00" || { 
         echo "EE($err): scipy failed."; exit $err 
      }
   fi
   
   # matplotlib
   if ! python -c 'import matplotlib' &>/dev/null; then
      err=10
      tmp00='git+https://github.com/matplotlib/matplotlib#egg=matplotlib'  
      pip install -e "$tmp00" || { 
         echo "EE($err): matplotlib failed."; exit $err 
      }
   fi
   
   export CC=''
   export CXX=''
   export FFLAGS=''

   # ipython
   if ! which ipython &>/dev/null; then
      err=12
      pip install ipython || { 
         echo "EE($err): ipython failed."; exit $err 
      }
   fi

   # nokia's Qt toolkits and libs.
   if ! which qmake &>/dev/null; then
      cd '/usr/local/src/' 
      err=13
      tmp00='http://get.qt.nokia.com/qt/source/qt-mac-opensource-4.7.4.dmg'
      tmp01=$(basename "$tmp00")
      if [ -f "$tmp01" ]; then
         open "$tmp01" || {
            echo "EE($err): qtLib failed."; exit $err
         }
      else
         echo "downloading $tmp01 at $PWD"
         curl -O "$tmp00" && open "$tmp01" || {
            echo "EE($err): qtLib failed."; exit $err
         }
      fi
      echo 'After PyQt4 is done installing, run me again.'
      exit 0
   fi

   # pyqt
   export PYTHONPATH="/usr/local/lib/python:$PYTHONPATH"
   if ! python -c 'import PyQt4' &>/dev/null; then
      err=14
      brew install --verbose pyqt || { 
         echo "EE($err): nose failed."; exit $err 
      }
   fi

   # pyzmq
   export CC="gcc-4.2"
   export CXX="g++-4.2"
   export FFLAGS="-ff2c"
   if ! brew list | grep 'zeromq' &>/dev/null; then
      brew install --use-gcc 'zmq' || {
         err=15
         echo "EE($err): zmq failed."; exit $err
      }
   fi
   if ! python -c 'import zmq' &>/dev/null; then
      err=16
      pip install 'pyzmq' || { echo "EE($err): pyzmq failed."; exit $err ;}
   fi
   if ! python -c 'import pyicu' &>/dev/null; then
      err=16
      pip install 'pyicu' || { echo "EE($err): pyicu failed."; exit $err ;}
   fi
   export CC=''
   export CXX=''
   export FFLAGS=''

   # pygments
   if ! python -c 'import pygments' &>/dev/null; then
      err=17
      pip install 'pygments' || { 
      echo "EE($err): pygments failed."; exit $err 
   }
   fi

}

function fn_brew_extra(){
   err=18
   tmp00='mongodb
redis'
#boost'
   for pkg in $tmp00; do
      # Create a test for boost c++ lib
      [ -d '/usr/local/Cellar/boost' ] && continue

      if ! which "$( echo "$pkg" | sed -e 's;mongodb;mongo;'\
         -e 's;redis;&-cli;')" &>/dev/null; then
         brew install --verbose "$pkg" || { 
         echo "EE($err): $pkg failed."; exit $err 
      }
      fi
   done
}

function fn_redis_setup(){
   err=19
   if ! [ -f ~/Library/LaunchAgents ]; then
      mkdir -p ~/Library/LaunchAgents || {
         echo "EE($err): Redis setup failed"; exit $err
      }
   fi

   cp '/usr/local/Cellar/redis/2.2.14/io.redis.redis-server.plist' ~/Library/LaunchAgents/. &&
   launchctl load -w ~/Library/LaunchAgents/io.redis.redis-server.plist 2>/dev/null || {
      echo "EE($err): Redis setup failed."; exit $err
   }
}

function fn_python_extra(){
   err=20
   tmp00='nose
sympy
pymongo
redis'
   for pkg in $tmp00; do
      if ! python -c "import $pkg" &>/dev/null; then
         pip install "$pkg" || { echo "EE($err): $pkg failed."; exit $err ;}
      fi
   done
}

function fn_profile(){
   # setting up user's .bash_profile
   err=3
   tmp00='# add txt here
alias ipython="ipython --TerminalInteractiveShell.colors=\"Linux\" --TerminalInteractiveShell.confirm_exit=False --TerminalInteractiveShell.deep_reload=True --pprint"
alias ipy="ipython qtconsole --pylab=inline"
export PATH="/usr/local/share/python:$PATH"
export PATH="/usr/local/bin:$PATH"
export PYTHONPATH="/usr/local/lib/python:$PYTHONPATH"'
   echo "$tmp00" | while read path; do
      grep "$path" ~/.bash_profile  || echo "$path" >> ~/.bash_profile
   done &>/dev/null

   tmp00='[ -f ~/.bash_profile ] && . ~/.bash_profile'
   grep "$tmp00" ~/.bashrc &>/dev/null || echo "$tmp00" >> ~/.bashrc 

   [ -f ~/.bash_profile ] || { 
      echo "EE($err): file ~/.bash_profile wasn't created."; exit $err
   }
}

function main(){
   fn_basic 
   fn_gcc
   fn_install_brew
   fn_python 
   
   # raise error if /usr/local doesn't exists yet!!!
   [ -d '/usr/local' ] && cd '/usr/local' || {
      err=5
      echo "EE($err): can't change to /usr/local directory."; exit $err
   }
   echo 'a'
   fn_pylab
   fn_brew_extra
   fn_redis_setup 
   fn_python_extra
   fn_profile

}

echo 'A'
main


