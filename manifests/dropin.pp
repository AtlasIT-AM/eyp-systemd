define systemd::dropin (
                          $execstart                   = undef,
                          $execstop                    = undef,
                          $execreload                  = undef,
                          $execstartpre                = undef,
                          $execstartpost               = undef,
                          $restart                     = 'no',
                          $user                        = undef,
                          $group                       = undef,
                          $servicename                 = $name,
                          $forking                     = false,
                          $pid_file                    = undef,
                          $description                 = undef,
                          $after                       = undef,
                          $remain_after_exit           = undef,
                          $type                        = undef,
                          $env_vars                    = [],
                          $environment_files           = [],
                          $wants                       = [],
                          $after_units                 = [],
                          $before_units                = [],
                          $requires                    = [],
                          $conflicts                   = [],
                          $permissions_start_only      = undef,
                          $timeoutstartsec             = undef,
                          $timeoutstopsec              = undef,
                          $timeoutsec                  = undef,
                          $restart_prevent_exit_status = undef,
                          $limit_nofile                = undef,
                          $limit_nproc                 = undef,
                          $limit_nice                  = undef,
                          $runtime_directory           = undef,
                          $runtime_directory_mode      = undef,
                          $restart_sec                 = undef,
                          $private_tmp                 = undef,
                          $working_directory           = undef,
                          $root_directory              = undef,
                          $umask                       = undef,
                          $nice                        = undef,
                          $oom_score_adjust            = undef,
                          $startlimitinterval          = undef,
                          $startlimitburst             = undef,
                          $standard_output             = undef,
                          $standard_error              = undef,
                          $killmode                    = undef,
                        ) {

  if ($env_vars != undef )
  {
    validate_array($env_vars)
  }

  if($type!=undef and $forking==true)
  {
    fail('Incompatible options: type / forking')
  }

  if($type != 'oneshot' and is_array($execstart) and count($execstart) > 1)
  {
    fail('Incompatible options: There are multiple execstart values and Type is not "oneshot"')
  }

  if($type != 'oneshot' and is_array($execstop) and count($execstop) > 1)
  {
    fail('Incompatible options: There are multiple execstart values and Type is not "oneshot"')
  }

  # Takes one of no, on-success, on-failure, on-abnormal, on-watchdog, on-abort, or always.
  validate_re($restart, [ '^no$', '^on-success$', '^on-failure$', '^on-abnormal$', '^on-watchdog$', '^on-abort$', '^always$'], "Not a supported restart type: ${restart} - Takes one of no, on-success, on-failure, on-abnormal, on-watchdog, on-abort, or always")

  validate_array($wants)
  validate_array($after_units)
  validate_array($before_units)
  validate_array($requires)
  validate_array($conflicts)

  if versioncmp($::puppetversion, '4.0.0') >= 0
  {
    contain ::systemd
  }
  else
  {
    include ::systemd
  }

  file { "/etc/systemd/system/${servicename}.service.d/":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
  file { "/etc/systemd/system/${servicename}.service.d/override.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/dropin.erb"),
    #notify  => Exec['systemctl reload'],
  }

}
