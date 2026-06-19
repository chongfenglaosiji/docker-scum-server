<!-- Language Toggle -->
<input type="radio" id="lang-zh" name="lang" checked hidden>
<input type="radio" id="lang-en" name="lang" hidden>
<style>
  #lang-zh:checked ~ .zh { display: block; }
  #lang-zh:checked ~ .en { display: none; }
  #lang-en:checked ~ .zh { display: none; }
  #lang-en:checked ~ .en { display: block; }
  .lang-btn {
    cursor: pointer;
    display: inline-block;
    padding: 6px 16px;
    margin: 4px;
    border: 1px solid #0366d6;
    border-radius: 4px;
    color: #0366d6;
    background: #fff;
    font-size: 14px;
    user-select: none;
  }
  .lang-btn:hover { background: #0366d6; color: #fff; }
  #lang-zh:checked ~ .lang-bar label[for="lang-zh"] { background: #0366d6; color: #fff; }
  #lang-en:checked ~ .lang-bar label[for="lang-en"] { background: #0366d6; color: #fff; }
</style>

<div class="lang-bar">
  <label class="lang-btn" for="lang-zh">中文</label>
  <label class="lang-btn" for="lang-en">English</label>
</div>

<!-- 中文内容 -->
<div class="zh">

# Docker SCUM Server

基于 `scottyhardy/docker-wine` + SteamCMD 构建的 **[SCUM](https://store.steampowered.com/app/513710/SCUM/)** 专用服务器 Docker 镜像。

## 概述

通过 Wine 兼容层在 Linux Docker 容器中运行 SCUM 游戏服务器。服务器文件通过 SteamCMD 自动下载并更新。

## 快速开始

### 构建镜像

```bash
docker build -t scum-server .
```

### 启动容器

```bash
docker run -d \
  -p 7777-7779:7777-7779/udp \
  -p 7779:7779/tcp \
  -p 27015:27015/udp \
  -v /opt/scum:/scum-server \
  --name scum \
  scum-server
```

首次启动会自动通过 SteamCMD 下载 SCUM 服务端文件（约 18GB），完成后自动启动服务器。

### 查看日志

```bash
docker logs -f scum
```

### 管理服务器

```bash
docker stop scum      # 停止
docker start scum     # 启动（每次启动自动检查更新）
docker restart scum   # 重启
```

## 端口说明

| 端口 | 协议 | 用途 |
|------|------|------|
| 7777 | UDP  | 游戏主端口 |
| 7778 | UDP  | 预留 |
| 7779 | UDP/TCP | Steam 联机 |
| 27015| UDP  | 查询端口 |

## 数据持久化

服务端文件和配置文件通过卷挂载持久化到宿主机：

```bash
-v /opt/scum:/scum-server
```

配置目录：`/opt/scum/SCUM/Saved/Config/WindowsServer/`

## 配置修改

首次启动后会生成默认配置文件，编辑后重启容器生效：

```bash
vim /opt/scum/SCUM/Saved/Config/WindowsServer/ServerSettings.ini
docker restart scum
```

## 技术栈

- **基础镜像**: [scottyhardy/docker-wine](https://github.com/scottyhardy/docker-wine) (WineHQ + winbind + Xvfb)
- **Wine 版本**: WineHQ Stable (9.0+)
- **SteamCMD**: 官方 Steam 命令行客户端
- **SCUM App ID**: 3792580

## 注意事项

- 首次启动由于需要下载约 18GB 游戏文件，预计耗时 30-60 分钟
- 镜像基于 Wine 转译运行 Windows 程序，CPU 和内存开销略高于原生
- 建议至少分配 4GB 内存和 4 核 CPU

</div>

<!-- English Content -->
<div class="en">

# Docker SCUM Server

A Dockerized **[SCUM](https://store.steampowered.com/app/513710/SCUM/)** dedicated server built on `scottyhardy/docker-wine` + SteamCMD.

## Overview

Runs the SCUM game server inside a Linux Docker container via the Wine compatibility layer. Server files are automatically downloaded and updated through SteamCMD.

## Quick Start

### Build

```bash
docker build -t scum-server .
```

### Run

```bash
docker run -d \
  -p 7777-7779:7777-7779/udp \
  -p 7779:7779/tcp \
  -p 27015:27015/udp \
  -v /opt/scum:/scum-server \
  --name scum \
  scum-server
```

On first run, SteamCMD downloads the SCUM server files (~18GB). The server starts automatically once complete.

### View Logs

```bash
docker logs -f scum
```

### Server Management

```bash
docker stop scum      # Stop
docker start scum     # Start (auto-updates on each start)
docker restart scum   # Restart
```

## Ports

| Port | Protocol | Purpose |
|------|----------|---------|
| 7777 | UDP      | Game port |
| 7778 | UDP      | Reserved |
| 7779 | UDP/TCP  | Steam networking |
| 27015| UDP      | Query port |

## Data Persistence

Server files and configs are persisted on the host via a mounted volume:

```bash
-v /opt/scum:/scum-server
```

Config directory: `/opt/scum/SCUM/Saved/Config/WindowsServer/`

## Configuration

Default config files are generated on first run. Edit them on the host and restart to apply:

```bash
vim /opt/scum/SCUM/Saved/Config/WindowsServer/ServerSettings.ini
docker restart scum
```

## Tech Stack

- **Base Image**: [scottyhardy/docker-wine](https://github.com/scottyhardy/docker-wine) (WineHQ + winbind + Xvfb)
- **Wine**: WineHQ Stable (9.0+)
- **SteamCMD**: Official Steam console client
- **SCUM App ID**: 3792580

## Notes

- First start requires downloading ~18GB of game files (30-60 min expected)
- Wine translation layer adds some CPU/memory overhead vs native
- Recommended minimum: 4GB RAM, 4 CPU cores

</div>
