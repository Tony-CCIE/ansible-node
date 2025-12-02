FROM ubuntu:22.04

LABEL maintainer="James Cai <maintainer@example.com>"

ARG ANSIBLE_USER=ansible
ARG ANSIBLE_UID=1000
ENV DEBIAN_FRONTEND=noninteractive

# 安装必需包并清理缓存（把 update 与 install 合并以避免陈旧索引）
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    openssh-server python3 sudo curl wget bash-completion openssl ca-certificates netcat \
  && rm -rf /var/lib/apt/lists/*

# 创建 sshd 运行目录
RUN mkdir -p /var/run/sshd

# 创建非特权用户（默认 ansible），并把 sudo 配置放到 /etc/sudoers.d/
RUN useradd -m -u ${ANSIBLE_UID} -s /bin/bash ${ANSIBLE_USER} \
  && echo "${ANSIBLE_USER} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${ANSIBLE_USER} \
  && chmod 0440 /etc/sudoers.d/${ANSIBLE_USER}

# 默认禁止 root 密码登录（仍支持密钥登录）
RUN sed -i 's/^#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config || true

# 修正容器中 SSHD 的 PAM 行为（避免登录后被踢）
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

# 拷贝 entrypoint（运行时配置用户公钥等）
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 22

# 健康检测（检查本地 22 端口是否监听）
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD nc -z localhost 22 || exit 1

# 使用 entrypoint 启动 sshd（entrypoint 负责在容器启动时注入 authorized_keys、生成 host keys 等）
CMD ["/usr/local/bin/entrypoint.sh"]