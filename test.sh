#!/bin/sh

MIRRORS=$(curl --retry 5 http://dl-cdn.alpinelinux.org/alpine/MIRRORS.txt 2> /dev/null)
COUNT=$(printf "$MIRRORS" | wc -l)
HOSTS=$(printf "$MIRRORS" | awk -F / '{printf $3" "}')

printf "MIRRORS\n$MIRRORS\n\n"
printf "HOSTS\n$HOSTS\n\n"
printf "COUNT $COUNT\n\n"

HOST=$(./netselect -s 1 -t 7 $HOSTS 2> /dev/null)
test "" == "$HOST" && HOST=$(printf "$HOSTS" | awk '{printf $1; exit}')
MIRROR=$(printf "$MIRRORS" | grep /$HOST/)

printf "HOST $HOST\n\n"
printf "MIRROR $MIRROR\n\n"
