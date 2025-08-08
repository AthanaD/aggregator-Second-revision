# Aggregator: 您的终极自动化代理订阅中心

[
![Docker Pulls](https://img.shields.io/docker/pulls/devinglaw/aggregator?style=for-the-badge&logo=docker)
](https://hub.docker.com/r/devinglaw/aggregator)
[
![Build Status](https://img.shields.io/badge/build-passing-success?style=for-the-badge&logo=githubactions)
](https://hub.docker.com/r/devinglaw/aggregator)
[
![Architecture](https://img.shields.io/badge/arch-amd64%20%7C%20arm64-blue?style=for-the-badge&logo=linux)
](https://hub.docker.com/r/devinglaw/aggregator)
[
![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)
](https://github.com/wzdnzd/aggregator/blob/main/LICENSE)

一款功能强大、高度可定制的自动化代理订阅聚合工具，旨在打造一个稳定、高效、无人值守的私有代理池。项目基于 Docker 进行封装，支持多平台架构，让您无论是个人使用还是团队共享，都能轻松部署和管理。

## ✨ 核心特性

*   **🚀 自动化周期执行**: 内置 Cron 定时任务，无需人工干预，自动抓取、更新、处理订阅和节点。
*   **🌐 多源聚合**: 支持从私有订阅链接、公开网页、Telegram 频道、GitHub 仓库等多种来源发现和抓取节点。
*   **🧩 灵活的配置系统**: 通过一份 `config.aggregator.json` 文件即可精细化控制所有抓取和处理逻辑，包括重命名、过滤、分组等。
*   **🐳 Docker 优先**: 提供开箱即用的 `docker-compose.yml`，实现一键部署，屏蔽底层环境差异。
*   **💻 多架构支持**: 镜像同时支持 `linux/amd64` 和 `linux/arm64` 架构，完美适配 X86 服务器、NAS 及树莓派等 ARM 设备。
*   **🔧 可扩展脚本**: 支持通过自定义 Python 脚本扩展抓取逻辑，实现对特殊网站的定制化采集。
*   **☁️ 云端存储**: 可将处理好的配置文件（Clash, Sing-box, V2ray）和抓取到的订阅链接自动推送到 GitHub Gist，方便多客户端同步。

## 🚀 快速开始

通过以下简单几步，即可快速启动您的自动化代理聚合服务。

### 步骤 1: 准备目录和文件

在您的服务器上创建一个项目目录，例如 `my-aggregator`，并进入该目录。

```bash
mkdir my-aggregator
cd my-aggregator
```

然后，创建必要的子目录：

```bash
mkdir -p data scripts
```

*   `data/`: 用于存放由 `aggregator` 生成的持久化数据，例如发现的机场列表等。
*   `scripts/`: (可选) 用于存放您的自定义抓取脚本。

### 步骤 2: 创建配置文件

在项目根目录下创建核心配置文件 `config.aggregator.json`。您可以直接复制下面的模板作为起点。

```bash
touch config.aggregator.json
```
> **提示**: 完整的配置模板和详细解释请参见下方的 **[配置深度解析](#-配置深度解析-configaggregatorjson)** 章节。

### 步骤 3: 创建环境变量文件

为了安全地管理敏感信息（如 GitHub Token），我们使用 `.env` 文件。在项目根目录下创建 `.env.aggregator` 文件。

```bash
touch .env.aggregator
```

然后填入您的 GitHub Gist Token，用于存储生成的配置文件。

```ini
# .env.aggregator

# 您的 GitHub Personal Access Token，需要有 gist 权限
# 用于将生成的 Clash/Singbox 等配置文件推送到 Gist
GIST_TOKEN=ghp_YourGitHubTokenHere
```

### 步骤 4: 创建 Docker Compose 文件

在项目根目录下创建 `docker-compose.yml` 文件。

```bash
touch docker-compose.yml
```

将以下内容复制进去：

```yaml
version: '3.8'

services:
  # 核心服务：Aggregator
  aggregator:
    # 直接从 Docker Hub 拉取构建好的多架构镜像
    image: devinglaw/aggregator:latest
    container_name: aggregator
    restart: unless-stopped
    
    # 关键：将您的配置文件和数据目录挂载进容器
    volumes:
      # 1. 挂载您的配置文件 (只读)
      - ./config.aggregator.json:/aggregator/subscribe/config/config.json:ro
      # 2. 挂载您的数据输出目录
      - ./data:/aggregator/data
      # 3. (可选) 挂载您的自定义脚本目录 (只读)
      - ./scripts:/aggregator/subscribe/scripts:ro

    # 关键：通过 .env 文件安全地传入您的敏感信息
    env_file:
      - .env.aggregator
      
  # Watchtower 服务 (可选)，用于自动更新 aggregator 镜像
  watchtower:
    image: containrrr/watchtower
    restart: always
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      # 每 5 分钟检查一次更新
      - WATCHTOWER_POLL_INTERVAL=300
    # 这里指定只监控 aggregator 这一个容器
    command: "aggregator"
```

### 步骤 5: 启动服务！

一切就绪！在项目根目录下运行以下命令即可启动所有服务。

```bash
docker-compose up -d
```

容器启动后会立即执行一次聚合任务，之后会根据内置的 Cron 计划（默认每2小时）自动运行。

## ⚙️ 配置深度解析 (`config.aggregator.json`)

这是项目的灵魂所在，它定义了数据从哪里来 (`crawl`)、如何处理 (`groups`)、以及存到哪里去 (`storage`)。

<details>
<summary><b>点击查看完整的 <code>config.aggregator.json</code> 模板源代码</b></summary>

```json
{
    "domains": [
        {
            "name": "MyPrivateSub_Placeholder",
            "sub": [
                "https://example.com/your/private/sub/link"
            ],
            "domain": "",
            "enable": false,
            "rename": "",
            "include": "",
            "exclude": "",
            "push_to": [
                "MyProxies"
            ],
            "ignorede": true,
            "liveness": true,
            "rate": 2.5,
            "count": 1,
            "coupon": "",
            "secure": false,
            "renew": {
                "account": [
                    {
                        "email": "",
                        "passwd": "",
                        "ticket": {
                            "enable": true,
                            "autoreset": false,
                            "subject": "",
                            "message": "",
                            "level": 1
                        }
                    }
                ],
                "plan_id": 3,
                "package": "",
                "method": 1,
                "coupon_code": "",
                "chatgpt": {
                    "enable": true,
                    "regex": "",
                    "operate": "IN"
                }
            }
        }
    ],
    "crawl": {
        "enable": true,
        "exclude": "过期|停用|维护",
        "threshold": 5,
        "singlelink": true,
        "persist": {
            "subs": "crawledsubs",
            "proxies": "crawledproxies"
        },
        "config": {
            "rename": "",
            "include": "",
            "exclude": "",
            "xxxxxxx": ""
        },
        "airport_discovery": {
            "enable": true,
            "channel": "jichang_list",
            "pages": 5,
            "rigid": true,
            "chuck": false,
            "push_to": [
                "MyProxies"
            ],
            "persist": {
                "domains": "discovered-airports.txt"
            }
        },
        "telegram": {
            "enable": false,
            "pages": 5,
            "exclude": "",
            "users": {
                "channel": {
                    "include": "",
                    "exclude": "",
                    "config": {
                        "rename": "",
                        "xxxxxx": ""
                    },
                    "push_to": []
                }
            }
        },
        "google": {
            "enable": false,
            "exclude": "",
            "notinurl": [],
            "push_to": []
        },
        "github": {
            "enable": true,
            "pages": 2,
            "push_to": [
                "MyProxies"
            ],
            "exclude": "",
            "spams": []
        },
        "twitter": {
            "enable": false,
            "users": {
                "username": {
                    "enable": true,
                    "num": 30,
                    "include": "",
                    "exclude": "",
                    "config": {
                        "rename": "",
                        "xxxxxx": ""
                    },
                    "push_to": []
                }
            }
        },
        "repositories": [
            {
                "enable": false,
                "username": "",
                "repo_name": "",
                "commits": 3,
                "exclude": "",
                "push_to": []
            }
        ],
        "pages": [
            {
                "enable": true,
                "url": "",
                "include": "",
                "exclude": "",
                "config": {
                    "rename": ""
                },
                "push_to": []
            }
        ],
        "scripts": [
            {
                "enable": false,
                "script": "file#function",
                "params": {
                    "persist": {
                        "fileid": ""
                    },
                    "any": "xxx",
                    "config": {
                        "enable": true,
                        "liveness": true,
                        "exclude": "",
                        "rename": "",
                        "push_to": []
                    }
                }
            }
        ]
    },
    "groups": {
        "MyProxies": {
            "emoji": true,
            "list": true,
            "targets": {
                "clash": "MyClashProfile",
                "singbox": "MySingboxProfile",
                "v2ray": "MyV2rayProfile"
            },
            "regularize": {
                "enable": true,
                "locate": true,
                "bits": 2
            }
        }
    },
    "storage": {
        "engine": "gist",
        "token": "",
        "base": "https://api.github.com",
        "domain": "https://gist.github.com",
        "items": {
            "MyClashProfile": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "clash.yaml"
            },
            "MySingboxProfile": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "singbox.json"
            },
            "MyV2rayProfile": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "v2ray.txt"
            },
            "crawledsubs": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "crawled-subs.txt"
            },
            "crawledproxies": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "crawled-proxies.yaml"
            },
            "discovered-airports.txt": {
                "username": "louism8reise",
                "gistid": "b067dd4e6848fdb37effb0f796669e79",
                "filename": "discovered-airports.txt"
            }
        }
    }
}
```

</details>

### 主要配置块说明

1.  **`domains`**: 定义您的私有、固定订阅源。
    *   `name`: 订阅源的名称。
    *   `sub`: 订阅链接数组。
    *   `enable`: 是否启用此订阅源。
    *   `push_to`: 将此订阅源的节点推送到哪个 `groups` 进行处理。

2.  **`crawl`**: 定义动态抓取任务。
    *   `enable`: 是否开启抓取功能。
    *   `persist`: 定义抓取到的订阅和代理节点的持久化存储位置（对应 `storage` 中的 Gist 文件名）。
    *   `airport_discovery`: 从 Telegram 频道发现潜在的机场网站。
    *   `telegram`, `github`, `google`, `twitter`: 从这些平台抓取订阅链接。
    *   `pages`, `scripts`: 从指定网页或通过自定义脚本抓取。

3.  **`groups`**: 定义节点处理组。
    *   `MyProxies`: 组名，可以自定义。`push_to` 的目标就是这个组名。
    *   `targets`: 定义输出的配置文件类型和对应的 `storage` Gist 文件名。例如，将处理好的节点生成为名为 `MyClashProfile` 的 Clash 配置。
    *   `regularize`: 对节点名称进行美化和规范化，例如添加国旗 emoji。

4.  **`storage`**: 定义存储后端。
    *   `engine`: 目前支持 `gist`。
    *   `token`: **【重要】** 此处留空，Token 由 `.env.aggregator` 文件安全注入。
    *   `items`: 定义每一个 Gist 文件的具体信息。
        *   `MyClashProfile`: 逻辑名称，与 `groups.targets` 中的名称对应。
        *   `gistid`: 您要用于存储的 Gist 的 ID。**所有文件可以共用同一个 Gist ID**。
        *   `filename`: 在该 Gist 中存储的文件名。

## 🛠️ 开发者指南：构建多架构镜像

如果您需要修改源代码并构建自己的镜像，以下是推荐的构建流程。

### 先决条件
1.  安装并运行 Docker，确保 `buildx` 已启用。
2.  登录到您的 Docker Hub 账户: `docker login`

### 一键构建并推送
在项目根目录下，执行以下单条命令即可完成 `amd64` 和 `arm64` 镜像的构建，并自动推送到您的 Docker Hub 仓库。

```bash
# 将 devinglaw/aggregator 替换为您自己的 Docker Hub 用户名和仓库名
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t devinglaw/aggregator:latest \
  -t devinglaw/aggregator:amd64-latest \
  -t devinglaw/aggregator:arm64-latest \
  --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" \
  --push \
  .
```
*   `--platform`: 指定要构建的目标平台。
*   `-t`: 为镜像打上多个标签。`latest` 标签将成为一个指向特定平台镜像的 manifest list。
*   `--build-arg`: 传入构建参数，此处使用清华镜像源加速 Python 包的安装。
*   `--push`: 构建完成后立即推送。
*   `.`: 指定 Dockerfile 所在的上下文路径为当前目录。

## 📜 免责声明

*   本项目仅用于学习和研究网络爬虫及自动化技术，请勿用于任何非法用途。
*   严禁使用本项目进行任何盈利性活动。对于一切因不当使用而产生的后果，项目维护者概不负责。

## 🙏 致谢

*   [Subconverter](https://github.com/asdlokj1qpi233/subconverter), [Mihomo](https://github.com/MetaCubeX/mihomo) 等优秀开源项目。
*   感谢 [NodeSupport](https://github.com/NodeSeekDev/NodeSupport) 和 [YXVM](https://yxvm.com) 对原项目的赞助。
