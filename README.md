<!--
 * @Author: wzdnzd
 * @Date: 2022-03-06 14:51:29
 * @Description: 
 * Copyright (c) 2022 by wzdnzd, All Rights Reserved.
-->

## 功能
打造免费代理池，爬一切可爬节点
> 拥有灵活的插件系统，如果目标网站特殊，现有功能未能覆盖，可针对性地通过插件实现

> 欢迎 Star 及 PR。对于质量较高且普适的爬取目标，亦可在 Issues 中列出，将在评估后选择性添加

## 使用方法
> 可前往 [Issue #91](https://github.com/wzdnzd/aggregator/issues/91) 食用**共享订阅**，量大质优。**请勿浪费**
 
略，自行探索。我才不会告诉你入口是 `collect.py` 和 `process.py`。**强烈建议使用后者，前者只是个小玩具**，配置参考 `subscribe/config/config.default.json`，详细文档见 [DeepWiki](https://deepwiki.com/wzdnzd/aggregator)


## 免责申明
+ 本项目仅用作学习爬虫技术，请勿滥用，不要通过此工具做任何违法乱纪或有损国家利益之事
+ 禁止使用该项目进行任何盈利活动，对一切非法使用所产生的后果，本人概不负责

## 致谢
1. <u>[Subconverter](https://github.com/asdlokj1qpi233/subconverter)</u>、<u>[Mihomo](https://github.com/MetaCubeX/mihomo)</u>

2. 感谢 [![YXVM](https://support.nodeget.com/page/promotion?id=250)](https://yxvm.com)
[NodeSupport](https://github.com/NodeSeekDev/NodeSupport) 赞助了本项目
Docker desktop设置：
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "dns": [
    "114.114.114.114",
    "8.8.8.8"
  ],
  "experimental": false,
  "registry-mirrors": [
    "https://registry.docker-cn.com"
  ]
}

DOCKERHUB_USERNAME：devinglaw
DOCKERHUB_TOKEN：dckr_pat_s7FDFO_tK-ivNH0oxBlwcvfSD8o


# 1. 构建 amd64 镜像
docker build -t devinglaw/aggregator:amd64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .
# 2. 推送 amd64 镜像
docker push devinglaw/aggregator:amd64-latest
# 1. 使用 buildx 构建 arm64 镜像并加载到本地
docker buildx build --platform linux/arm64 -t devinglaw/aggregator:arm64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" --load .
# 2. 推送 arm64 镜像
docker push devinglaw/aggregator:arm64-latest
# 1. 创建一个 manifest，它指向刚才上传的两个镜像
docker manifest create devinglaw/aggregator:latest --amend devinglaw/aggregator:amd64-latest --amend devinglaw/aggregator:arm64-latest
# 2. 将这个 manifest 推送到 Docker Hub，完成最终的关联
docker manifest push devinglaw/aggregator:latest


# 如果 mybuilder 还存在，就删除它
docker buildx rm mybuilder
# 1. 构建并标记 amd64 镜像 (您本地的架构)
docker build --platform linux/amd64 -t devinglaw/aggregator:amd64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .
# 2. 构建并标记 arm64 镜像 (在本地模拟构建)
# 这一步可能会慢一些，因为它是在模拟 arm64 环境
docker build --platform linux/arm64 -t devinglaw/aggregator:arm64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .
# 1. 推送 amd64 镜像
docker push devinglaw/aggregator:amd64-latest
# 2. 推送 arm64 镜像
docker push devinglaw/aggregator:arm64-latest
# 1. 创建 manifest list，指向云端的两个镜像
docker manifest create devinglaw/aggregator:latest --amend devinglaw/aggregator:amd64-latest --amend devinglaw/aggregator:arm64-latest
# 2. 推送这个 manifest list，完成最终合并
docker manifest push devinglaw/aggregator:latest

# 1. 拉取 amd64 版本的 python 基础镜像 (可能已存在，但执行一下无妨)
docker pull --platform linux/amd64 python:3.12.3-slim
# 2. 拉取 arm64 版本的 python 基础镜像 (这是关键！)
docker pull --platform linux/arm64 python:3.12.3-slim
# 1. 构建 amd64 镜像 (会使用缓存，很快)
docker build --platform linux/amd64 -t devinglaw/aggregator:amd64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .
# 2. 构建 arm64 镜像 (现在应该会成功了！)
docker build --platform linux/arm64 -t devinglaw/aggregator:arm64-latest --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" .
# 1. 推送 amd64 镜像
docker push devinglaw/aggregator:amd64-latest
# 2. 推送 arm64 镜像
docker push devinglaw/aggregator:arm64-latest
# 1. 创建 manifest
docker manifest create devinglaw/aggregator:latest --amend devinglaw/aggregator:amd64-latest --amend devinglaw/aggregator:arm64-latest
# 2. 推送 manifest
docker manifest push devinglaw/aggregator:latest
以上最后两步可能出错，建议在VPS中运行：
docker login
docker pull devinglaw/aggregator:amd64-latest
docker pull devinglaw/aggregator:arm64-latest
docker manifest rm devinglaw/aggregator:latest
#!/bin/bash
# 这是一个完整的、从头到尾的脚本，请直接复制全部内容执行
# --- 准备工作 ---
# 步骤 1: (如果需要) 安装 jq 工具。如果已安装，这步会自动跳过。
# CentOS/RHEL 系统使用 yum
if command -v yum &> /dev/null && ! command -v jq &> /dev/null; then
    echo "正在安装 jq 工具..."
    sudo yum install -y jq
fi
# Debian/Ubuntu 系统使用 apt-get
if command -v apt-get &> /dev/null && ! command -v jq &> /dev/null; then
    echo "正在安装 jq 工具..."
    sudo apt-get update && sudo apt-get install -y jq
fi
# 步骤 2: 定义镜像名称变量，方便后续使用
IMAGE_NAME="devinglaw/aggregator"
echo "准备操作的镜像: ${IMAGE_NAME}"
# 步骤 3: 清理本地可能存在的残留 manifest (安全起见)
# "|| true" 表示如果命令失败（比如 manifest 本来就不存在），也继续执行后续步骤
echo "正在清理本地旧的 manifest (如果存在)..."
docker manifest rm ${IMAGE_NAME}:latest || true
# --- 核心操作 ---
echo "正在从 Docker Hub 获取 amd64 镜像的精确 digest..."
AMD64_DIGEST=$(docker manifest inspect "${IMAGE_NAME}:amd64-latest" | jq -r '.manifests[] | select(.platform.architecture == "amd64").digest')
echo "正在从 Docker Hub 获取 arm64 镜像的精确 digest..."
ARM64_DIGEST=$(docker manifest inspect "${IMAGE_NAME}:arm64-latest" | jq -r '.manifests[] | select(.platform.architecture == "arm64").digest')
# 检查 digest 是否成功获取
if [ -z "${AMD64_DIGEST}" ] || [ -z "${ARM64_DIGEST}" ]; then
    echo "错误：获取 digest 失败，请检查网络或镜像标签是否存在！"
    exit 1
fi
echo "----------------------------------------"
echo "获取到的 Digest 如下:"
echo "AMD64: ${AMD64_DIGEST}"
echo "ARM64: ${ARM64_DIGEST}"
echo "----------------------------------------"
echo "正在使用精确的 digest 创建新的 manifest..."
docker manifest create "${IMAGE_NAME}:latest" \
  "${IMAGE_NAME}@${AMD64_DIGEST}" \
  "${IMAGE_NAME}@${ARM64_DIGEST}"
echo "正在将新的 manifest 推送到 Docker Hub..."
docker manifest push "${IMAGE_NAME}:latest"
# --- 完成 ---
echo ""
echo "🎉 操作成功！"
echo "多架构 manifest '${IMAGE_NAME}:latest' 已成功创建并推送到 Docker Hub。"
echo "您现在可以去 Docker Hub 网站或使用 'docker buildx imagetools inspect ${IMAGE_NAME}:latest' 命令进行验证。"
docker buildx imagetools inspect devinglaw/aggregator:latest

在VPS中运行：
# 进入你的项目目录
cd /root/aggregator-main/

# 一条命令完成所有构建和推送
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t devinglaw/aggregator:latest \
  -t devinglaw/aggregator:amd64-latest \
  -t devinglaw/aggregator:arm64-latest \
  --build-arg PIP_INDEX_URL="https://pypi.tuna.tsinghua.edu.cn/simple" \
  --push \
  .





#!/bin/bash
# 该脚本用于构建并推送一个支持 amd64 和 arm64 架构的 Docker 镜像。
# --- 配置项 ---
# 请将这里的镜像名称替换为您自己的
IMAGE_NAME="devinglaw/aggregator"
PIP_MIRROR="https://pypi.tuna.tsinghua.edu.cn/simple"
# --- 脚本开始 ---
set -e # 如果任何命令失败，则立即退出脚本
echo "==== [阶段一：准备基础镜像] ===="
# 拉取两个平台的基础镜像，确保构建环境的一致性
docker pull --platform linux/amd64 python:3.12.3-slim
docker pull --platform linux/arm64 python:3.12.3-slim
echo "==== [阶段二：为每个平台分别构建并推送镜像] ===="
# 1. 构建并推送 amd64 镜像
echo "--> 构建 amd64 镜像..."
docker build --platform linux/amd64 -t "${IMAGE_NAME}:amd64-latest" --build-arg PIP_INDEX_URL="${PIP_MIRROR}" .
echo "--> 推送 amd64 镜像..."
docker push "${IMAGE_NAME}:amd64-latest"
# 2. 构建并推送 arm64 镜像
echo "--> 构建 arm64 镜像..."
docker build --platform linux/arm64 -t "${IMAGE_NAME}:arm64-latest" --build-arg PIP_INDEX_URL="${PIP_MIRROR}" .
echo "--> 推送 arm64 镜像..."
docker push "${IMAGE_NAME}:arm64-latest"
echo "==== [阶段三：【核心】精确创建并推送多架构清单] ===="
# 这是解决问题的关键步骤。我们不再使用 :tag 的方式来合并，
# 因为 :tag 指向的是一个包含“镜像本身”和“构建证明(attestation)”的清单列表。
# 我们需要直接引用那个“镜像本身”的精确地址(digest)，以避免歧义。
# 1. 获取 amd64 镜像的精确 digest
# 我们通过 inspect 命令找到 platform.architecture 为 "amd64" 的那个清单的 digest
AMD64_DIGEST=$(docker manifest inspect "${IMAGE_NAME}:amd64-latest" | jq -r '.manifests[] | select(.platform.architecture == "amd64" and .platform.os == "linux") | .digest')
echo "找到 amd64 的 Digest: ${AMD64_DIGEST}"
# 2. 获取 arm64 镜像的精确 digest
# 同理，找到 platform.architecture 为 "arm64" 的那个清单的 digest
ARM64_DIGEST=$(docker manifest inspect "${IMAGE_NAME}:arm64-latest" | jq -r '.manifests[] | select(.platform.architecture == "arm64" and .platform.os == "linux") | .digest')
echo "找到 arm64 的 Digest: ${ARM64_DIGEST}"
# 3. 使用精确的 digest 创建并推送最终的 manifest
# 注意：${IMAGE_NAME}@${AMD64_DIGEST} 这种@digest的写法是成功的关键！
echo "--> 创建最终的 latest 清单..."
docker manifest create "${IMAGE_NAME}:latest" \
  "${IMAGE_NAME}@${AMD64_DIGEST}" \
  "${IMAGE_NAME}@${ARM64_DIGEST}"
echo "--> 推送最终的 latest 清单..."
docker manifest push "${IMAGE_NAME}:latest"
echo "==== [成功] ===="
echo "多架构镜像 ${IMAGE_NAME}:latest 已成功创建并推送！"
echo "您现在可以在任何 amd64 或 arm64 主机上通过 'docker pull ${IMAGE_NAME}:latest' 来拉取镜像了。"

