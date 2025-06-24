#!/bin/bash

# n8n Docker Compose 管理脚本 - Mac M芯片专用
# 提供完整的 n8n 服务管理功能

set -e

# 配置变量
COMPOSE_FILE="docker-compose-mac-m1.yml"
PROJECT_NAME="n8n-mac-m1"
HOST_PORT="8967"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示帮助信息
show_help() {
    echo -e "${BLUE}=== n8n Docker Compose 管理脚本 (Mac M芯片) ===${NC}"
    echo -e "${CYAN}使用方法: $0 [命令]${NC}"
    echo ""
    echo -e "${YELLOW}可用命令:${NC}"
    echo -e "  ${GREEN}start${NC}     启动所有服务"
    echo -e "  ${GREEN}stop${NC}      停止所有服务"
    echo -e "  ${GREEN}restart${NC}   重启所有服务"
    echo -e "  ${GREEN}status${NC}    查看服务状态"
    echo -e "  ${GREEN}logs${NC}      查看实时日志"
    echo -e "  ${GREEN}logs-n8n${NC}  只查看 n8n 日志"
    echo -e "  ${GREEN}backup${NC}    备份数据库"
    echo -e "  ${GREEN}restore${NC}   恢复数据库 (需要备份文件)"
    echo -e "  ${GREEN}update${NC}    更新到最新版本"
    echo -e "  ${GREEN}clean${NC}     清理未使用的数据"
    echo -e "  ${GREEN}shell${NC}     进入 n8n 容器 shell"
    echo -e "  ${GREEN}psql${NC}      连接 PostgreSQL 数据库"
    echo -e "  ${GREEN}redis${NC}     连接 Redis"
    echo -e "  ${GREEN}info${NC}      显示系统信息"
    echo -e "  ${GREEN}help${NC}      显示此帮助信息"
    echo ""
    echo -e "${BLUE}访问地址: ${GREEN}http://localhost:${HOST_PORT}${NC}"
}

# 检查 Docker 和 Docker Compose
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker 未安装${NC}"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}错误: Docker 未运行${NC}"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}错误: Docker Compose 未安装${NC}"
        exit 1
    fi
}

# Docker Compose 命令封装
dc() {
    if command -v docker-compose &> /dev/null; then
        docker-compose -f "${COMPOSE_FILE}" -p "${PROJECT_NAME}" "$@"
    else
        docker compose -f "${COMPOSE_FILE}" -p "${PROJECT_NAME}" "$@"
    fi
}

# 启动服务
start_services() {
    echo -e "${BLUE}启动 n8n 服务...${NC}"
    
    # 创建必要的目录
    mkdir -p backups custom-nodes workflows
    
    # 启动服务
    dc up -d
    
    echo -e "${YELLOW}等待服务启动...${NC}"
    sleep 10
    
    # 检查服务状态
    if dc ps | grep -q "Up"; then
        echo -e "${GREEN}✅ 服务启动成功!${NC}"
        echo -e "${GREEN}🌐 访问地址: http://localhost:${HOST_PORT}${NC}"
        echo -e "${CYAN}💡 首次启动可能需要几分钟来初始化数据库${NC}"
    else
        echo -e "${RED}❌ 服务启动失败${NC}"
        dc logs
    fi
}

# 停止服务
stop_services() {
    echo -e "${YELLOW}停止 n8n 服务...${NC}"
    dc down
    echo -e "${GREEN}✅ 服务已停止${NC}"
}

# 重启服务
restart_services() {
    echo -e "${YELLOW}重启 n8n 服务...${NC}"
    dc restart
    echo -e "${GREEN}✅ 服务已重启${NC}"
}

# 查看服务状态
show_status() {
    echo -e "${BLUE}=== 服务状态 ===${NC}"
    dc ps
    echo ""
    echo -e "${BLUE}=== 容器资源使用情况 ===${NC}"
    docker stats --no-stream $(dc ps -q) 2>/dev/null || echo "没有运行的容器"
}

# 查看日志
show_logs() {
    if [ "$1" = "n8n" ]; then
        echo -e "${BLUE}=== n8n 服务日志 ===${NC}"
        dc logs -f n8n
    else
        echo -e "${BLUE}=== 所有服务日志 ===${NC}"
        dc logs -f
    fi
}

