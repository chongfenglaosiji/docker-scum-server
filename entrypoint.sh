#!/bin/bash
set -e

export HOME=/home/steam

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

echo "🚀 启动 SCUM 服务器..."
exec wine /scum-server/SCUM/Binaries/Win64/SCUMServer.exe \
    -log -port=7777 -queryport=27015 -nobattleye
