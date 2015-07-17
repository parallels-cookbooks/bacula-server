#
# Cookbook Name:: bacula-server
# Attribute:: default
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

# Postgresql configuration
default['postgresql']['version'] = '9.3'
default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
default['postgresql']['dir'] = "/var/lib/pgsql/#{node['postgresql']['version']}/data"
default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
default['postgresql']['enable_pgdg_yum'] = true
default['postgresql']['config']['data_directory'] = node['postgresql']['dir']

# Bacula director configuration
default['bacula']['director']['user'] = 'bacula'
default['bacula']['director']['group'] = 'bacula'
default['bacula']['director']['name'] = 'bacula-dir'
default['bacula']['director']['port'] = 9101
default['bacula']['director']['maximum_concurrent_jobs'] = 20
default['bacula']['director']['clients_role'] = 'bacula-client'
default['bacula']['director']['storage_role'] = 'bacula-storage'
default['bacula']['director']['working_directory'] = '/var/spool/bacula'
default['bacula']['director']['pid_directory'] = '/var/run'
default['bacula']['director']['email_on_error'] = []

# Bacula storage configuration
default['bacula']['storage']['volumes_dir'] = '/srv/bacula'
default['bacula']['storage']['user'] = 'bacula'
default['bacula']['storage']['group'] = 'tape'

# Bacula common configuration
default['bacula']['databag_name'] = 'bacula'
default['bacula']['databag_item'] = 'bacula'
default['bacula']['director_package'] = 'bacula-director-postgresql'
default['bacula']['storage_package'] = 'bacula-storage-postgresql'
default['bacula']['full_backup_retention'] = '12 month'
default['bacula']['incremental_backup_retention'] = '30 days'
default['bacula']['differential_backup_retention'] = '30 days'
