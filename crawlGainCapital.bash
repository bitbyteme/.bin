#! /bin/bash

#
## Crawling gaincapital.com's FOREX historic data. 
## This crawler is VERY specific! Not general et al.
## It only target .zip files. If the page format changes, this crawler 
## won't work
#

prog="$(basename "$0")"
#tmp="/tmp/$prog/id.$$"; mkdir -p "$tmp" || exit 1
#tmp="$PWD/$prog.$$"
tmp="$PWD/$prog"
target="http://ratedata.gaincapital.com/"

mkdir -p "$tmp" || { echo "EE($err): can't create $tmp"; exit $err ;}

#
## Selecting the time period for here crawling. 
## Leave commented out for crawling everything.
#
#lessThen='2011.06'; greaterThen='2011.06' 


# scanning all data at gain capital

#skip01='True'
# skipping ....
[ -z "$skip01" ] && {
echo "reading $target/*:" 

curl -silent "$target" | grep '<a href="..20.*</a>' | 
sed -e "s;.*href=...;$target;" -e 's;".*;/;' |
while read pp; do
   curl -silent "$pp" | grep '<a href="..*</a>' | 
   sed -e "s;.*href=...;$pp;" -e 's;.zip.*;.zip;' -e 's;">.*;;' |
   while read ll; do
      base="$(basename "$ll")"
      if [ "$base" = "${base%.*}" ]; then
         # It doesn't end with an extention! Needs to go one level down in
         # the FOREX historic table.
         curl -silent "$(echo $ll | sed 's;  *;%20;g')/" | 
         grep '<a href="..*</a>' | grep -vE 'Each months|This is the home' |
         grep -vE 'Will become'  |
         sed -e "s;.*href=...;$ll/;" -e 's;.zip.*;.zip;' -e 's;  *;%20;g' >> "$tmp/db" && echo -n '.' || echo -n '-'
      else
         # Now, files with extentions. 
         echo "$ll" >> "$tmp/db" && echo -n '.'
      fi
   done 
done
}

# downloading all zip files

#skip02='True'
# skipping ....
[ -z "$skip02" ] && {
echo "downloading .zip from $target/*:"

mkdir -p "$tmp/zipped/" || exit 1
cat "$tmp/db" | while read pp; do 
   file="$(echo "$pp" | sed -e 's;.*com/;;' -e 's;%20;_;g' -e 's;/;-;g')"
   # The actual download of the .zip file happens here.
   [ -f "$tmp/zipped/$file" ]  && echo -n '.' || 
      curl "$pp" --O "$tmp/zipped/$file"
done

}
#
## creating a list of every file is which isn't a .zip
#
#skip03='True'
# skipping ....
[ -z "$skip03" ] && {
echo "checking for invalid .zip"

find "$tmp/zipped/" -type f | while read pp; do
   unzip -l "$pp" &>/dev/null || echo "$pp" >> "$tmp/error"
   echo -n '.'
done
echo
}
#
## unziping data
#
#skip04='True'
# skipping ....
[ -z "$skip04" ] && {
echo 'unzipping'

#tmp02="$tmp/unzipped"

#tmp00='/Volumes/emptyBrain/'
mkdir -p "$tmp/unzipped" || exit 1
find "$tmp/zipped/" -type f | while read pp; do
   file="$(basename "$pp" | sed 's;.zip$;.csv;')"
   #if [ -f "$tmp/unzipped/$file" ] || [ -f "$tmp02/$file" ]; then
   if [ -f "$tmp/unzipped/$file" ]; then
      echo -n '.' 
   else
      if unzip -qqp "$pp" 2>/dev/null > "$tmp/unzipped/$file"; then 
         echo -n '+' 
      else 
         echo -n '-'
         # removing filename that was created but failed to unzip
         rm "$tmp/unzipped/$file" || exit 1
      fi
   fi
done  
}

echo -e "\n$prog: (EE): this files are not .zip."
cat "$tmp/error"

