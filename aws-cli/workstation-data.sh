#!/bin/bash

curl -sL https://github.com/hrk-arai/chef-server/raw/master/setup_workstation.sh | bash
touch /home/centos/chef/hostlist.txt
chown -R centos:centos /home/centos/chef/hostlist.txt
