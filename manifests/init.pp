class passenger_repo (
  $ensure                 = $passenger_repo::params::ensure,
  $enterprise_license_key = $passenger_repo::params::enterprise_license_key,
  $enterprise_repo_name   = $passenger_repo::params::enterprise_repo_name,
  $enterprise_token       = $passenger_repo::params::enterprise_token,
  $oss_repo_name          = $passenger_repo::params::oss_repo_name,
  $pin                    = $passenger_repo::params::pin,
) inherits passenger_repo::params {

  if $enterprise_license_key {
    if !defined('$enterprise_token') {
      fail('The Phusion Enterprise APT download token was not provided.')
    }

    $location  = "https://download:${enterprise_token}@www.phusionpassenger.com/enterprise_apt"
    $repo_name = $enterprise_repo_name

    file { '/etc/passenger-enterprise-license':
      ensure  => file,
      content => $enterprise_license_key,
      before  => Apt::Source[$repo_name],
    }
  }

  else {
    $location  = 'https://oss-binaries.phusionpassenger.com/apt/passenger'
    $repo_name = $oss_repo_name
  }

  if $::osfamily == 'Debian' {
    ensure_packages(['apt-transport-https', 'ca-certificates'])
    include ::apt

    if ($ensure == 'present') {
      apt::source { $repo_name:
        key      => {
          'id'     => '16378A33A6EF16762922526E561F9B9CAC40B2F7',
          'server' => 'keyserver.ubuntu.com',
        },
        location => $location,
        pin      => $pin,
        release  => $::lsbdistcodename,
        repos    => 'main',
        require  => [
          Package['apt-transport-https'],
          Package['ca-certificates'],
        ],
      }
    }

    else {
      apt::source { $enterprise_repo_name:
        ensure => 'absent',
      }

      apt::source { $oss_repo_name:
        ensure => 'absent',
      }
    }
  }

  else {
    notice ("Your operating system ${::operatingsystem} will not have the Phusion Passenger repository applied")
  }
}
