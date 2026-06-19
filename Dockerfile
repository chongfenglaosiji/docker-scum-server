FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    SCUM_APP_ID=3792580 \
    SCUM_SERVER_DIR=/scum-server \
    STEAMCMD_USER=steam \
    HOME=/home/steam

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y wget curl xvfb gnupg2 software-properties-common \
        fonts-wine procps sudo lib32gcc-s1 lib32stdc++6 libc6-i386 \
        cabextract && \
    mkdir -p /etc/apt/keyrings && \
    wget -O /etc/apt/keyrings/winehq.asc https://dl.winehq.org/wine-builds/winehq.key && \
    echo "deb [signed-by=/etc/apt/keyrings/winehq.asc] https://dl.winehq.org/wine-builds/ubuntu/ jammy main" > /etc/apt/sources.list.d/winehq.list && \
    apt-get update && \
    apt-get install -y --install-recommends winehq-stable && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN wget -O /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    mkdir -p /opt/steamcmd && \
    tar -xzf /tmp/steamcmd.tar.gz -C /opt/steamcmd && \
    rm /tmp/steamcmd.tar.gz && chmod -R 755 /opt/steamcmd

RUN /opt/steamcmd/steamcmd.sh +quit || true

RUN useradd -m -s /bin/bash -u 1000 ${STEAMCMD_USER} && \
    echo "${STEAMCMD_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chown -R ${STEAMCMD_USER}:${STEAMCMD_USER} /home/${STEAMCMD_USER}

RUN chown -R ${STEAMCMD_USER}:${STEAMCMD_USER} /opt/steamcmd
RUN mkdir -p ${SCUM_SERVER_DIR} && chown -R ${STEAMCMD_USER}:${STEAMCMD_USER} ${SCUM_SERVER_DIR}

USER ${STEAMCMD_USER}
WORKDIR ${SCUM_SERVER_DIR}

COPY --chown=${STEAMCMD_USER}:${STEAMCMD_USER} entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7777/udp 27015/udp
VOLUME ["${SCUM_SERVER_DIR}"]
ENTRYPOINT ["/entrypoint.sh"]
