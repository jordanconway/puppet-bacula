# Class: bacula
#
# This class installs a bacula job on the director.  This can be used for specific applications as well as general host backups
#
# Parameters:
#   * files - An array of files that you wish to get backed up on this job for
#     this host.  ie: ["/etc","/usr/local"]
#   * excludes - An array of files to skip for the given job.
#     ie: ["/usr/local/src"]
#   * fileset - If set to true, a fileset will be genereated based on the files
#     and exclides paramaters specified above. If set to false, the
#     job will attempt to use the fileset named "Common". If set to anything
#     else, provided it's a String, that named fileset will be used.
#     NOTE: the fileset Common or the defined fileset must be declared elsewhere
#     for this to work. See Class::Bacula for details.
#   * runscript - Array of hash(es) containing RunScript directives.
#   * reshedule_on_error - boolean for enableing disabling job option "Reschedule On Error"
#   * reshedule_interval - string time-spec for job option "Reschedule Interval"
#   * reshedule_times - string count for job option "Reschedule Times"
#
# Actions:
#   * Exports job fragment for consuption on the director
#
# Requires:
#   * Class::Bacula {}
#
# Sample Usage:
#  bacula::job { "${fqdn}-common":
#    fileset => "Root",
#  }
#
#  bacula::job { "${fqdn}-mywebapp":
#    files    => ["/var/www/mywebapp","/etc/mywebapp"],
#    excludes => ["/var/www/mywebapp/downloads"],
#  }
#
define bacula::job (
  $files               = [],
  $excludes            = [],
  $jobtype             = 'Backup',
  $fileset             = true,
  $template            = 'bacula/job.conf.erb',
  $pool                = 'Default',
  $jobdef              = 'Default',
  $runscript           = [],
  $level               = undef,
  $accurate            = 'no',
  $reschedule_on_error = false,
  $reschedule_interval = '1 hour',
  $reschedule_times    = '10',
) {
  validate_array($files)
  validate_array($excludes)
  validate_re($jobtype, ['^Backup', '^Restore', '^Admin', '^Verify'])
  validate_array($runscript)
  validate_re($accurate, ['^yes', '^no'])

  include bacula::common
  include bacula::params

  # if the fileset is not defined, we fall back to one called "Common"
  if is_string($fileset) {
    $fileset_real = $fileset
  } elsif $fileset == true {
    if $files == '' { err('you tell me to create a fileset, but no files given') }
    $fileset_real = $name
    bacula::fileset { $name:
      files    => $files,
      excludes => $excludes
      }
  } else {
    $fileset_real = 'Common'
  }

  @@concat::fragment { "bacula-job-${name}":
    target  => '/etc/bacula/conf.d/job.conf',
    content => template($template),
    tag     => "bacula-${::bacula::params::bacula_director}";
  }
}
