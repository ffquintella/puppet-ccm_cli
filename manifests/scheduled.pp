# @summary A short summary of the purpose of this defined type.
#
# Creates a file and updates it on a schedule
#
# @example
#   ccm_cli::scheduled { 'namevar': }
#
# @param [String] ccm_srv_record 
#   The dns srv record used to locate the ccm service
#
# @param [String] template_content 
#   The file template content
#
# @param [String] authorization_token 
#   The ccm app authorization token
#
# @param [Array] credentials 
#   The credentials to be searchead and replaced
#
# @param [Array] configurations 
#   The configurations to be searchead and replaced
#
# @param [String] destination_file 
#   The destination file to be written
#
# @param [String] environment 
#   The environment of the credentials to be retrieved
#
# @param [Integer] frequency 
#   The frequency in minutes to retrieve the information
#
define ccm_cli::scheduled (
  String $ccm_srv_record = '',
  String $template_content = '',
  String $authorization_token = '',
  Array $credentials = [],
  Array $configurations = [],
  String $destination_file = $title,
  String $environment = 'dev',
  Integer $frequency = 5
){

  if $::os['family'] != 'RedHat' {
    fail {'Os not supported':}
  }

  if $ccm_srv_record == '' {
    fail {'ccm_srv_record needs to be set':}
  }
  if $template_content == '' {
    fail {'$template_content needs to be set.':}
  }
  if $authorization_token == '' {
    fail {'$authorization_token needs to be set.':}
  }
  if $destination_file == '' {
    fail {'$destination_file needs to be set.':}
  }
  if $frequency < 1 {
    fail {'$frequency needs to be positive and bigger then 0.':}
  }

  include 'ccm_cli::lin::api'
  $installation_directory = $ccm_cli::lin::api::installation_directory

  $user = 'root'
  $group = 'root'

  if !defined(File[$installation_directory]){
    file{ $installation_directory:
      owner  => $user,
      group  => $group,
      source => 'puppet:///modules/ccm_cli/base_lib.rb',
    }
  }

  if !defined(File["${installation_directory}/base_lib.rb"]){
    file{"${installation_directory}/base_lib.rb":
      owner   => $user,
      group   => $group,
      source  => 'puppet:///modules/ccm_cli/base_lib.rb',
      require => File[$installation_directory],
    }
  }
  if !defined(File["${installation_directory}/ccm_lib.rb"]){
    file{"${installation_directory}/ccm_lib.rb":
      owner   => $user,
      group   => $group,
      source  => 'puppet:///modules/ccm_cli/ccm_lib.rb',
      require => File[$installation_directory],
    }
  }
  if !defined(File["${installation_directory}/templates"]){
    file{"${installation_directory}/templates":
      ensure  => directory,
      owner   => $user,
      group   => $group,
      require => File[$installation_directory],
    }
  }

  $clean_title = regsubst($title, ' ', '_', 'G')

  file{"${installation_directory}/templates/${clean_title}.erb":
    owner   => $user,
    group   => $group,
    content => $template_content,
    require => File["${installation_directory}/templates"],
  }

  file{"${installation_directory}/${clean_title}_reader.rb":
    owner   => $user,
    group   => $group,
    content => epp('ccm_cli/ccm_http_reader.rb.epp', {
      'ccm_srv_record'   => $ccm_srv_record,
      'credentials'      => $credentials,
      'configurations'   => $configurations,
      'token'            => $authorization_token,
      'destination_file' => $destination_file,
      'template'         => $template_content,
      'environment'      => $environment,}),
    require => File[$installation_directory],
  }

  cron {"${clean_title}_job":
    command => "/bin/bash -c 'cd ${installation_directory}/; /bin/env ruby ${installation_directory}/${clean_title}_reader.rb'",
    user    => 'root',
    minute  => "*/${frequency}",
    require => File["${installation_directory}/${clean_title}_reader.rb"],
  }


}

