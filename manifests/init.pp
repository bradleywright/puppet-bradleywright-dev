# Standard applications and config I use on every Mac
class bradleywright-dev(
  $email = "brad@intranation.com"
  ) {

  # Applications
  include alfred
  include chrome
  include dropbox
  include emacs::formacosx
  include emacs-keybindings
  include iterm2::dev
  include omnifocus
  include remove-spotlight
  include stay
  include turn-off-dashboard
  include vagrant
  include zsh

  # OSX hacks
  include osx::dock::autohide
  include osx::finder::unhide_library
  include osx::global::disable_key_press_and_hold
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_save_dialog
  include osx::no_network_dsstores

  boxen::osx_defaults { 'Disable reopen windows when logging back in':
    key    => 'TALLogoutSavesState',
    domain => 'com.apple.loginwindow',
    value  => 'false',
    user   => $::boxen_user,
  }

  # Install my dotfiles and emacs.d
  $my_home  = "/Users/${::boxen_user}"

  $dotfiles = "${::boxen_srcdir}/dotfiles"

  repository { $dotfiles:
    source  => 'bradleywright/dotfiles',
    notify  => Exec['bradleywright-make-dotfiles'],
  }

  exec { 'bradleywright-make-dotfiles':
    command     => "cd ${dotfiles} && make",
    refreshonly => true,
  }

  $emacs = "${::boxen_srcdir}/emacs-d"

  repository { $emacs:
    source  => 'bradleywright/emacs-d',
    notify  => Exec['bradleywright-make-emacs-d'],
  }

  exec { 'bradleywright-make-emacs-d':
    command     => "cd ${emacs} && make",
    refreshonly => true,
  }

  # This is so Emacs behaves itself when calling out to node
  file { "${my_home}/.emacs.d/local/${::hostname}.el":
    mode    => '0644',
    content => "(exec-path-from-shell-copy-envs '(\"BOXEN_NVM_DIR\" \"BOXEN_NVM_DEFAULT_VERSION\"))
",
    require => Repository[$emacs],
  }

  # Standard packages
  package {
    [
     'bash-completion',
     'python',
     'reattach-to-user-namespace',
     'the_silver_searcher',
     'tmux',
     'wget',
     'zsh-completions',
     'zsh-lovers'
     ]:
  }

  file { "${my_home}/.local_zshrc":
    mode    => '0644',
    content => "cdpath=(${::boxen_srcdir} ~)

# Do not want hub clobbering git
unalias git",
  }

  # Make sure I load Boxen
  file { "${my_home}/.local_zshenv":
    mode    => '0644',
    content => "[[ -f ${boxen::config::boxen_home}/env.sh ]] && . ${boxen::config::boxen_home}/env.sh

[[ -d ${boxen::config::boxen_home}/homebrew/share/python ]] && path=(\$path ${boxen::config::boxen_home}/homebrew/share/python)
"
  }

  # Use my dotfiles gitconfig
  git::config::global { 'include.path':
    value => "${my_home}/.local_gitconfig",
  }

  git::config::global { 'user.email':
    value => $email,
  }

  # Clobber boxen version of Git to use stock homebrew
  Package <| title == "boxen/brews/git" |> {
    ensure => "1.8.3.4"
  }

  # Use my own Git config, thanks.
  Git::Config::Global <| title == "core.excludesfile" |> {
    value => "~/.gitignore"
  }
}
