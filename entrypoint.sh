#!/bin/sh
# 使用 sh 以保证最大的兼容性

# 如果任何命令失败，脚本会立刻退出，方便调试
set -e

# --- 以下逻辑完全来自于您原来的 docker-compose.yml ---

echo '[INFO] Preparing cron environment...'

# 步骤 1: 创建定时任务配置文件 (使用 sudo)
echo '[INFO] Creating cron job...'

# 使用 `sudo sh -c '...'` 的方式来创建 root 拥有的文件，这是最稳妥和正确的方法。
# 这样可以确保即使脚本的某一部分在非 root 环境下被调用，也能正确写入需要 root 权限的目录。
sudo sh -c 'echo "# 任务1: 每周一凌晨0点，进行一次全面的订阅采集/机场发现
0 0 * * 1 cd /aggregator && python -u subscribe/process.py -s /aggregator/subscribe/config/config.json > /proc/1/fd/1 2>/proc/1/fd/2

# 任务2: 每2小时，刷新并处理所有任务
0 */2 * * * cd /aggregator && python -u subscribe/process.py -s /aggregator/subscribe/config/config.json > /proc/1/fd/1 2>/proc/1/fd/2
" > /etc/cron.d/aggregator_cron'

# 步骤 2: 赋予 cron 任务文件正确的权限 (使用 sudo)
sudo chmod 0644 /etc/cron.d/aggregator_cron
echo '[INFO] Cron job created and permissions set.'

# 步骤 3: 容器启动时，立即执行一次完整的聚合任务
# Dockerfile 最后一行是 USER appuser，所以此命令会以 appuser 用户身份执行，这正是我们想要的。
echo '[INFO] Container started. Running initial aggregation task...'
python -u subscribe/process.py -s /aggregator/subscribe/config/config.json
echo '[INFO] Initial aggregation task finished.'

# 步骤 4: 启动 cron 服务，并在前台运行以保持容器存活
# cron 服务需要 root 权限来读取 /etc/cron.d 并管理任务
echo '[INFO] Starting cron daemon for scheduled tasks...'
# 使用 exec 会让 cron 进程替换掉当前的 shell 进程，成为容器的主进程(PID 1)，
# 这是保持容器运行并能正确接收停止信号的最佳实践。
exec sudo cron -f
