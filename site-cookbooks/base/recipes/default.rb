#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# Basics
basic_pkgs = %w{vim tree git openssl libssl-dev}
basic_pkgs.each do |pkg|
    package pkg do
        action :install
    end
end


# PostgreSQL
package "postgresql" do
    action :install
end

# heroku toolbelt
bash "install_heroku_toolbelt" do
    code "wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh"
    # not "command"... why!?
    not_if "which heroku"
end

# Ruby
group "rbenv" do
  action :create
  members "vagrant"
  append true
end

git "rbenv" do
    destination "/usr/local/rbenv"
    repository "git://github.com/sstephenson/rbenv.git"
    reference "master"
    action :sync
    user "root"
    group "rbenv"
end

template "/etc/profile.d/rbenv.sh" do
    source "rbenv.sh.erb"
    owner "root"
    group "root"
    mode 0644
end

directory "/usr/local/rbenv/plugins" do
  owner "root"
  group "rbenv"
  mode "0755"
  action :create
end

git "/usr/local/rbenv/plugins/ruby-build" do
    repository "git://github.com/sstephenson/ruby-build.git"
    reference "master"
    action :sync
    user "root"
    group "rbenv"
end

ruby_version = "2.1.5"

bash "install_ruby" do # not "execute" 
    code "source /etc/profile.d/rbenv.sh; rbenv install #{ruby_version}"
    # not "command"... why!?
    action :run
    not_if "bash -c \"source /etc/profile.d/rbenv.sh; rbenv versions | grep #{ruby_version}\""
end

bash "set_global_ruby" do
    code <<-EOC
    source /etc/profile.d/rbenv.sh
    rbenv global #{ruby_version}
    rbenv rehash
    EOC
    # not "command"... why!?
    action :run
    not_if "bash -c \"source /etc/profile.d/rbenv.sh; rbenv global | grep #{ruby_version}\""
end


