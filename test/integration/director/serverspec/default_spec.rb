require 'spec_helper'

describe 'bacula-server::director' do
  it 'installs postgresql-server with 9.3 verison' do
    expect(package('postgresql93-server')).to be_installed.with_version('9.3.6')
  end

  it 'enables and runs postgresql' do
    expect(service('postgresql-9.3')).to be_running
    expect(service('postgresql-9.3')).to be_enabled
  end

  it 'installs bacula director' do
    expect(package('bacula-director-postgresql')).to be_installed
  end

  it 'enables and runs bacula director server' do
    expect(service('bacula-dir')).to be_enabled
    expect(service('bacula-dir')).to be_running
  end
end
