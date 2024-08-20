<!--
SPDX-FileCopyrightText: 2024 Damian Fajfer <damian@fajfer.org>

SPDX-License-Identifier: CC-BY-SA-4.0
-->
# GreenCell UPS App in docker
GC UPS App is a program that enables preview in real time and displays measurement data including input and output voltages, load frequency of the UPS, its temperature and battery capacity.

You can setup automatic system shut-off, notifications and email warnings in the event of switching to batter operation.

> **DISCLAIMER:**  
> I am not affiliated with GREENCELL.GLOBAL brand, I don't represent and I was never employed by CSG S.A. nor I was ever contracted by them for doing any work whatsoever

## About 
I took the desktop-only electron app and forced it to run in docker with HTTP webUI enabled. I wrote a [blog entry](https://blog.fajfer.org/2023/09/16/running-green-cell-ups-app-gcups-on-gnu-linux-server/) regarding the subject.

Join us on [Matrix](https://matrix.to/#/#gcups:fsfe.org) to discuss and troubleshoot!

Table of Contents
=================

   * [About](#about)
   * [Quick Start](#quick-start)
   * [How To Run It](#how-to-run-it)
     * [USB detection](#usb-detection)
     * [Custom settings](#custom-settings)
     * [Docker-compose](#docker-compose)
   * [Versioning](#versioning)
   * [FAQ](#faq)

## Quick Start
For testing purposes (to see if this thing works on your machine) you can run the container in `privileged` mode but this is not recommended, [read](https://learn.snyk.io/lesson/container-runs-in-privileged-mode/).  
`docker run --privileged -p 0.0.0.0:8080:8080 ghcr.io/fajfer/gcups:1.1.7`  

Image exposes port **8080** and the default password is **gcups123**

## How To Run It
Container itself is ready to start, the only thing you need to do is to attach proper USB device:  
`docker run --device=/dev/bus/usb/001/011 -p 0.0.0.0:8080:8080 ghcr.io/fajfer/gcups:1.1.7`  
How to find which device to use? Read [USB detection](#usb-detection)

You can also run it via [Docker-compose](#docker-compose), for which I provided an [example](docker-compose.yaml) of. This is a desktop app that was forced inside of a container and it exposes a HTTP connection which makes you unable to configure following stuff:
- enabling/disabling HTTP server
- changing password
- changing HTTP server port

It's not much of a problem since we're using docker. You can decide to not publish the port and you can always map it to a different port on your host container so it isn't much of a problem. If you wish to change the password, however, then I recommend you read [Custom settings](#custom-settings) part.

## USB detection

An example, based on my `UPS05`, on how to find which USB to mount to your docker.

If you plug your usb and then proceed with `sudo dmesg` you will see something like this:
```
[21022.370000] usb 1-4: new full-speed USB device number 11 using xhci_hcd
[21022.623977] usb 1-4: New USB device found, idVendor=0001, idProduct=0000, bcdDevice= 1.00
[21022.623981] usb 1-4: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[21022.623983] usb 1-4: Product: MEC0003
[21022.623985] usb 1-4: Manufacturer: MEC
```
Let's compare this with `lsusb` output:
```
Bus 006 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 005 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 004 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 003 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 002 Device 002: ID 05e3:0626 Genesys Logic, Inc. USB3.1 Hub
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 011: ID 0001:0000 Fry's Electronics MEC0003
Bus 001 Device 006: ID 046d:c31c Logitech, Inc. Keyboard K120
Bus 001 Device 004: ID 08bb:2902 Texas Instruments PCM2902 Audio Codec
Bus 001 Device 002: ID 05e3:0610 Genesys Logic, Inc. Hub
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
```

Notice device number 11 from `dmesg`:
`[21022.370000] usb 1-4: new full-speed USB device number 11 using xhci_hcd`  

And that we can see both the product and the manufacturer
```
[21022.623983] usb 1-4: Product: MEC0003
[21022.623985] usb 1-4: Manufacturer: MEC
```
That aligns perfectly with our device: 
`Bus 001 Device 011: ID 0001:0000 Fry's Electronics MEC0003`  
We need both bus and device number so `--device=/dev/bus/usb/$BUS/$DEVICE` gives us `--device=/dev/bus/usb/001/011`

## Custom settings
If you didn't read my [blog entry](https://blog.fajfer.org/2023/09/16/running-green-cell-ups-app-gcups-on-gnu-linux-server/) I would recommend scrolling just to the "Generating your own by-sequence" part. Basically you can mount the entire `/opt/gcups/` if you wanted but the only thing you really need is `/opt/gcups/db/gcups-rxdb-1-settings` which is actually a [LevelDB](https://github.com/google/leveldb) database.

Example:
`docker run --device=/dev/bus/usb/001/011 -p 0.0.0.0:8080:8080 -v /opt/gcups/db/gcups-rxdb-1-settings:/opt/gcups/db/gcups-rxdb-1-settings ghcr.io/fajfer/gcups:1.1.7`  

There's no other way at this moment to change the password during runtime since I don't know how to properly manipulate password hash and salt and it doesn't really bother me.

## Docker-compose
An example of [docker-compose.yaml](docker-compose.yaml):
```yaml
version: '3'
services:  
  gcups:
    container_name: gcups
    image: ghcr.io/fajfer/gcups:1.1.7
    ports:
      - '0.0.0.0:8085:8080'
    restart: unless-stopped
    volumes:
      - $HOME/gcups-rxdb-1-settings:/opt/gcups/db/gcups-rxdb-1-settings
    devices:
      - /dev/bus/usb/001/010:/dev/bus/usb/001/010
```
Above example exposes port 8085 on the host, uses a volume and a device. You can safely remove volumes and would need to change your devices based on [USB detection](#usb-detection)

## Versioning
I'm not a fan of `latest` tag so I will probably not to have it here. I'm going to try to always support the latest version (1.1.7 since 02.06.2023) and this is how the container image is named. If I optimize the image I'm going to update the latest available version based on it and if GreenCell releases the new version I will also build it and provide with a new tag.

## FAQ
If you are getting the following error:
```
/opt/gcups/gcups[101]: ../../third_party/electron_node/src/node_api.cc:1332:napi_status napi_release_threadsafe_function(napi_threadsafe_function, napi_threadsafe_function_release_mode): Assertion `(func) != nullptr' failed.
```
Then you have your UPS connected via USB and provided a wrong `--device` for the docker image. This will obviously make the HTTP server unable to start.
