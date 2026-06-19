#!/bin/bash
set -e

export HOME=/home/steam

# 创建 Steam 目录符号链接
mkdir -p /home/steam/.local/share/Steam
mkdir -p /home/steam/.steam
rm -f /home/steam/.steam/root /home/steam/.steam/steam
ln -sf /home/steam/.local/share/Steam /home/steam/.steam/root
ln -sf /home/steam/.local/share/Steam /home/steam/.steam/steam

SCUM_DIR="/scum-server"
SCUM_APP_ID="3792580"

# 更新函数（带重试，每次必跑 SteamCMD）
update_scum() {
    local max_retries=5
    local retry=0
    while [ $retry -lt $max_retries ]; do
        echo "🔄 检查 SCUM 更新 (第 $((retry+1)) 次)..."
        set +e
        /opt/steamcmd/steamcmd.sh \
            +force_install_dir "${SCUM_DIR}" \
            +@sSteamCmdForcePlatformType windows \
            +login anonymous \
            +app_update ${SCUM_APP_ID} validate \
            +quit
        local exit_code=$?
        set -e
        if [ $exit_code -eq 0 ]; then
            echo "✅ SteamCMD 更新成功"
            return 0
        fi
        retry=$((retry+1))
        echo "⚠️ SteamCMD 失败 (退出码 $exit_code)，等待 10 秒后重试..."
        sleep 10
    done
    echo "❌ SteamCMD 重试 5 次后仍失败"
    return 1
}

update_scum || exit 1

# 定位可执行文件
EXE_PATH=$(find ${SCUM_DIR} -name "SCUMServer.exe" -type f | head -n 1)
if [ -z "$EXE_PATH" ]; then
    echo "❌ 未找到 SCUMServer.exe"
    exit 1
fi
echo "✅ 服务端程序：$EXE_PATH"
REL_PATH="${EXE_PATH#${SCUM_DIR}/}"

# 直接启动（配置文件由用户自行挂载管理）
echo "🚀 启动 SCUM 服务器（游戏端口 7777，查询端口 27015）..."
cd "${SCUM_DIR}"
xvfb-run --auto-servernum --server-args='-screen 0 1024x768x24' \
    wine "${REL_PATH}" -log -port=7777 -queryport=27015 -nobattleye