# 备份数据库
backup_database() {
    echo -e "${BLUE}备份 PostgreSQL 数据库...${NC}"
    
    BACKUP_FILE="backups/n8n_backup_$(date +%Y%m%d_%H%M%S).sql"
    
    dc exec -T postgres pg_dump -U n8n_user -d n8n > "${BACKUP_FILE}"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ 数据库备份成功: ${BACKUP_FILE}${NC}"
    else
        echo -e "${RED}❌ 数据库备份失败${NC}"
    fi
}

# 恢复数据库
restore_database() {
    echo -e "${YELLOW}可用的备份文件:${NC}"
    ls -la backups/*.sql 2>/dev/null || {
        echo -e "${RED}没有找到备份文件${NC}"
        return 1
    }
    
    echo -e "${CYAN}请输入要恢复的备份文件名:${NC}"
    read -r backup_file
    
    if [ ! -f "$backup_file" ]; then
        echo -e "${RED}备份文件不存在: $backup_file${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}警告: 这将覆盖当前数据库! 确认继续? (y/N)${NC}"
    read -r confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo -e "${BLUE}恢复数据库...${NC}"
        dc exec -T postgres psql -U n8n_user -d n8n < "$backup_file"
        echo -e "${GREEN}✅ 数据库恢复完成${NC}"
    else
        echo -e "${YELLOW}操作已取消${NC}"
    fi
}

# 更新到最新版本
update_services() {
    echo -e "${BLUE}更新 n8n 到最新版本...${NC}"
    
    # 先备份
    backup_database
    
    # 拉取最新镜像
    dc pull
    
    # 重启服务
    dc up -d
    
    echo -e "${GREEN}✅ 更新完成${NC}"
}

# 清理数据
clean_data() {
    echo -e "${YELLOW}这将删除未使用的 Docker 镜像和卷${NC}"
    echo -e "${RED}确认继续? (y/N)${NC}"
    read -r confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        docker system prune -f
        echo -e "${GREEN}✅ 清理完成${NC}"
    else
        echo -e "${YELLOW}操作已取消${NC}"
    fi
}

# 进入容器 shell
enter_shell() {
    echo -e "${BLUE}进入 n8n 容器...${NC}"
    dc exec n8n /bin/sh
}

# 连接 PostgreSQL
connect_psql() {
    echo -e "${BLUE}连接 PostgreSQL...${NC}"
    dc exec postgres psql -U n8n_user -d n8n
}

# 连接 Redis
connect_redis() {
    echo -e "${BLUE}连接 Redis...${NC}"
    dc exec redis redis-cli -a redis_secure_password_2024
}

# 显示系统信息
show_info() {
    echo -e "${BLUE}=== 系统信息 ===${NC}"
    echo -e "${CYAN}架构:${NC} $(uname -m)"
    echo -e "${CYAN}操作系统:${NC} $(uname -s)"
    echo -e "${CYAN}Docker 版本:${NC} $(docker --version)"
    
    if command -v docker-compose &> /dev/null; then
        echo -e "${CYAN}Docker Compose 版本:${NC} $(docker-compose --version)"
    else
        echo -e "${CYAN}Docker Compose 版本:${NC} $(docker compose version)"
    fi
    
    echo ""
    echo -e "${BLUE}=== n8n 配置信息 ===${NC}"
    echo -e "${CYAN}访问端口:${NC} ${HOST_PORT}"
    echo -e "${CYAN}项目名称:${NC} ${PROJECT_NAME}"
    echo -e "${CYAN}配置文件:${NC} ${COMPOSE_FILE}"
    echo -e "${CYAN}数据库:${NC} PostgreSQL"
    echo -e "${CYAN}缓存:${NC} Redis"
    echo -e "${CYAN}平台:${NC} linux/arm64"
}

# 主函数
main() {
    case "${1:-help}" in
        start)
            check_dependencies
            start_services
            ;;
        stop)
            check_dependencies
            stop_services
            ;;
        restart)
            check_dependencies
            restart_services
            ;;
        status)
            check_dependencies
            show_status
            ;;
        logs)
            check_dependencies
            show_logs
            ;;
        logs-n8n)
            check_dependencies
            show_logs n8n
            ;;
        backup)
            check_dependencies
            backup_database
            ;;
        restore)
            check_dependencies
            restore_database
            ;;
        update)
            check_dependencies
            update_services
            ;;
        clean)
            check_dependencies
            clean_data
            ;;
        shell)
            check_dependencies
            enter_shell
            ;;
        psql)
            check_dependencies
            connect_psql
            ;;
        redis)
            check_dependencies
            connect_redis
            ;;
        info)
            show_info
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}未知命令: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"