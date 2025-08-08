# Airport Utils: 终极代理管理与自动化工具集

[
![Python Version](https://img.shields.io/badge/python-3.8+-blue.svg?style=for-the-badge&logo=python)
](https://www.python.org/)
[
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)
](https://opensource.org/licenses/MIT)
[
![Status](https://img.shields.io/badge/status-active-success.svg?style=for-the-badge)
]()

一个强大的、模块化的 Python 脚本集合，专为机场（Proxy Provider）用户和管理者设计，旨在实现从发现、扫描、续订到节点清理、过滤和分析的全流程自动化。

---

## ✨ 核心功能

本工具集包含多个独立的脚本，每个脚本都专注于一项特定任务：

-   **✈️ 机场扫描与发现**:
    -   **SSPanel 扫描器 (`scaner.py`)**: 自动发现、注册并抓取 SSPanel 站点的所有节点信息。
    -   **X-UI 面板扫描器 (`xui.py`)**: 批量扫描 X-UI 面板，提取 VLESS, VMess, Trojan, Shadowsocks 节点，并生成格式化的订阅链接和 Markdown 报告。
-   **🤖 自动化维护**:
    -   **自动签到 (`auto-checkin.py`)**: 每日自动登录指定机场网站并执行签到，获取流量。
    -   **自动续订/重置 (`renewal.py`)**: 自动为 V2Board 站点的账户购买或重置套餐。
    -   **PureFast 专用签到 (`purefast.py`)**: 针对 PureFast 网站的复杂人机验证进行自动化签到。
-   **🧹 节点管理与优化**:
    -   **Clash 配置清理器 (`clean.py`)**: 规范化节点命名、基于 GeoIP 添加国家/地区信息、移除重复节点、并强制执行安全策略（如 TLS）。
    -   **Clash 节点过滤器 (`filter.py`)**: 与运行中的 Clash 核心交互，根据延迟自动筛选并移除慢速或无效节点。
-   **📊 数据分析**:
    -   **IP 地理位置分析 (`ip-location.py`)**: 批量查询 IP 地址的地理位置、ASN 和组织信息，并导出为 Excel 表格。

## 🔧 环境准备

在开始之前，请确保您已安装 Python 3.8+ 环境，并安装所有必要的依赖库。

1.  **克隆或下载项目**

2.  **安装依赖**:
    ```bash
    pip install -r requirements.txt

[
![Python Version](https://img.shields.io/badge/python-3.8+-blue.svg?style=for-the-badge&logo=python)
](https://www.python.org/)
[
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)
](https://opensource.org/licenses/MIT)
[
![Status](https://img.shields.io/badge/status-active-success.svg?style=for-the-badge)
]()


##  Scripts Overview & Usage

下面是每个核心脚本的详细介绍和使用方法。

<details>
<summary><strong>✈️ 1. 机场自动签到 (<code>auto-checkin.py</code>)</strong></summary>

### 简介
该脚本用于自动登录多个基于 SSPanel 或 V2Board 的机场网站并执行每日签到。

### 配置
在脚本同目录下创建 `config.json` 文件，并按以下格式填入您的账户信息：

```json
{
    "proxyServer": {
        "http": "http://127.0.0.1:1080",
        "https": "http://127.0.0.1:1080"
    },
    "waitTime": 0,
    "retry": 5,
    "domains": [
        {
            "domain": "https://your-airport-domain.com",
            "proxy": true,
            "param": {
                "email": "your_email@example.com",
                "passwd": "your_password"
            }
        },
        {
            "domain": "https://another-airport.net",
            "proxy": false,
            "param": {
                "email": "another_email@example.com",
                "passwd": "another_password"
            }
        }
    ]
}
```

### 使用
直接运行脚本即可。
```bash
python auto-checkin.py
```
日志将记录在 `checkin.log` 文件中。

</details>

<details>
<summary><strong>🧹 2. Clash 配置清理器 (<code>clean.py</code>)</strong></summary>

### 简介
此脚本用于处理一个 Clash 配置文件（或仅含 `proxies` 列表的 YAML 文件），进行去重、重命名、地理位置标注和安全强化。

### 使用方法
```bash
python clean.py [OPTIONS]
```

**常用参数:**
-   `-c, --config`: 指定要处理的 Clash 配置文件路径 (默认为 `config.yaml`)。
-   `-l, --location`: 根据节点 IP 解析其地理位置并用于重命名。
-   `-b, --backup`: 在修改前备份原始文件。
-   `-n, --num`: 节点重命名后的数字后缀位数 (默认为 `2`)。
-   `-s, --secure`: 强制开启 `tls` 并禁用 `skip-cert-verify`。
-   `-u, --update`: 强制更新 GeoIP 数据库。

**示例:**
```bash
# 清理 myproxies.yaml，根据IP重命名，并备份原文件
python clean.py -c myproxies.yaml -l -b
```

</details>

<details>
<summary><strong>🚀 3. Clash 节点过滤器 (<code>filter.py</code>)</strong></summary>

### 简介
通过 Clash 的 RESTful API，自动测试 `proxy-providers` 中的节点，并移除延迟过高或不可用的节点，最后自动重载 Clash 配置。

### 前提
-   Clash 核心（例如 Mihomo）必须正在运行。
-   Clash 的 `external-controller` API 必须已启用。

### 使用方法
```bash
python filter.py [OPTIONS]
```

**常用参数:**
-   `-c, --config`: 指定 Clash 的主配置文件 `config.yaml` 的路径。
-   `-p, --provider`: 指定要进行过滤的 `proxy-provider` 的名称。
-   `-a, --all`: 过滤所有 `proxy-providers`。
-   `-d, --delay`: 可接受的最大延迟（毫秒），超过此值的节点将被移除 (默认为 `600`)。
-   `-b, --backup`: 备份被修改的 provider 文件。

**示例:**
```bash
# 过滤名为 "MyProvider" 的节点池，移除延迟超过800ms的节点
python filter.py -c ~/.config/clash/config.yaml -p "MyProvider" -d 800
```

</details>

<details>
<summary><strong>📊 4. IP 地理位置分析 (<code>ip-location.py</code>)</strong></summary>

### 简介
批量查询 IP 地址的地理位置信息（国家、城市、ASN等），并将结果保存为 Excel 文件。IP 源默认为 `https://zip.baipiao.eu.org`。

### 使用方法
```bash
python ip-location.py [OPTIONS]
```

**常用参数:**
-   `-d, --directory`: 数据存储目录 (默认为 `./data`)。
-   `-f, --file`: 输出的 Excel 文件名 (默认为 `ips.xlsx`)。
-   `-u, --update`: 强制更新 IP 列表和 GeoIP 数据库。

**示例:**
```bash
# 运行分析并生成报告
python ip-location.py -u -f cloudflare_ips_report.xlsx
```

</details>

<details>
<summary><strong>🔍 5. SSPanel 机场扫描器 (<code>scaner.py</code>)</strong></summary>

### 简介
一个强大的扫描工具，能够发现并利用部分 SSPanel 站点的 `/getnodelist` 接口，自动注册账户并抓取全站节点。

### 使用方法
```bash
python scaner.py [OPTIONS]
```

**常用参数:**
-   `-a, --address`: 目标机场域名或包含域名列表的本地文件。
-   `-b, --batch`: 启用批量模式，从文件中读取域名列表进行扫描。
-   `-e, --email`: 用于注册的邮箱地址。
-   `-p, --passwd`: 用于注册的密码。
-   `-f, --file`: 将抓取到的节点保存为 YAML 文件的路径。
-   `-t, --type`: 要抓取的节点类型 (`vmess`, `ssr`, `all`)，默认为 `vmess`。
-   `-s, --skip`: 跳过注册步骤（如果账户已存在）。

**示例:**
```bash
# 扫描单个机场
python scaner.py -a "https://example-airport.com" -e "test@test.com" -p "password123" -f "example.yaml"

# 批量扫描 airports.txt 中的所有机场
python scaner.py -b -a "airports.txt" -e "test@test.com" -p "password123" -d "./output_proxies"
```

</details>

<details>
<summary><strong>📈 6. X-UI 面板扫描器 (<code>xui.py</code>)</strong></summary>

### 简介
批量扫描 X-UI 面板，尝试使用默认凭据登录，成功后提取所有可用节点的订阅链接，并生成一份美观的 Markdown 报告。

### 使用方法
```bash
python xui.py [OPTIONS]
```

**常用参数:**
-   `-f, --filename`: 包含 X-UI 面板 URL 列表的文件（必需）。
-   `-l, --link`: 输出的 Base64 编码的订阅链接文件名 (默认为 `links.txt`)。
-   `-m, --markdown`: 输出的 Markdown 报告文件名 (默认为 `table.md`)。
-   `-a, --available`: 保存登录成功的面板 URL 的文件名 (默认为 `availables.txt`)。
-   `-t, --thread`: 并发扫描的线程数。
-   `-u, --update`: 强制更新 GeoIP 数据库。

**示例:**
```bash
# 从 xui_panels.txt 文件开始扫描
python xui.py -f xui_panels.txt -t 50
```

</details>

<details>
<summary><strong>🔄 7. V2Board 计划续订 (<code>renewal.py</code>)</strong></summary>

### 简介
为基于 V2Board 的机场账户自动执行购买套餐或重置流量的操作。

### 配置
与 `auto-checkin.py` 类似，在 `config.json` 的 `param` 中添加续订相关参数。
```json
// ... in config.json
{
    "domain": "https://v2board-airport.com",
    "proxy": true,
    "param": {
        "email": "your_email@example.com",
        "passwd": "your_password",
        "couponCode": "your_coupon_code",
        "renewalPeriod": "month_price", // 续订周期
        "resetPeriod": "reset_price", // 重置周期
        "planId": "1" // 套餐ID
    }
}
```

### 使用方法
```bash
python renewal.py [OPTIONS]
```

**常用参数:**
-   `-c, --config`: 配置文件路径 (默认为 `config.json`)。
-   `-n, --num`: 续订次数 (默认为 `1`)。
-   `-r, --reset`: 执行重置流量操作，而不是续订。
-   `-s, --sleep`: 每次续订后的随机等待时间（分钟）。

**示例:**
```bash
# 对配置文件中所有账户执行一次续订
python renewal.py

# 对配置文件中所有账户执行一次流量重置
python renewal.py -r
```

</details>


## 📜 免责声明
-   本项目所有脚本仅供技术学习和研究使用。
-   请勿将本工具集用于任何非法活动或商业盈利用途。
-   使用者应对自己的行为负责，作者对因使用这些脚本而导致的任何后果概不负责。

---
*Generated with ❤️ by an AI assistant based on the provided source code.*
