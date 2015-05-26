#
# Cookbook Name:: bacula-server
# Recipe:: director
#
# Copyright 2015 Pavel Yudin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

databag = data_bag_item(node['bacula']['databag_name'], node['bacula']['databag_item'])

node.set['postgresql']['password']['postgres'] = databag['postgres_root_password']

include_recipe 'postgresql::server'

package node['bacula']['director_package'] do
  action :install
  version node['bacula']['version'] if node['bacula']['version']
end

# Creating bacula database schema
execute 'create database' do
  command '/usr/libexec/bacula/create_bacula_database'
  cwd '/'
  user 'postgres'
  returns 0
  not_if "psql -tqc '\\l' | grep #{databag['db_name']}", user: 'postgres'
end

execute 'create tables' do
  command '/usr/libexec/bacula/make_bacula_tables'
  cwd '/'
  user 'postgres'
  returns 0
  not_if "psql -tqc '\\d' #{databag['db_name']} | grep log", user: 'postgres'
end

execute 'grant privileges' do
  command '/usr/libexec/bacula/grant_bacula_privileges'
  cwd '/'
  user 'postgres'
  returns 0
  not_if "psql -tqc '\\du' | grep #{databag['db_user']}", user: 'postgres'
end

# Setting password for the database bacula user
execute 'setting password' do
  command "psql -c \"ALTER ROLE #{databag['db_user']} PASSWORD '#{databag['db_password']}';\""
  user 'postgres'
  returns 0
  sensitive true
end

template '/etc/sysconfig/bacula-dir' do
  source 'bacula-dir.erb'
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[bacula-dir]'
end

directory '/etc/bacula/conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

if Chef::Config[:solo]
  Chef::Log.fatal('This recipe uses search. Chef Solo does not support search.')
else
  bacula_clients = search(:node, "role:#{node['bacula']['director']['clients_role']}")
  bacula_storage = search(:node, "role:#{node['bacula']['director']['storage_role']}").first
end

fail 'Storage server not found' if bacula_storage.nil?
fail 'You must have at least one configured client' if bacula_clients.empty?

template '/etc/bacula/conf.d/storage.conf' do
  source 'dir-storage.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(:storage => bacula_storage, :sd_password => databag['sd_password'])
  notifies :restart, 'service[bacula-dir]'
end

directory '/etc/bacula/conf.d/clients' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

bacula_clients.each do |client|
  template "/etc/bacula/conf.d/clients/#{client['fqdn']}.conf" do
    source 'client.conf.erb'
    owner 'root'
    group 'root'
    mode '0644'
    variables(:client => client, :fd_password => databag['fd_password'])
    notifies :restart, 'service[bacula-dir]'
  end
end

template '/etc/bacula/bacula-dir.conf' do
  source 'bacula-dir.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables console_password: databag['console_password'], db_name: databag['db_name'],
            db_user: databag['db_user'], db_password: databag['db_password']
  notifies :restart, 'service[bacula-dir]'
end

service 'bacula-dir' do
  supports :status => true, :restart => true, :reload => true
  action [:start, :enable]
end
