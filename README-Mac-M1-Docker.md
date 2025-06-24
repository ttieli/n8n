# n8n Docker 部署指南 - Mac M芯片专用

本指南提供了在Mac M芯片（Apple Silicon）上运行n8n的完整Docker解决方案，使用不常见端口**8967**以避免端口冲突。

## 📋 目录

- [前置要求](#前置要求)
- [快速开始](#快速开始)
- [部署方案](#部署方案)
- [详细使用指南](#详细使用指南)
- [配置说明](#配置说明)
- [常见问题](#常见问题)
- [维护操作](#维护操作)
- [安全建议](#安全建议)

## 🔧 前置要求

### 系统要求
- macOS 11.0+ (Big Sur)
- Apple Silicon (M1/M2/M3) 芯片
- 至少 4GB 可用内存
- 至少 10GB 可用磁盘空间

### 软件要求
- [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) (推荐最新版本)
- Docker Compose (通常包含在Docker Desktop中)

### 验证安装
```bash
# 检查Docker版本
docker --version

# 检查Docker Compose版本
docker compose version

# 检查系统架构
uname -m  # 应显示 arm64
```

## 🚀 快速开始

### 方案一：简单单容器部署（推荐新手）

1. **下载并运行单容器脚本**：
   ```bash
   # 添加执行权限
   chmod +x run-n8n-mac-m1.sh
   
   # 启动n8n
   ./run-n8n-mac-m1.sh
   ```

2. **访问n8n**：
   打开浏览器访问 `http://localhost:8967`

### 方案二：完整生产环境部署（推荐生产使用）

1. **使用管理脚本启动**：
   ```bash
   # 添加执行权限
   chmod +x manage-n8n.sh
   
   # 启动完整服务栈
   ./manage-n8n.sh start
   ```

2. **访问n8n**：
   打开浏览器访问 `http://localhost:8967`

## 📚 部署方案

### 方案对比

| 特性 | 单容器方案 | 完整方案 |
|------|------------|----------|
| 数据库 | SQLite | PostgreSQL |
| 缓存 | 无 | Redis |
| 扩展性 | 有限 | 高 |
| 资源占用 | 低 | 中等 |
| 适用场景 | 个人使用/测试 | 生产环境/团队使用 |
| Worker支持 | 无 | 支持 |
| 队列模式 | 无 | 支持 |

### 文件说明

```
.
├── run-n8n-mac-m1.sh           # 单容器启动脚本
├── docker-compose-mac-m1.yml   # 完整Docker Compose配置
├── manage-n8n.sh               # 服务管理脚本
├── README-Mac-M1-Docker.md     # 本文档
├── n8n-data/                   # n8n数据目录（自动创建）
├── backups/                    # 数据库备份目录（自动创建）
├── custom-nodes/               # 自定义节点目录（自动创建）
└── workflows/                  # 工作流备份目录（自动创建）
```

## 📖 详细使用指南

### 单容器方案使用

```bash
# 启动服务
./run-n8n-mac-m1.sh

# 查看容器状态
docker ps

# 查看日志
docker logs n8n-workflow

# 停止服务
docker stop n8n-workflow

# 重启服务
docker restart n8n-workflow
```

### 完整方案使用

管理脚本提供了丰富的命令：

```bash
# 查看所有可用命令
./manage-n8n.sh help

# 启动所有服务
./manage-n8n.sh start

# 查看服务状态
./manage-n8n.sh status

# 查看实时日志
./manage-n8n.sh logs

# 只查看n8n日志
./manage-n8n.sh logs-n8n

# 备份数据库
./manage-n8n.sh backup

# 更新到最新版本
./manage-n8n.sh update

# 停止所有服务
./manage-n8n.sh stop
```

### 高级操作

```bash
# 进入n8n容器shell
./manage-n8n.sh shell

# 连接PostgreSQL数据库
./manage-n8n.sh psql

# 连接Redis
./manage-n8n.sh redis

# 显示系统信息
./manage-n8n.sh info
```

## ⚙️ 配置说明

### 端口配置
- **主端口**: 8967 (n8n Web界面)
- **内部端口**: 5678 (容器内部)

### 环境变量配置

主要环境变量可在相应配置文件中修改：

```yaml
# 基础配置
N8N_HOST: 0.0.0.0
N8N_PORT: 5678
N8N_PROTOCOL: http
WEBHOOK_URL: http://localhost:8967
GENERIC_TIMEZONE: Asia/Shanghai

# 数据库配置（完整方案）
DB_TYPE: postgresdb
DB_POSTGRESDB_HOST: postgres
DB_POSTGRESDB_DATABASE: n8n
DB_POSTGRESDB_USER: n8n_user
DB_POSTGRESDB_PASSWORD: n8n_secure_password_2024

# 性能配置
N8N_CONCURRENCY_PRODUCTION_LIMIT: 10
EXECUTIONS_DATA_MAX_AGE: 168  # 7天
```

### 数据持久化

- **单容器方案**: 数据存储在 `./n8n-data` 目录
- **完整方案**: 使用Docker卷持久化数据
  - PostgreSQL 数据
  - Redis 数据
  - n8n 配置和工作流

## 🔍 常见问题

### Q: 首次启动很慢怎么办？
A: 首次启动需要下载镜像和初始化数据库，请耐心等待3-5分钟。

### Q: 8967端口被占用怎么办？
A: 修改脚本中的`HOST_PORT`变量为其他端口，如8968、9234等。

### Q: 如何更改时区？
A: 修改环境变量`GENERIC_TIMEZONE`，如改为`America/New_York`。

### Q: 如何添加自定义节点？
A: 将节点文件放入`custom-nodes`目录，重启服务即可。

### Q: 数据如何备份？
A: 使用 `./manage-n8n.sh backup` 命令自动备份PostgreSQL数据库。

### Q: 如何恢复数据？
A: 使用 `./manage-n8n.sh restore` 命令从备份文件恢复。

### Q: 服务无法启动怎么办？
A: 检查Docker是否运行，查看日志：`./manage-n8n.sh logs`

### Q: 如何升级n8n版本？
A: 使用 `./manage-n8n.sh update` 命令自动升级到最新版本。

## 🛠️ 维护操作

### 定期维护任务

1. **数据备份**（建议每周）：
   ```bash
   ./manage-n8n.sh backup
   ```

2. **日志清理**（建议每月）：
   ```bash
   docker system prune -f
   ```

3. **版本更新**（建议每月检查）：
   ```bash
   ./manage-n8n.sh update
   ```

### 监控和调试

```bash
# 查看资源使用情况
./manage-n8n.sh status

# 实时查看日志
./manage-n8n.sh logs

# 检查容器健康状态
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 性能优化

1. **调整并发限制**：
   - 修改 `N8N_CONCURRENCY_PRODUCTION_LIMIT` 环境变量
   - 根据Mac性能调整，建议M1/M2为10-20

2. **数据清理**：
   - 设置 `EXECUTIONS_DATA_MAX_AGE` 自动清理旧执行记录
   - 定期清理不需要的工作流

3. **内存优化**：
   - 监控Docker Desktop内存使用
   - 必要时调整Docker内存限制

## 🔒 安全建议

### 生产环境安全配置

1. **更改默认密码**：
   ```yaml
   # 在docker-compose-mac-m1.yml中修改
   POSTGRES_PASSWORD: your_secure_password
   QUEUE_BULL_REDIS_PASSWORD: your_redis_password
   ```

2. **启用HTTPS**（生产环境）：
   ```yaml
   N8N_PROTOCOL: https
   N8N_SECURE_COOKIE: true
   ```

3. **限制网络访问**：
   - 仅在必要时开放端口
   - 使用防火墙限制访问

4. **定期备份**：
   - 设置自动备份任务
   - 将备份存储在安全位置

### 网络安全

- 使用强密码
- 定期更新n8n版本  
- 监控访问日志
- 限制管理员权限

## 📞 支持和帮助

### 获取帮助

1. **查看脚本帮助**：
   ```bash
   ./manage-n8n.sh help
   ```

2. **查看官方文档**：
   - [n8n官方文档](https://docs.n8n.io/)
   - [Docker官方文档](https://docs.docker.com/)

3. **社区支持**：
   - [n8n社区论坛](https://community.n8n.io/)
   - [GitHub Issues](https://github.com/n8n-io/n8n/issues)

### 日志收集

如需技术支持，请提供以下信息：

```bash
# 系统信息
./manage-n8n.sh info

# 服务状态
./manage-n8n.sh status

# 错误日志
./manage-n8n.sh logs > n8n-logs.txt
```

## 📝 更新日志

- **v1.0.0** - 初始版本，支持Mac M芯片
- 使用端口8967避免冲突
- 支持单容器和完整部署方案
- 提供完整的管理脚本
- 针对ARM64架构优化

---

**注意**: 本指南专为Mac M芯片设计，确保Docker Desktop已正确配置ARM64支持。如有问题，请检查Docker设置中的"Use Rosetta for x86/amd64 emulation"选项。