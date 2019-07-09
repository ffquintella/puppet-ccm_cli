require 'spec_helper'

describe 'ccm_cli::scheduled' do
  let(:title) { 'test_scheduled' }
  let(:params) do
    {
      ccm_srv_record: 'ccm.srvc.test.com',
      template_content: 'teste',
      authorization_token: 'AVHDSDS',
      destination_file: '/tmp/test',
      frequency: 2
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
