#!/bin/bash

packages="/etc/chef/packages"
version="7"
core="chef-server-core-12.1.2-1.el7.x86_64.rpm"
reporting="opscode-reporting-1.5.6-1.el7.x86_64.rpm"
manage="opscode-manage-1.21.0-1.el7.x86_64.rpm"

mkdir $packages

# download packages
curl -sL https://packages.chef.io/stable/el/$version/$core > $packages/$core
curl -sL https://packages.chef.io/stable/el/$version/$reporting > $packages/$reporting
curl -sL https://packages.chef.io/stable/el/$version/$manage > $packages/$manage

# install chef-server-core
rpm -Uvh $packages/$core
chef-server-ctl reconfigure

# install manage
chef-server-ctl install opscode-manage --path $packages
chef-server-ctl reconfigure
opscode-manage-ctl reconfigure

# install reporting
chef-server-ctl install opscode-reporting --path $packages
chef-server-ctl reconfigure
opscode-reporting-ctl reconfigure
