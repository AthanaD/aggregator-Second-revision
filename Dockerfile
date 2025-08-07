# 使用一个支持多架构的基础镜像
FROM python:3.12.3-slim

# Docker buildx 会自动提供这个变量，值会是 amd64 或 arm64
ARG TARGETARCH

# --- 新增部分 ---
# 安装 sudo 和 cron，为定时任务做准备
# 切换到 root 用户进行安装
USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends sudo cron && \
    rm -rf /var/lib/apt/lists/*
# --- 新增部分结束 ---

# 设置工作目录
WORKDIR /aggregator

# 复制依赖和源码

COPY . .


# 根据目标架构，删除不需要的二进制文件
# 这是一个更健壮的方法，确保只保留正确架构的文件
RUN case ${TARGETARCH} in \
        "amd64") \
            echo "Building for amd64, keeping amd64 binaries." ; \
            rm -rf subconverter/subconverter-darwin-amd64 subconverter/subconverter-darwin-arm64 subconverter/subconverter-windows-amd64.exe subconverter/subconverter-linux-arm64 ; \
            rm -rf clash/clash-linux-arm64 ; \
            ;; \
        "arm64") \
            echo "Building for arm64, keeping arm64 binaries." ; \
            rm -rf subconverter/subconverter-darwin-amd64 subconverter/subconverter-darwin-arm64 subconverter/subconverter-windows-amd64.exe subconverter/subconverter-linux-amd64 ; \
            rm -rf clash/clash-linux-amd64 ; \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGETARCH}" ; \
            exit 1 ; \
            ;; \
    esac

# 安装依赖
# build-arg 可以在 buildx 命令中传入
ARG PIP_INDEX_URL
RUN pip install --no-cache-dir -r requirements.txt -i ${PIP_INDEX_URL:-https://pypi.org/simple}

# --- 新增部分 ---
# 创建一个非 root 用户，并赋予其免密 sudo 权限
# 这比直接用 root 运行应用更安全
RUN useradd -m appuser && \
    echo "appuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# ======================= [核心修复与加固] =======================
# 1. [预防性修复] 授予二进制文件可执行权限。
#    这样 Python 脚本 (无论被手动还是被 cron 调用) 都能成功执行它们。
#    我们使用 find 命令来确保所有匹配的二进制文件都被正确处理。
RUN chmod +x /aggregator/entrypoint.sh && \
    find /aggregator/clash -type f -name 'clash-linux-*' -exec chmod +x {} + && \
    find /aggregator/subconverter -type f -name 'subconverter-linux-*' -exec chmod +x {} +


# 2. [解决已知问题] 将工作目录的所有权赋予新创建的 appuser。
#    -R 表示递归。这样 appuser 就能在 /aggregator/data 等子目录中写入日志和数据了。
RUN chown -R appuser:appuser /aggregator
# ===============================================================

# 切换回新创建的普通用户
# 容器将以此用户启动，与您 docker-compose.yml 的设计完全吻合
USER appuser
# --- 新增部分结束 ---
# 设置入口点，这样 docker-compose 中就不需要再写 entrypoint 了
ENTRYPOINT ["/aggregator/entrypoint.sh"]

# 暴露端口 (如果你的应用需要的话，保留)
# EXPOSE 8000
# 启动命令 (重要：我们不再使用这个 CMD)
# CMD ["python", "app.py"] 
# CMD 不再重要，因为 docker-compose.yml 中的 entrypoint 会覆盖它。
# 保留一个占位的 CMD 是个好习惯。
CMD ["sh"]
