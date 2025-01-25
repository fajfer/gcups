#!/bin/bash
# SPDX-FileCopyrightText: 2024-2025 Damian Fajfer <damian@fajfer.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

dbus-daemon --session --fork --print-address 1 > /tmp/dbus-session
export DBUS_SESSION_BUS_ADDRESS=$(cat /tmp/dbus-session)
service dbus start

echo "GCUPS running on port: $GCUPS_HTTP_PORT"
echo "Default webUI password: $GCUPS_PASSWORD"
echo -n "Running gcups " && xvfb-run gcups --version --no-sandbox

xvfb-run gcups --no-sandbox
echo "GCUPS webserver started"
tail -f /opt/gcups/log/error.log
