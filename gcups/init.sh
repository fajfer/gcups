#!/bin/bash

dbus-daemon --session --fork --print-address 1 > /tmp/dbus-session
export DBUS_SESSION_BUS_ADDRESS=$(cat /tmp/dbus-session)
service dbus start

echo "GCUPS running on port: $GCUPS_HTTP_PORT"
echo "Default webUI password: $GCUPS_PASSWORD"
echo -n "Running gcups " && xvfb-run gcups --version --no-sandbox

xvfb-run gcups --no-sandbox
echo "GCUPS webserver started"
tail -f /opt/gcups/log/error.log