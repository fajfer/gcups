FROM docker.io/ubuntu:jammy-20240227
RUN apt-get update && apt-get install -y wget gpg xvfb libgbm-dev libasound2 && \
    # GC UPS App official setup
    wget -qO- https://gcups-static.greencell.global/csgsa-keyring.gpg | gpg --dearmor | dd of=/usr/share/keyrings/csgsa-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/csgsa-keyring.gpg] https://gcups-static.greencell.global/deb stable non-free" | dd of=/etc/apt/sources.list.d/gcups.list && \
    apt-get update -y && apt-get install -y gcups && \
    rm -rf var/lib/apt/lists/*

EXPOSE 8080
COPY init.sh /opt/init.sh
ENTRYPOINT ["/opt/init.sh"]
