# ChefServer作成
chefserver=`aws ec2 run-instances \
--region ap-southeast-1 \
--image-id ami-2c95344f \
--instance-type t2.large \
--subnet-id subnet-8d0f76e8 \
--security-group-ids sg-5217c436 \
--key-name chef-server \
--user-data file://~/work/chef-training/chef-server-data.sh \
--output text \
--query "Instances[].InstanceId[]"`
echo "chefserver instanceid = ${chefserver}"

# workstation作成
workstation=`aws ec2 run-instances \
--region ap-southeast-1 \
--image-id ami-b6b267d5 \
--instance-type t2.large \
--subnet-id subnet-8d0f76e8 \
--security-group-ids sg-b11c7ad5 \
--key-name workstation \
--user-data file://~/work/chef-training/workstation-data.sh \
--output text \
--query "Instances[].InstanceId[]"`
echo "workstation instanceid = ${workstation}"

# node作成
node=`aws ec2 run-instances \
--region ap-southeast-1 \
--image-id ami-b6b267d5 \
--instance-type t2.micro \
--subnet-id subnet-8d0f76e8 \
--security-group-ids sg-3b32e15f \
--key-name node \
--user-data file://workstation-data.sh \
--output text \
--query "Instances[].InstanceId[]"`
echo "node instanceid = ${workstation}"

# タグ付け
aws ec2 create-tags \
--region ap-southeast-1 \
--resources ${chefserver} \
--tags Key=Name,Value=ChefServer

aws ec2 create-tags \
--region ap-southeast-1 \
--resources ${workstation} \
--tags Key=Name,Value=Workstation

aws ec2 create-tags \
--region ap-southeast-1 \
--resources ${node} \
--tags Key=Name,Value=TestNode

# IPアドレスの取得
chefserverip=`aws ec2 describe-instances \
--region ap-southeast-1 \
--output text \
--query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" \
--instance-ids ${chefserver}`
echo "ChefServerIp = ${chefserverip}"

workstationip=`aws ec2 describe-instances \
--region ap-southeast-1 \
--output text \
--query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" \
--instance-ids ${workstation}`
echo "WorkstationIp = ${workstationip}"

nodeip=`aws ec2 describe-instances \
--region ap-southeast-1 \
--output text \
--query "Reservations[].Instances[].NetworkInterfaces[].Association[].PublicIp" \
--instance-ids ${node}`
echo "NodeIp = ${nodeip}"

# ChefServer publicDNSの取得
chefserverdns=`aws ec2 describe-instances \
--region ap-southeast-1 \
--query "Reservations[].Instances[].PublicDnsName[]" \
--output text \
--instance-ids ${chefserver}`
echo "ChefServerDns = ${chefserverdns}"

# workstationが起動するのを待つ
while :
do
  check=`aws ec2 describe-instance-status --region ap-southeast-1 --query "InstanceStatuses[].InstanceStatus[].Status[]" --output text --instance-id ${workstation}`
  [ "$check" = "ok" ] && break || echo "workstation waiting"; sleep 10
done

# workstationに必要なファイルを配置

scp -o "StrictHostKeyChecking=no" -i ~/.ssh/workstation.pem ~/.ssh/node.pem centos@${workstationip}:~/.ssh/node.pem
echo "https://${chefserverdns}" > ./chef-server-url
scp -o "StrictHostKeyChecking=no" -i ~/.ssh/workstation.pem ./chef-server-url centos@${workstationip}:~/chef/chef-server-url
