#!/bin/sh

NETWORK=${NETWORK_NAME:-vpn}

if [ ! -d "/etc/tinc/${NETWORK}" ]; then
    if [ -z "${NETWORK_ADDRESS}" ]; then
        echo Please set NETWORK_ADDRESS environment variable
        exit 1
    fi

    if [ -n "${SERVER}" ]; then
        /usr/sbin/tinc -n "${NETWORK}" init "${NODE_NAME:-$(hostname)}"
        cat > "/etc/tinc/${NETWORK}/invitation-created" <<'EOF'
#!/bin/sh

cat > $INVITATION_FILE <<EOT
Name = $NODE
Netname = $NETNAME
ConnectTo = $NAME
#----------------#
EOT
/usr/sbin/tinc export-all >> $INVITATION_FILE
EOF
        chmod +x "/etc/tinc/${NETWORK}/invitation-created"
    elif [ -n "${INVITE_URL}" ]; then
        /usr/sbin/tinc join "${INVITE_URL}"
    fi

    /usr/sbin/tinc -n "${NETWORK}" add subnet ${NETWORK_ADDRESS}
    if [ -d "/etc/tinc/${NETWORK}" ]; then
        cat > "/etc/tinc/${NETWORK}/tinc-up" <<EOF
#!/bin/sh

/sbin/ip addr add ${NETWORK_ADDRESS}/${NETWORK_PREFIX:-24} dev \$INTERFACE
/sbin/ip link set \$INTERFACE up
EOF

        cat > "/etc/tinc/${NETWORK}/tinc-down" <<EOF
#!/bin/sh

/sbin/ip link set \$INTERFACE down
/sbin/ip addr del ${NETWORK_ADDRESS}/${NETWORK_PREFIX:-24} dev \$INTERFACE
EOF

        chmod +x "/etc/tinc/${NETWORK}/tinc-up" "/etc/tinc/${NETWORK}/tinc-down"
    fi
fi

exec /usr/sbin/tinc $@
