#!/bin/bash
# SPDX-FileCopyrightText: 2025 Damian Fajfer <damian@fajfer.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

UDEV_RULES_DIR=/etc/udev/rules.d

tee $UDEV_RULES_DIR/10-gcups.rules > /dev/null <<EOT
SUBSYSTEM=="input", GROUP="input", MODE="0666"
SUBSYSTEM=="usb", ATTRS{idVendor}=="0001", SYMLINK+="ups", ATTRS{idProduct}=="0000", MODE:="666", GROUP="plugdev"
KERNEL=="hidraw*", ATTRS{idVendor}=="0001", ATTRS{idProduct}=="0000", MODE="0666", GROUP="plugdev"
EOT

tee $UDEV_RULES_DIR/10-gcups17.rules > /dev/null <<EOT
SUBSYSTEM=="input", GROUP="input", MODE="0666"
SUBSYSTEM=="tty", ATTRS{idVendor}=="067b", SYMLINK+="ttyups", ATTRS{idProduct}=="2303", MODE:="666", GROUP="plugdev"
EOT

udevadm control --reload-rules
