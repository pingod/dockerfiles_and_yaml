#!/bin/bash

if [ ! -f /.container_init ]; then
	/container_init.sh
fi

exec /usr/sbin/sshd -D
