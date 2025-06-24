# 🚀 n8n Docker 快速入门 - Mac M芯片专用

## 📁 文件说明

```
📦 n8n-docker-mac-m1/
├── 🎯 start-n8n.sh               # 交互式启动器 (推荐)
├── 🏃 run-n8n-mac-m1.sh          # 单容器部署脚本
├── 🏢 manage-n8n.sh              # 完整方案管理脚本
├── 📋 docker-compose-mac-m1.yml  # Docker Compose 配置
├── 🔧 .env.example               # 环境变量示例
├── 📖 README-Mac-M1-Docker.md    # 详细文档
└── 📝 QUICK-START.md            # 本文件
```

## ⚡ 快速开始

### 方法一：交互式启动器（推荐新手）
```bash
./start-n8n.sh
```
- 提供图形化菜单选择
- 自动检查系统要求
- 支持两种部署方案

### 方法二：直接运行简单方案
```bash
./run-n8n-mac-m1.sh
```
- 单容器 + SQLite
- 快速启动，适合个人使用

### 方法三：直接运行完整方案
```bash
./manage-n8n.sh start
```
- 多容器 + PostgreSQL + Redis
- 生产级别，支持高并发

## 🎯 访问地址

所有方案统一使用：**http://localhost:8967**

## 📊 方案对比

| 特性 | 简单方案 | 完整方案 |
|------|----------|----------|
| 启动命令 | `./run-n8n-mac-m1.sh` | `./manage-n8n.sh start` |
| 数据库 | SQLite | PostgreSQL |
| 缓存 | 无 | Redis |
| 扩展性 | 有限 | 高 |
| 适用场景 | 个人/测试 | 生产/团队 |

## 🛠️ 常用命令

### 简单方案
```bash
# 查看状态
docker ps

# 查看日志
docker logs n8n-workflow

# 停止服务
docker stop n8n-workflow

# 重启服务
docker restart n8n-workflow
```

### 完整方案
```bash
# 查看所有命令
./manage-n8n.sh help

# 启动服务
./manage-n8n.sh start

# 查看状态
./manage-n8n.sh status

# 查看日志
./manage-n8n.sh logs

# 备份数据
./manage-n8n.sh backup

# 停止服务
./manage-n8n.sh stop
```

## ⚙️ 自定义配置

1. **复制环境变量文件**：
   ```bash
   cp .env.example .env
   ```

2. **编辑配置**：
   ```bash
   nano .env
   ```

3. **重启服务使配置生效**

## 🔧 常见问题

### Q: 首次启动很慢？
A: 需要下载Docker镜像，请耐心等待3-5分钟

### Q: 端口8967被占用？
A: 修改脚本中的端口号，或在.env文件中设置

### Q: 数据存储在哪里？
A: 
- 简单方案：`./n8n-data/` 目录
- 完整方案：Docker卷 (持久化存储)

### Q: 如何备份数据？
A: 
- 简单方案：备份 `./n8n-data/` 目录
- 完整方案：使用 `./manage-n8n.sh backup`

## 🎨 特色功能

✅ **Mac M芯片优化** - 专为ARM64架构设计  
✅ **不常见端口** - 使用8967端口避免冲突  
✅ **一键启动** - 简单命令即可运行  
✅ **数据持久化** - 重启不丢失数据  
✅ **自动备份** - 完整方案支持数据备份  
✅ **健康检查** - 自动监控服务状态  
✅ **中文支持** - 全中文界面和文档  

## 🚨 注意事项

- 确保Docker Desktop已启动
- 首次运行会下载镜像，需要网络连接
- 生产环境请修改默认密码
- 建议定期备份重要数据

## 📚 更多帮助

- 详细文档：`README-Mac-M1-Docker.md`
- 环境变量：`.env.example`
- 在线帮助：`./manage-n8n.sh help`

---

**快速体验**：直接运行 `./start-n8n.sh` 开始您的n8n之旅！ 🎉