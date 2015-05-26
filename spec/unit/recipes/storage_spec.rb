#
# Cookbook Name:: bacula-server
# Spec:: storage
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

describe 'bacula-server::storage' do
  context 'When all attributes are default, on an rhel platform' do
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
      end
      runner.converge(described_recipe)
    end

    it 'converges successfully' do
      chef_run
    end

    it 'installs bacula-storage package' do
      expect(chef_run).to install_package('bacula-storage-postgresql')
    end

    it 'creates backup directory' do
      expect(chef_run).to create_directory('/srv/bacula')
    end

    it 'enables and runs bacula storage server' do
      expect(chef_run).to enable_service('bacula-sd')
      expect(chef_run).to start_service('bacula-sd')
    end

    it 'creates bacula storage config' do
      expect(chef_run).to create_template('/etc/bacula/bacula-sd.conf')
    end

    it 'creates bacula storage sysconfig' do
      expect(chef_run).to create_template('/etc/sysconfig/bacula-sd')
    end
  end
end
