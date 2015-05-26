require 'spec_helper'

describe 'bacula-server::storage' do
  it 'installs bacula storage' do
    expect(package('bacula-storage-postgresql')).to be_installed
  end

  it 'enables and runs bacula storage server' do
    expect(service('bacula-sd')).to be_enabled
    expect(service('bacula-sd')).to be_running
  end
end
