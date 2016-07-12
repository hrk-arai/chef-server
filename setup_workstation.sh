#!/bin/bash

mkdir -p /etc/chef/packages
curl -sL https://packages.chef.io/stable/el/6/chefdk-0.14.25-1.el6.x86_64.rpm > /etc/chef/packages/chefdk-0.14.25-1.el6.x86_64.rpm
rpm -i /etc/chef/packages/chefdk-0.14.25-1.el6.x86_64.rpm
su -c "mkdir /home/centos/chef" centos
yum install -y unzip tree git
