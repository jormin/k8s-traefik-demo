#!/bin/bash

# 设置主机名
echo "1. 设置hostname"
currentHostname=$(hostname)
echo "当前hostname：$currentHostname"
read -p "请输入hostname(直接回车不修改)：" hostname
if [ -z "${hostname}" ];then
    hostname=$currentHostname
fi
hostnamectl set-hostname $hostname
echo ""

# 设置sshd
echo "2. 设置sshd"
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa
sed -i -e 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' -e 's/PasswordAuthentication yes/PasswordAuthentication no/' -e 's/#ClientAliveInterval 0/ClientAliveInterval 60/' -e 's/#ClientAliveCountMax 3/ClientAliveCountMax 30/' /etc/ssh/sshd_config
service sshd restart
read -p "请输入免密登录公钥：" pubkey
cat > ~/.ssh/authorized_keys <<EOF
$pubkey
EOF
echo ""

echo "3. 设置时区为 Asia/Shanghai"
sudo timedatectl set-timezone Asia/Shanghai
echo ""

echo "4. 切换阿里源"
sudo cp -ra /etc/apt/sources.list /etc/apt/sources.list.bak
sudo sed -i -e 's#http://cn.archive.ubuntu.com/ubuntu#http://mirrors.aliyun.com/ubuntu#' -e 's#http://mirrors.tencentyun.com/ubuntu#http://mirrors.aliyun.com/ubuntu#' /etc/apt/sources.list
sudo apt-get update
sudo apt-get upgrade
echo ""

echo "5. 关闭防火墙和Selinux"
sudo ufw disable
sudo ufw status
sudo apt install -y policycoreutils
sudo sestatus -v
echo ""

echo "6. 关闭swap"
swapoff -a
echo ""

echo "7. 设置 alias"
echo "alias ll=\"ls -la\"" >> ~/.bash_profile
source ~/.bash_profile
echo ""

echo "8. 安装 docker"
sudo apt-get remove docker docker-engine docker.io containerd runc
sudo apt-get update
sudo apt-get install -y \
    net-tools \
    unzip \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    conntrack
sudo curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
mkdir /etc/docker
sudo cat > /etc/docker/daemon.json <<EOF
{
    "exec-opts": ["native.cgroupdriver=systemd"],
    "log-driver": "json-file",
    "log-opts": {
    "max-size": "100m"
    },
    "storage-driver": "overlay2",
    "registry-mirrors":[
        "https://mirror.ccs.tencentyun.com",
        "https://docker.mirrors.ustc.edu.cn",
        "https://registry.docker-cn.com"
    ]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl enable docker
echo ""

echo "9. 安装 docker compose"
sudo curl -L "http://download.lerzen.com/docker-compose-Linux-x86_64" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
echo ""

echo "10. 处理dns"
sed -i 's/#DNS=/DNS=114.114.114.114/' /etc/systemd/resolved.conf
service systemd-resolved restart
systemctl enable systemd-resolved
mv /etc/resolv.conf /etc/resolv.conf.bak
ln -s /run/systemd/resolve/resolv.conf /etc/
echo ""

echo "11. 安装kubernetes和kubesphere"
export KKZONE=cn
curl -sfL https://get-kk.kubesphere.io | VERSION=v1.2.0 sh -
chmod +x kk
./kk create cluster --with-kubernetes v1.21.5 --with-kubesphere v3.2.0
echo ""