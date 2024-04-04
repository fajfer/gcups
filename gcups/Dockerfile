FROM docker.io/ubuntu:jammy-20240227
RUN apt-get update && apt-get install -y wget gpg xvfb libgbm-dev libasound2 python3-pip && \
    wget -qO- https://gcups-static.greencell.global/csgsa-keyring.gpg | gpg --dearmor | dd of=/usr/share/keyrings/csgsa-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/csgsa-keyring.gpg] https://gcups-static.greencell.global/deb stable non-free" | dd of=/etc/apt/sources.list.d/gcups.list && \
    apt-get update -y && apt-get install -y gcups && \
    rm -rf var/lib/apt/lists/* && \
    python3 -m pip install plyvel && \
    apt-get remove -y python3-pip && \
    mkdir -m775 -p /opt/gcups/db/gcups-rxdb-1-settings

COPY populate-db.py db.txt ./
RUN python3 populate-db.py

ENV GCUPS_HTTP_PORT=8080
ENV GCUPS_PASSWORD=gcups123

EXPOSE $GCUPS_HTTP_PORT

COPY init.sh /opt/init.sh
ENTRYPOINT ["/opt/init.sh"]
