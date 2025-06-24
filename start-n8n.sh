#!/bin/bash

# n8n 启动选择器 - Mac M芯片专用
# 提供简单和完整两种部署方案选择

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示欢迎信息
show_welcome() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║                                                          ║${NC}"
    echo -e "${BLUE}║         🚀 n8n Docker 启动器 - Mac M芯片专用            ║${NC}"
    echo -e "${BLUE}║                                                          ║${NC}"
    echo -e "${BLUE}║         使用端口: ${GREEN}8967${BLUE}                                 ║${NC}"
    echo -e "${BLUE}║         访问地址: ${GREEN}http://localhost:8967${BLUE}               ║${NC}"
    echo -e "${BLUE}║                                                          ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 检查系统要求
check_system() {
    echo -e "${CYAN}正在检查系统要求...${NC}"
    
    # 检查架构
    if [[ $(uname -m) != "arm64" ]]; then
        echo -e "${YELLOW}⚠️  警告: 未检测到ARM64架构，但脚本将继续运行${NC}"
    else
        echo -e "${GREEN}✅ ARM64架构 (Mac M芯片)${NC}"
    fi
    
    # 检查Docker
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}❌ Docker 未安装${NC}"
        echo -e "${YELLOW}请先安装 Docker Desktop for Mac${NC}"
        exit 1
    fi
    
    if ! docker info > /dev/null 2>&1; then
        echo -e "${RED}❌ Docker 未运行${NC}"
        echo -e "${YELLOW}请先启动 Docker Desktop${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker 运行正常${NC}"
    
    # 检查Docker Compose
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${YELLOW}⚠️  Docker Compose 未找到，但可能仍能使用内置版本${NC}"
    else
        echo -e "${GREEN}✅ Docker Compose 可用${NC}"
    fi
    
    echo ""
    sleep 2
}

# 显示部署方案对比
show_comparison() {
    echo -e "${BLUE}=== 📚 部署方案对比 ===${NC}"
    echo ""
    printf "%-20s %-20s %-20s\n" "特性" "简单方案" "完整方案"
    echo -e "${CYAN}$(printf '%-60s' | tr ' ' '─')${NC}"
    printf "%-20s %-20s %-20s\n" "数据库" "SQLite" "PostgreSQL"
    printf "%-20s %-20s %-20s\n" "缓存" "无" "Redis"
    printf "%-20s %-20s %-20s\n" "Worker支持" "无" "支持"
    printf "%-20s %-20s %-20s\n" "队列模式" "无" "支持"
    printf "%-20s %-20s %-20s\n" "扩展性" "有限" "高"
    printf "%-20s %-20s %-20s\n" "资源占用" "低" "中等"
    printf "%-20s %-20s %-20s\n" "适用场景" "个人/测试" "生产/团队"
    printf "%-20s %-20s %-20s\n" "启动时间" "快" "稍慢"
    echo ""
}

# 选择部署方案
choose_deployment() {
    while true; do
        echo -e "${YELLOW}请选择部署方案:${NC}"
        echo ""
        echo -e "  ${GREEN}1)${NC} 🏃 简单方案 - 单容器 + SQLite"
        echo -e "     ${CYAN}• 快速启动，适合个人使用和测试${NC}"
        echo -e "     ${CYAN}• 资源占用少，配置简单${NC}"
        echo ""
        echo -e "  ${GREEN}2)${NC} 🏢 完整方案 - 多容器 + PostgreSQL + Redis"
        echo -e "     ${CYAN}• 生产级别，支持高并发和队列${NC}"
        echo -e "     ${CYAN}• 支持Worker扩展和数据备份${NC}"
        echo ""
        echo -e "  ${GREEN}3)${NC} 📖 查看详细文档"
        echo ""
        echo -e "  ${GREEN}0)${NC} 退出"
        echo ""
        
        read -p "$(echo -e ${CYAN}请输入选择 [1-3,0]: ${NC})" choice
        
        case $choice in
            1)
                deploy_simple
                break
                ;;
            2)
                deploy_full
                break
                ;;
            3)
                show_documentation
                ;;
            0)
                echo -e "${YELLOW}再见! 👋${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}❌ 无效选择，请输入 1、2、3 或 0${NC}"
                echo ""
                ;;
        esac
    done
}

