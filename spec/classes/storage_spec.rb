require 'spec_helper'

describe 'bacula::storage' do
  let(:facts) {
    {
      :operatingsystem => 'Debian',
      :concat_basedir => '/dne'
    }
  }
  let(:params) { {:director => 'mydirector.lan'} }
  it { should contain_class('bacula::storage') }
end

