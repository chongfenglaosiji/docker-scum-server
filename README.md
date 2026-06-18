# Docker SCUM Server

将 SCUM 专用服务器打包为 Docker 镜像，基于 SteamCMD + Wine 运行。

Dockerized SCUM dedicated server using SteamCMD + Wine.

---

## 快速开始 Quick Start

### 1. 构建镜像 Build

```bash
docker build -t scum-server .
```

### 2. 启动容器 Run

```bash
docker run -d \
  -p 7777-7779:7777-7779/udp \
  -p 7779:7779/tcp \
  -p 27015:27015/udp \
  -v /opt/scum:/scum-server \
  --name scum \
  scum-server
```

启动后服务端文件会自动下载到 `/opt/scum`，配置文件在首次运行后生成，可直接在宿主机上编辑。

On first run, server files are downloaded to `/opt/scum`. Config files are generated automatically — edit them directly on the host.

---

## 如何使用 Usage

### 查看日志 View Logs

```bash
docker logs -f scum
```

首次启动可以看到 SteamCMD 下载进度和服务器启动输出。

Watch SteamCMD download progress and server startup output.

### 停止 / 启动 Stop & Start

```bash
docker stop scum
docker start scum
```

每次启动都会自动检查并更新 SCUM 服务器。

Each start triggers an automatic update check.

### 更新 Update

```bash
docker restart scum
```

重启即触发更新，entrypoint 会自动检测并下载最新版。

Restart triggers update — entrypoint fetches the latest version automatically.

### 进入容器 Shell Access

```bash
docker exec -it scum bash
```

### 修改配置 Edit Config

容器启动后，在挂载目录下生成配置文件：

After first run, config files appear under the mounted volume:

```
/opt/scum/
├── SCUMServer.exe
├── ServerSettings.ini       ← 服务器设置 Server settings
├── Game.ini                 ← 游戏规则 Game rules
├── ...
```

在宿主机上直接编辑，重启生效：

Edit on the host, then restart:

```bash
vim /opt/scum/ServerSettings.ini
docker restart scum
```

### Docker Compose 管理

创建 `docker-compose.yml`：

```yaml
version: "3"
services:
  scum:
    image: scum-server
    container_name: scum
    restart: unless-stopped
    ports:
      - "7777-7779:7777-7779/udp"
      - "7779:7779/tcp"
      - "27015:27015/udp"
    volumes:
      - /opt/scum:/scum-server
```

```bash
docker-compose up -d
```

---

## 端口说明 Ports

| 端口 Port | 协议 Protocol | 用途 Purpose |
|-----------|---------------|--------------|
| 7777      | UDP           | 游戏主端口 Game port |
| 7778      | UDP           | 预留 Reserved |
| 7779      | UDP / TCP     | Steam 联机 Steam networking |
| 27015     | UDP           | 查询端口 Query port |

## 数据卷 Volumes

| 路径 Path | 说明 Description |
|-----------|------------------|
| `/scum-server` | SCUM 服务端安装目录（游戏文件 + 配置） Server installation & configs |

---

## 工作原理 How It Works

1. **SteamCMD** 匿名登录，下载或更新 `SCUMServer.exe`（App ID `3792580`）  
   SteamCMD logs in anonymously and downloads / updates SCUMServer.exe.
2. 安装后检查可执行文件，失败则重试最多 **5 次**  
   Retries up to **5 times** if the executable is not found.
3. 通过 `xvfb-run` + `wine` 启动，绑定 `7777` / `27015`  
   Launches via xvfb-run + wine, bound to ports 7777 / 27015.

## Dockerfile 结构 Dockerfile Structure

| 阶段 Layer | 说明 Description |
|------------|------------------|
| `FROM ubuntu:22.04` | 基础镜像 Base image |
| 安装依赖 Dependencies | wine、xvfb、32位库 wine, xvfb, i386 libs |
| SteamCMD | 下载安装 Download & install |
| 用户创建 User setup | 非 root 运行 Non-root user |
| 入口 Entrypoint | entrypoint.sh，自动更新+启动 Auto-update & launch |

## 注意事项 Notes

- SteamCMD 需要 32 位库（`i386`），构建时已预装  
  32-bit libraries (i386) are pre-installed for SteamCMD.
- 如需交互控制台，去掉 `-d` 并加上 `-it`  
  For console interaction, omit `-d` and add `-it`.
