# Ansible 实验室环境

这是一个完整的 Ansible 学习环境，包含 1 个 control 节点和 2 个 node 节点，所有节点均运行在 Docker 容器中。

## 快速开始

### 环境要求

Docker 和 Docker Compose
至少 4GB 可用内存
Ubuntu/Linux/macOS 系统（Windows 需要 WSL2）

### 一键部署

```bash
# 克隆或下载项目文件后
chmod +x setup-with-compose.sh
./setup-with-compose.sh
```

### 项目结构

```tex
ansible-lab/
├── docker-compose.yml          # 容器编排配置
├── setup-with-compose.sh       # 一键安装脚本（主要）
├── README.md                   # 本文档
├── ansible-files/              # Ansible 配置文件目录
│   ├── ansible.cfg             # Ansible 配置文件
│   ├── inventory.ini           # 主机清单文件
│   ├── *.yml                   # 各种 Playbook 示例
│   ├── *.j2                    # Jinja2 模板文件
├── scripts/                    # 辅助脚本目录
│   └── quick-test.sh           # 快速测试脚本
└── README.md                   # 说明文档
```

## 环境信息

### 容器信息

| 容器名  | 角色            | IP地址      | SSH端口 | 功能                      |
| :------ | :-------------- | :---------- | :------ | :------------------------ |
| control | Ansible控制节点 | 172.20.0.10 | 2222    | Ansible命令执行、配置管理 |
| node1   | 被管理节点1     | 172.20.0.11 | 2201    | Web服务器、应用部署       |
| node2   | 被管理节点2     | 172.20.0.12 | 2202    | Web服务器、应用部署       |

### 登录凭据

- **所有节点SSH用户名**: `root`
- **所有节点SSH密码**:  `password`

### 预装软件

- Ubuntu 22.04 基础系统
- OpenSSH Server (SSH服务)
- Python 3 (Ansible所需)
- Ansible (仅control节点)
- 常用工具: curl, wget, vim, net-tools等

## 使用方法

### 1. 启动环境

```bash
# 一键部署（推荐）
./setup-with-compose.sh

# 或手动启动
docker-compose up -d
```

### 2. 进入控制节点

```bash
# 方法1：使用Docker直接进入
docker exec -it control bash

# 方法2：使用SSH连接
ssh root@localhost -p 2222
# 密码：password
```

### 3. 验证环境

```bash
# 进入控制节点后
cd /root/ansible-files

# 测试Ansible连接
ansible all -m ping

# 查看所有节点信息
ansible all -m setup
```

###  4. 运行示例 playbook

```bash
# 1. 测试打印 python 语言版本
ansible-playbook test-playbook.yml
```

