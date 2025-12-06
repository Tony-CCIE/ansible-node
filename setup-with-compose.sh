#!/bin/bash

echo "=== 启动容器 ==="
docker-compose up -d

echo "=== 等待容器启动 ==="
sleep 3

# 在所有容器中安装必要软件的函数
install_packages() {
    local container=$1
    echo "在 $container 中安装软件..."
    
    # 安装基础软件
    docker exec $container apt-get update
    docker exec $container apt-get install -y \
        openssh-server \
        sudo \
        python3 \
        python3-pip \
        vim \
        curl \
        net-tools \
        iputils-ping
    
    # 创建 SSH 目录
    docker exec $container mkdir -p /var/run/sshd
    
    # 设置 root 密码
    docker exec $container bash -c "echo 'root:password' | chpasswd"
    
    # 允许 root SSH 登录
    docker exec $container sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    docker exec $container sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
    
    # 启动 SSH 服务
    docker exec $container service ssh start
    
    # 安装 Python3（如果还没装）
    docker exec $container apt-get install -y python3 python3-apt
}

# 安装软件到所有容器
install_packages node1
install_packages node2
install_packages control

# 在 control 节点安装 Ansible
echo "在 control 节点安装 Ansible..."
docker exec control apt-get install -y ansible sshpass

# 生成 SSH 密钥
echo "生成 SSH 密钥..."
docker exec control bash -c "ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''"

# 复制 SSH 公钥到所有节点
for node in node1 node2; do
    echo "复制 SSH 公钥到 $node..."
    docker exec control bash -c "ssh-keyscan -H $node >> /root/.ssh/known_hosts"
    docker exec $node bash -c "mkdir -p /root/.ssh"
    docker exec control bash -c "sshpass -p 'password' ssh-copy-id root@$node"
done

