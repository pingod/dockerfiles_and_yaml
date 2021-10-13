#!/bin/bash

if [ -f /.container_init ]; then
	exit 0
fi

PASS=${ROOT_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${ROOT_PASS} ] && echo "preset" || echo "random" )
echo "root:$PASS" | chpasswd

adduser --disabled-password --shell /usr/bin/zsh --uid 1000 --gecos "" $USER
adduser $USER sudo

echo $USER":"$PASSWORD | chpasswd
adduser $USER x2gouser

touch /.container_init

