require 'spec_helper'

describe 'ccm_cli::api' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          ccm_srv_record: 'ccm.srvc.test.com',
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_class('ccm_cli::lin::api') }
      it { is_expected.to contain_file('/usr/srare/ccm') }
      it { is_expected.to contain_file('/usr/srare/ccm/base_lib.rb') }
      it { is_expected.to contain_file('/usr/srare/ccm/ccm_lib.rb') }
      
    end
  end
end
