#! /bin/sh

#
## make this GLOBAL variable more secure. We shouldn't be displaying our
## token and username on the wild like this.
##
## It would be cool if each one of us had our encrypted GIT data and 
## whenever we decide to setupt a new git, it would be decrypted on the 
## script. It would prompt us for the file password and then export the 
## the GLOBAL GIT variable.
#

#
## setting up ssh
#
fn_setup_ssh(){
   if [ -d ~/.ssh ]; then
      if [ -d ~/.ssh-bak ]; then
         echo 'would you like to rewrite the ssh backup (n/y): \c'
         read ans
         case "$ans" in
            n) true
               ;;
            y)  ~/.ssh/* ~/.ssh-bak || {
                  echo "\nnothing to back up!\n"
               }
               ;;
            *) exit 1
               ;;
         esac
      else
         mkdir ~/.ssh-bak && cp ~/.ssh/* ~/.ssh-bak || {
            err=3
            echo "EE($err): backing up ~/.ssh failed"; exit $err
         }
      fi
   else
      mkdir ~/.ssh || {
         err=4
         echo "EE($err): creating ~/.ssh failed"; exit $err
      }
   fi

   #cd "$tmp"
   err=5
   ssh-keygen -t rsa -C "$GIT_USER_EMAIL" \
      -f "$HOME/.ssh/id_rsa.$GIT_USER" -N ''
   echo 'keys generated: '
   echo 'new github public key is: '
   cat "$HOME/.ssh/id_rsa.$GIT_USER.pub" || exit $err
   

   
   #cat id_rsa*pub 2>/dev/null && {
   #   err=5
   #   mv $tmp/id_rsa* "$HOME/.ssh" || exit $err
   #} || {
   #   err=6
   #   cat "$HOME/id_rsa.pub" || exit $err
   #}
   
   #cd "$curDir"
   
   echo "
Host github.com
   User $GIT_USER
   HostName github.com
   PreferredAuthentications publickey
   IdentityFile $HOME/.ssh/id_rsa.$GIT_USER" >> "$HOME/.ssh/config"

   #echo 'setup up your ssh key at github \n id_rsd.pub:'
   #cat ~/.ssh/id_rsa.pub
   #if [ -z "$ans" ]; then
   #   err=5
   #   mv /tmp/id_rsa "$HOME/.ssh/." &&
   #   mv /tmp/id_rsa.pub "$HOME/.ssh/." || exit $err
      
   #else 
   #   err=6
   #   mv /tmp/id_rsa "$HOME/.ssh/$ans" &&
   #   mv /tmp/id_rsa.pub "$HOME/.ssh/$ans.pub" || exit $err
   #fi
   # write more informative messsage
   echo "\npress enter after added new pub key to github: \c"
   read
}

#
## setting up github
#

fn_setup_git(){

   #
   ## creating a git
   #

   echo "\nConfigurating Git repo and using current dirname as repo's name"

   #read git_name
   #curl -F "login=$GIT_LOGIN" -F "token=$GIT_TOKEN" "$GIT_URL" -F \
   #   "name=$GIT_REPO" || { 
   #      err=7
   #      echo "EE($err): in creating repo $GIT_REPO"; exit $err
   #   }

   #git remote add origin git@gitgithub.com:"$GIT_LOGIN/$GIT_REPO.git"
   if [ -f "$curDir/.git" ]; then 
      echo 'A'
      git commit -a -m "$(uname -s -r -n) at $(date +%Y.%m.%d\ %H:%M:%S\ %z)"  
      git push -u origin master
   else
      ssh -T git@github.com 
      git config --global user.name "$GIT_USER"
      git config --global user.email "$GIT_USER_EMAIL"
      git config --global github.user "$GIT_USER"
      git config --global github.token "$GIT_TOKEN"

      git init
      git add *
      git remote add origin git@github.com:"$GIT_USER/$GIT_REPO.git"
   fi
}


main(){
   GIT_TOKEN='e22af74515ac01a84932bdac751963bd'
   GIT_USER='bitbyteme'
   GIT_LOGIN='bitbyteme'
   GIT_URL=' https://github.com/api/v2/yaml/repos/create'
   GIT_REPO="${PWD##*/}"
   GIT_USER_EMAIL='bitbyteme@gmail.com'

   curDir="$PWD"
   tmp="/tmp/$$"
   mkdir "$tmp" || exit 99

   echo '\nDo you need to setup a new ssh key-pair? (y|n)\c'
   read ans

   case "$ans" in
      y) fn_setup_ssh
         ;;
      n) true
         ;;
      *) exit 1
         ;;
   esac
   fn_setup_git
}

main



