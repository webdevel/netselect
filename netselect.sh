#!/bin/sh

LIST=http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt
FILE=/etc/apk/repositories
URIS=$(curl --retry 5 $LIST 2> /dev/null)
#printf "URIS\n$URIS\n\n"
HOSTS=$(printf "$URIS" | awk -F / '{printf $3" "}')
#printf "HOSTS\n$HOSTS\n\n"
HOST=$(./netselect -s 1 -t 7 $HOSTS 2> /dev/null)
#printf "HOST $HOST\n\n"
URI=$(printf "$URIS" | grep /$HOST/)
#printf "URI $URI\n\n"
CONTENT="${URI}v3.13/main\n${URI}v3.13/community"
printf "$CONTENT" > $FILE