# 简单部署
deploy_simple() {
    echo ""
    echo -e "${BLUE}=== 🏃 启动简单方案 ===${NC}"
    echo -e "${CYAN}正在使用单容器 + SQLite 模式...${NC}"
    echo ""
    
    if [ ! -f "run-n8n-mac-m1.sh" ]; then
        echo -e "${RED}❌ 找不到 run-n8n-mac-m1.sh 脚本${NC}"
        exit 1
    fi
    
    chmod +x run-n8n-mac-m1.sh
    ./run-n8n-mac-m1.sh
    
    show_success_simple
}

# 完整部署
deploy_full() {
    echo ""
    echo -e "${BLUE}=== 🏢 启动完整方案 ===${NC}"
    echo -e "${CYAN}正在使用多容器 + PostgreSQL + Redis 模式...${NC}"
    echo ""
    
    if [ ! -f "manage-n8n.sh" ]; then
        echo -e "${RED}❌ 找不到 manage-n8n.sh 脚本${NC}"
        exit 1
    fi
    
    if [ ! -f "docker-compose-mac-m1.yml" ]; then
        echo -e "${RED}❌ 找不到 docker-compose-mac-m1.yml 配置文件${NC}"
        exit 1
    fi
    
    chmod +x manage-n8n.sh
    ./manage-n8n.sh start
    
    show_success_full
}

# 显示成功信息 - 简单方案
show_success_simple() {
    echo ""
    echo -e "${GREEN}🎉 简单方案启动成功!${NC}"
    echo ""
    echo -e "${BLUE}📌 访问信息:${NC}"
    echo -e "  🌐 Web界面: ${GREEN}http://localhost:8967${NC}"
    echo -e "  📂 数据目录: ${CYAN}./n8n-data${NC}"
    echo -e "  🗄️  数据库: ${CYAN}SQLite (内置)${NC}"
    echo ""
    echo -e "${BLUE}💡 常用命令:${NC}"
    echo -e "  查看状态: ${YELLOW}docker ps${NC}"
    echo -e "  查看日志: ${YELLOW}docker logs n8n-workflow${NC}"
    echo -e "  停止服务: ${YELLOW}docker stop n8n-workflow${NC}"
    echo -e "  重启服务: ${YELLOW}docker restart n8n-workflow${NC}"
    echo ""
}

# 显示成功信息 - 完整方案
show_success_full() {
    echo ""
    echo -e "${GREEN}🎉 完整方案启动成功!${NC}"
    echo ""
    echo -e "${BLUE}📌 访问信息:${NC}"
    echo -e "  🌐 Web界面: ${GREEN}http://localhost:8967${NC}"
    echo -e "  🗄️  数据库: ${CYAN}PostgreSQL${NC}"
    echo -e "  🔄 缓存: ${CYAN}Redis${NC}"
    echo -e "  👷 Worker: ${CYAN}已启用${NC}"
    echo ""
    echo -e "${BLUE}💡 管理命令:${NC}"
    echo -e "  查看状态: ${YELLOW}./manage-n8n.sh status${NC}"
    echo -e "  查看日志: ${YELLOW}./manage-n8n.sh logs${NC}"
    echo -e "  备份数据: ${YELLOW}./manage-n8n.sh backup${NC}"
    echo -e "  停止服务: ${YELLOW}./manage-n8n.sh stop${NC}"
    echo -e "  获取帮助: ${YELLOW}./manage-n8n.sh help${NC}"
    echo ""
}

# 显示文档
show_documentation() {
    echo ""
    echo -e "${BLUE}=== 📖 文档和资源 ===${NC}"
    echo ""
    echo -e "${CYAN}📄 本地文档:${NC}"
    echo -e "  • README-Mac-M1-Docker.md - 完整使用指南"
    echo ""
    echo -e "${CYAN}🌐 在线资源:${NC}"
    echo -e "  • n8n官方文档: https://docs.n8n.io/"
    echo -e "  • Docker官方文档: https://docs.docker.com/"
    echo -e "  • n8n社区论坛: https://community.n8n.io/"
    echo ""
    echo -e "${CYAN}💡 快速提示:${NC}"
    echo -e "  • 首次启动可能需要3-5分钟下载镜像"
    echo -e "  • 如果8967端口被占用，可修改脚本中的端口设置"
    echo -e "  • 建议定期备份数据（完整方案支持自动备份）"
    echo ""
    
    read -p "$(echo -e ${YELLOW}按回车键返回主菜单...${NC})" 
    echo ""
}

# 主函数
main() {
    show_welcome
    check_system
    show_comparison
    choose_deployment
}

# 运行主函数
main "$@"