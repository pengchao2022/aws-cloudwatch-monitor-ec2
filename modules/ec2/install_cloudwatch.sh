#!/bin/bash
set -e

# 添加 AWS CloudWatch 官方仓库
apt-get update
apt-get install -y wget gnupg

# 添加 AWS 签名密钥
wget -q -O- https://aws-cloudwatch.s3.amazonaws.com/aws-cloudwatch.gpg | \
    gpg --dearmor -o /usr/share/keyrings/aws-cloudwatch.gpg

# 添加仓库源
echo "deb [signed-by=/usr/share/keyrings/aws-cloudwatch.gpg] https://aws-cloudwatch.s3.amazonaws.com/ stable main" | \
    tee /etc/apt/sources.list.d/aws-cloudwatch.list

# 更新并安装
apt-get update
apt-get install -y amazon-cloudwatch-agent

# 创建配置目录和文件
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

cat << 'EOF' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# 启动代理
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

echo "CloudWatch Agent installation completed"