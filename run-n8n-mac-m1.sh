#!/bin/bash

# n8n Docker 运行脚本 - 适用于 Mac M芯片
# 使用端口: 8967 (不常见端口)
# 作者: 自动生成脚本

set -e

# 配置变量
CONTAINER_NAME="n8n-workflow"
IMAGE_NAME="n8nio/n8n:latest"
HOST_PORT="8967"
CONTAINER_PORT="5678"
DATA_DIR="./n8n-data"
WEBHOOK_URL="http://localhost:${HOST_PORT}"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== n8n Docker 启动脚本 (Mac M芯片专用) ===${NC}"
echo -e "${YELLOW}端口: ${HOST_PORT}${NC}"
echo -e "${YELLOW}数据目录: ${DATA_DIR}${NC}"

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}错误: Docker 未运行或未安装${NC}"
    exit 1
fi

# 停止并删除现有容器
if docker ps -a --format 'table {{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo -e "${YELLOW}停止现有容器: ${CONTAINER_NAME}${NC}"
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
fi

# 创建数据目录
mkdir -p ${DATA_DIR}

# 设置权限 (Mac M芯片需要)
if [[ $(uname -m) == "arm64" ]]; then
    echo -e "${BLUE}检测到 ARM64 架构 (Mac M芯片)${NC}"
    # 确保数据目录权限正确
    chmod 755 ${DATA_DIR}
fi

echo -e "${BLUE}启动 n8n 容器...${NC}"

# 运行Docker容器
docker run -d \
    --name ${CONTAINER_NAME} \
    --platform linux/arm64 \
    -p ${HOST_PORT}:${CONTAINER_PORT} \
    -v ${PWD}/${DATA_DIR}:/home/node/.n8n \
    -e N8N_HOST=0.0.0.0 \
    -e N8N_PORT=${CONTAINER_PORT} \
    -e N8N_PROTOCOL=http \
    -e WEBHOOK_URL=${WEBHOOK_URL} \
    -e GENERIC_TIMEZONE=Asia/Shanghai \
    -e N8N_METRICS=true \
    -e N8N_DIAGNOSTICS_ENABLED=false \
    -e DB_TYPE=sqlite \
    -e DB_SQLITE_ENABLE_WAL=true \
    -e DB_SQLITE_VACUUM_ON_STARTUP=true \
    -e N8N_RUNNERS_ENABLED=true \
    -e N8N_RUNNERS_MODE=internal \
    -e N8N_LOG_LEVEL=info \
    -e N8N_LOG_OUTPUT=console \
    --restart unless-stopped \
    ${IMAGE_NAME}

# 等待容器启动
echo -e "${YELLOW}等待容器启动...${NC}"
sleep 5

# 检查容器状态
if docker ps --format 'table {{.Names}}\t{{.Status}}' | grep -q "^${CONTAINER_NAME}"; then
    echo -e "${GREEN}✅ n8n 容器启动成功!${NC}"
    echo -e "${GREEN}🌐 访问地址: http://localhost:${HOST_PORT}${NC}"
    echo -e "${GREEN}📁 数据目录: ${PWD}/${DATA_DIR}${NC}"
    echo ""
    echo -e "${BLUE}常用命令:${NC}"
    echo -e "  查看容器状态: ${YELLOW}docker ps${NC}"
    echo -e "  查看日志: ${YELLOW}docker logs ${CONTAINER_NAME}${NC}"
    echo -e "  停止容器: ${YELLOW}docker stop ${CONTAINER_NAME}${NC}"
    echo -e "  重启容器: ${YELLOW}docker restart ${CONTAINER_NAME}${NC}"
    echo ""
    echo -e "${BLUE}🔧 容器配置:${NC}"
    echo -e "  - 平台: linux/arm64 (Mac M芯片优化)"
    echo -e "  - 数据库: SQLite (适合单用户使用)"
    echo -e "  - 时区: Asia/Shanghai"
    echo -e "  - 自动重启: 是"
    echo -e "  - Task Runner: 启用"
else
    echo -e "${RED}❌ 容器启动失败${NC}"
    echo -e "${YELLOW}查看错误日志:${NC}"
    docker logs ${CONTAINER_NAME}
    exit 1
fi