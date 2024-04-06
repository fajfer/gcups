FROM docker.io/ubuntu:jammy-20240227
RUN apt-get update && apt-get install --no-install-recommends -y wget gpg xvfb libgbm-dev libasound2 python3-pip dbus-user-session && \
    wget -qO- https://gcups-static.greencell.global/csgsa-keyring.gpg | gpg --dearmor | dd of=/usr/share/keyrings/csgsa-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/csgsa-keyring.gpg] https://gcups-static.greencell.global/deb stable non-free" | dd of=/etc/apt/sources.list.d/gcups.list && \
    apt-get update -y && apt-get install --no-install-recommends -y gcups && \
    rm -rf var/lib/apt/lists/* && \
    python3 -m pip --no-cache-dir install plyvel && \
    python3 -m pip --no-cache-dir uninstall setuptools wheel && \
    apt-get remove -y python3-pip && \
    mkdir -m775 -p /opt/gcups/db/gcups-rxdb-1-settings && \
    rm -rf /opt/gcups/license /opt/gcups/manuals && rm -rf /tmp/* && \
    useradd -m gcups && chown -R gcups:gcups /opt/gcups && \
    mkdir /var/run/dbus && chown -R gcups:gcups /var/run/dbus

COPY --chown=gcups:gcups init.sh populate-db.py db.txt /opt/
WORKDIR /opt
RUN python3 populate-db.py

ENV GCUPS_HTTP_PORT=8080
ENV GCUPS_PASSWORD=gcups123
EXPOSE $GCUPS_HTTP_PORT

USER gcups
ENTRYPOINT ["/opt/init.sh"]
