#!/bin/sh
# 使用 sh 而不是 bash，因为基础镜像是 slim 版，不一定有 bash

# 如果任何命令失败，脚本会立刻退出，方便调试
set -e

# --- 这段逻辑完全来自您的 docker-compose.yml ---

echo '[INFO] Preparing cron environment...'

# 创建定时任务配置文件 (使用 sudo)
echo '[INFO] Creating cron job...'
# 注意：这里我们不再需要 `sudo sh -c '...'` 的复杂写法了，因为脚本本身就是以 root 权限启动的
# （Docker的ENTRYPOINT默认以root执行，之后才切换到USER）
# 但为了保险起见，尤其是在ENTRYPOINT和sudo交互时，保留sudo是稳妥的。
sudo echo "# 任务1: 每周一凌晨0点，进行一次全面的订阅采集/机场发现
0 0 * * 1 cd /aggregator && python -u subscribe/process.py -s /aggregator/subscribe/config/config.json > /proc/1/fd/1 2>/proc/1/fd/2

# 任务2: 每2小时，刷新并处理所有任务
0 */2 * * * cd /aggregator && python -u subscribe/process.py -s /aggregator/subscribe/config/config.json > /proc/1/fd/1 2>/proc/1/fd/2
" > /etc/cron.d/aggregator_cron

# 赋予 cron 任务文件正确的权限
sudo chmod 0644 /etc/cron.d/aggregator_cron

# 容器启动时，立即执行一次完整的聚合任务 (以 appuser 身份)
echo '[INFO] Container started. Running initial aggregation task...'
# 使用 su-exec 或 gosu 是更安全的做法，但这里用 sudo 也可以
# sudo -u appuser command...
# 这里的 python 命令会以 Dockerfile 中最后的 USER (appuser) 身份运行，所以直接写即可
python -u subscribe/process.py -s /aggregator/subscribe/config/config.json
echo '[INFO] Initial aggregation task finished.'

# 启动 cron 服务，并在前台运行以保持容器存活
echo '[INFO] Starting cron daemon for scheduled tasks...'
# cron 服务需要 root 权限来读取 /etc/cron.d 并管理任务
exec sudo cron -f
