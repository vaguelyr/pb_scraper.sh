#!/bin/bash
# vague
# scrape pastebins site for free, very slowly

wget(){
	#echo wget 1>&2
	command wget $@ -U 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.102 Safari/537.36 Vivaldi/2.0.1309.37'
	#waituntil 10 1>&2  # pastebin likes to ip ban you if you go too fast
	#waituntil 7 1>&2  # pastebin likes to ip ban you if you go too fast
	waituntil 5 1>&2  # pastebin likes to ip ban you if you go too fast
}

waituntil(){
	echo 
	for a in $(seq $1) ; do echo -ne "\rwaiting $a/$1" ; sleep 1s; done
}

# TODO use `file` to see what the file is and reject it based on what it is
# we dont want c++ homework and server logs
trashcheck(){
	:
	#file 
}

while true ; do
    # get the urls for all the recent pastes
	echo scraping index
	page=$(wget -q -O - https://pastebin.com/archive)
	urls=$(echo $page | grep href...........\" -o | grep -Ev "/archive|/messages|/scraping|/settings"  | sed -e 's/.$//' -e 's/.*\//https:\/\/pastebin.com\/raw\//')

    # download all the recent pastes
	for url in $urls ; do
		echo $url
		name=$(echo $url | sed -e 's/.*raw\///')
		wget $url -N ;

  		 # add each paste to the archive
		trashcheck $name && {
			echo trashcheck passed. proceding with archive		
			7z a dumps.7z $name || {
				echo archive failed. waiting a bit
				#sleep 10m
				waituntil 600
			} && {
				echo archive success. removing file
				rm $name
			}
		}
	done
done
