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
