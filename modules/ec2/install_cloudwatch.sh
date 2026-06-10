#!/bin/bash
# 更新并安装代理
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

# 启动代理并配置为开机自启
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json