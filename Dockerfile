FROM scottyhardy/docker-wine:latest

USER root

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y lib32gcc-s1 lib32stdc++6 libc6-i386 && \
    wget -O /tmp/steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && \
    mkdir -p /opt/steamcmd && \
    tar -xzf /tmp/steamcmd.tar.gz -C /opt/steamcmd && \
    rm /tmp/steamcmd.tar.gz && chmod -R 755 /opt/steamcmd && \
    /opt/steamcmd/steamcmd.sh +quit || true && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -u 1000 steam && \
    echo "steam ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /scum-server && \
    chown -R steam:steam /scum-server

USER steam
WORKDIR /scum-server

COPY --chown=steam:steam entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 7777/udp 27015/udp
VOLUME ["/scum-server"]
ENTRYPOINT ["/entrypoint.sh"]
