#!/bin/bash
set -e

export HOME=/home/steam

Xvfb :99 -screen 0 1024x768x24 &>/dev/null &
sleep 1
export DISPLAY=:99

mkdir -p /home/steam/.local/share/Steam
mkdir -p /home/steam/.steam
ln -sf /home/steam/.local/share/Steam /home/steam/.steam/root
ln -sf /home/steam/.local/share/Steam /home/steam/.steam/steam

update_scum() {
    local retry=0
    while [ $retry -lt 5 ]; do
        echo "🔄 检查 SCUM 更新..."
        /opt/steamcmd/steamcmd.sh \
            +force_install_dir /scum-server \
            +@sSteamCmdForcePlatformType windows \
            +login anonymous \
            +app_update 3792580 validate \
            +quit && return 0
        retry=$((retry+1))
        sleep 10
    done
    return 1
}
update_scum || exit 1

echo "✅ 服务端已就绪"
echo "📌 手动启动命令:"
echo "   wine /scum-server/SCUM/Binaries/Win64/SCUMServer.exe -log -port=7777 -queryport=27015 -nobattleye"

sleep infinity
