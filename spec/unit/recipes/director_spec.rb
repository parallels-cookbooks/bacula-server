#
# Cookbook Name:: bacula-server
# Spec:: director
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

require 'spec_helper'

describe 'bacula-server::director' do
  context 'When all attributes are default, on the rhel platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new do |_node, server|
        server.create_data_bag('bacula',
                               'bacula' => {
                                 postgres_root_password: 'postgres_root_password',
                                 db_name: 'bacula',
                                 db_user: 'bacula',
                                 db_password: 'password',
                                 sd_password: 'sd_password',
                                 console_password: 'console_password'
                               }
          )
        server.create_node('storage', run_list: ['role[bacula-storage]'], automatic: { ipaddress: '10.10.10.10' })
        server.create_node('client', run_list: ['role[bacula-client]'], automatic: { ipaddress: '10.10.10.11', fqdn: 'client.example.loc' })
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('ls /var/lib/pgsql/9.3/data/recovery.conf').and_return(false)
      stub_command("psql -tqc '\\l' | grep bacula").and_return(false)
      stub_command("psql -tqc '\\d' bacula | grep log").and_return(false)
      stub_command("psql -tqc '\\du' | grep bacula").and_return(false)
    end

    it 'converges successfully' do
      chef_run
    end

    it 'installs bacula-director package' do
      expect(chef_run).to install_package('bacula-director-postgresql')
    end

    it 'creates bacula database' do
      expect(chef_run).to run_execute('create database')
    end

    it 'creates bacula tables' do
      expect(chef_run).to run_execute('create tables')
    end

    it 'grants privileges' do
      expect(chef_run).to run_execute('grant privileges')
    end

    it 'sets password to bacula user' do
      expect(chef_run).to run_execute('setting password')
    end

    it 'creates directory for bacula config files' do
      expect(chef_run).to create_directory('/etc/bacula/conf.d')
    end

    it 'creates directory for bacula client configs' do
      expect(chef_run).to create_directory('/etc/bacula/conf.d/clients')
    end

    it 'enables and runs service' do
      expect(chef_run).to enable_service('bacula-dir')
      expect(chef_run).to start_service('bacula-dir')
    end

    it 'creates sysconfig file' do
      expect(chef_run).to create_template('/etc/sysconfig/bacula-dir')
    end

    it 'create bacula director config' do
      expect(chef_run).to create_template('/etc/bacula/bacula-dir.conf')
    end

    it 'creates storage config' do
      expect(chef_run).to create_template('/etc/bacula/conf.d/storage.conf')
    end

    it 'creates client config' do
      expect(chef_run).to create_template('/etc/bacula/conf.d/clients/client.example.loc.conf')
    end
  end

  context 'Idempotency check' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new do |_node, server|
        server.create_data_bag('bacula',
                               'bacula' => {
                                 postgres_root_password: 'postgres_root_password',
                                 db_name: 'bacula',
                                 db_user: 'bacula',
                                 db_password: 'password',
                                 sd_password: 'sd_password',
                                 console_password: 'console_password'
                               }
          )
        server.create_node('storage', run_list: ['role[bacula-storage]'], automatic: { ipaddress: '10.10.10.10' })
        server.create_node('client', run_list: ['role[bacula-client]'], automatic: { ipaddress: '10.10.10.11', fqdn: 'client.example.loc' })
      end
      runner.converge(described_recipe)
    end

    before do
      stub_command('ls /var/lib/pgsql/9.3/data/recovery.conf').and_return(false)
      stub_command("psql -tqc '\\l' | grep bacula").and_return(true)
      stub_command("psql -tqc '\\d' bacula | grep log").and_return(true)
      stub_command("psql -tqc '\\du' | grep bacula").and_return(true)
    end

    it 'creates bacula database' do
      expect(chef_run).not_to run_execute('create database')
    end

    it 'creates bacula tables' do
      expect(chef_run).not_to run_execute('create tables')
    end

    it 'grants privileges' do
      expect(chef_run).not_to run_execute('grant privileges')
    end
  end
end
