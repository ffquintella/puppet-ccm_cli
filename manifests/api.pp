# @summary A short summary of the purpose of this class
#
# This class installs the command line api used to automate requests to ccm
#
# @example
#   include ccm_cli::api
#
# @param [String] ccm_srv_record 
#   The dns srv record used to locate the ccm service
#
class ccm_cli::api (
  String $ccm_srv_record = '',
){
  case $::os['family'] {
    'RedHat': {
      include 'ccm_cli::lin::api'
      $installation_directory = $ccm_cli::lin::api::installation_directory
    }
    default: {fail {'OS is not supported yet.':}}
  }
  file { $installation_directory:
    ensure => directory,
  }
  file { "${installation_directory}/base_lib.rb":
    source  => 'puppet:///modules/ccm_cli/base_lib.rb',
    require => File[$installation_directory],
  }
  file { "${installation_directory}/ccm_lib.rb":
    source  => 'puppet:///modules/ccm_cli/ccm_lib.rb',
    require => File[$installation_directory],
  }
  file { "${installation_directory}/ccm_reader.rb":
    content => epp('ccm_cli/ccm_reader.rb.epp', {
      'ccm_srv_record'   => $ccm_srv_record,}),
    require => File[$installation_directory],
    mode    => '0760',
  }
}
