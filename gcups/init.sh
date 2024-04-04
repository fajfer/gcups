#!/bin/bash

dbus-daemon --session --fork --print-address 1 > /tmp/dbus-session
export DBUS_SESSION_BUS_ADDRESS=$(cat /tmp/dbus-session)
service dbus start

echo "GCUPS running on port: $GCUPS_HTTP_PORT"
echo "Default webUI password: $GCUPS_PASSWORD"

xvfb-run \
    gcups -vvv --no-sandbox
