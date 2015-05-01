abort "You must run this using 'bundle exec ...'" unless ENV['BUNDLE_BIN_PATH'] || ENV['BUNDLE_GEMFILE']
lock '3.4.0'

set :stages, %w[ production staging ]

set :use_sudo, false
set :deploy_via, :remote_cache
set :deploy_to, ->{ "/var/www/virtual/#{fetch :user}/apps/#{fetch :application}" }
set :home, ->{ "/home/#{fetch :user}" }
set :shared_path, ->{ "#{fetch :home}/shared/#{fetch :application}" }

set :application, 'AnswerCard'
set :repo_url, 'git@github.com:tessi/answer_card.git'
set :scm, :git

set :ssh_options, { :forward_agent => true }
set :pty, true

set :rollbar_token, "#{secret('rollbar.token')}"
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

def passenger_port
  capture(:cat, "#{fetch :shared_path}/.passenger-port")
end

set :bundle_path, -> { '~/.gem' }
set :bundle_flags, ''


namespace :uberspace do
  task :setup_passenger_port do
    on roles(:all) do
      port = capture('python -c \'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()\'')
      upload! StringIO.new(port), "#{fetch :shared_path}/.passenger-port"
    end
  end

  task :setup_svscan do
    on roles(:all) do
      execute 'test -d ~/service || uberspace-setup-svscan; echo 0'
    end
  end

  task :setup_bashrc do
    require 'securerandom'

    bashrc = <<-EOF
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi
umask 022

readlog()
{
        if [ -n "$1" ]; then
                cat ~/service/$1/log/main/* | tai64nlocal | less;
        else
                echo -e "Usage: readlog <daemonname>\navailible daemons: \n\n`ls ~/service/`";
        fi;
}

export PATH=/package/host/localhost/ruby-2.2/bin:$PATH
export PATH=#{fetch :home}/.gem/ruby/2.2.0/bin:$PATH
export PATH=/package/host/localhost/nodejs-0.10/bin:$PATH
export LANG=en_US.UTF-8
export RAILS_SERVE_STATIC_FILES=1
#{"export ROLLBAR_ACCESS_TOKEN=/#{fetch :rollbar_token}" if fetch :rollbar_token}
    EOF

    on roles(:all) do
      upload! StringIO.new(bashrc), "#{fetch :home}/.bashrc"
    end
  end


  task :setup_secrets do
    on roles(:all) do
      secrets = <<-EOF
#{fetch :stage}:
  secret_key_base: #{SecureRandom.hex 40}
      EOF

      execute :mkdir, "-p #{fetch :shared_path}/config"
      upload! StringIO.new(secrets), "#{fetch :shared_path}/config/secrets.yml"
    end
  end

  task :setup_npmrc do
    npmrc = <<-EOF
prefix = #{fetch :home}
umask = 077
    EOF

    on roles(:all) do
      upload! StringIO.new(npmrc), "#{fetch :home}/.npmrc"
    end
  end

  task :setup_bowerrc do
    bowerrc = <<-EOF
{
  "interactive": false
}
    EOF

    on roles(:all) do
      upload! StringIO.new(bowerrc), "#{fetch :home}/.bowerrc"
    end
  end

  task :setup_gemrc do
    gemrc = <<-EOF
gem: --user-install --no-rdoc --no-ri
    EOF

    on roles(:all) do
      upload! StringIO.new(gemrc), "#{fetch :home}/.gemrc"
    end
  end

  task :setup_shared_path do
    on roles(:all) do
      execute :mkdir, '-p', fetch(:shared_path)
    end
  end

  task :setup_bundler do
    on roles(:all) do
      within fetch(:home) do
        execute 'PATH=/package/host/localhost/ruby-2.2/bin:$PATH gem install bundler'
      end
    end
  end
end

namespace :daemontools do
  task :setup_daemon do
    on roles(:all) do
      daemon_script = <<-EOF
#!/bin/bash
export HOME=#{fetch :home}
source #{fetch :home}/.bashrc
cd #{fetch :deploy_to}/current
exec bundle exec passenger start -p #{passenger_port} -e #{fetch :state} 2>&1
      EOF

      log_script = <<-EOF
#!/bin/sh
exec multilog t ./main
      EOF

      execute                 "mkdir -p #{fetch :home}/etc/run-rails-#{fetch :application}"
      execute                 "mkdir -p #{fetch :home}/etc/run-rails-#{fetch :application}/log"
      upload! StringIO.new(daemon_script), "#{fetch :home}/etc/run-rails-#{fetch :application}/run"
      upload! StringIO.new(log_script),    "#{fetch :home}/etc/run-rails-#{fetch :application}/log/run"
      execute                 "chmod +x #{fetch :home}/etc/run-rails-#{fetch :application}/run"
      execute                 "chmod +x #{fetch :home}/etc/run-rails-#{fetch :application}/log/run"
      execute                 "ln -nfs #{fetch :home}/etc/run-rails-#{fetch :application} #{fetch :home}/service/rails-#{fetch :application}"
    end
  end
end

namespace :apache do
  task :setup_reverse_proxy do
    on roles(:all) do
      htaccess = <<-EOF
RewriteEngine On
RewriteBase /
RewriteRule ^(.*)$ http://localhost:#{passenger_port}/$1 [P]
      EOF
      path    = fetch(:domain) ? "/var/www/virtual/#{fetch :user}/#{fetch :domain}" : "/var/www/virtual/#{fetch :user}/html"
      execute    "mkdir -p #{path}"
      if fetch(:domain)
        wwwpath = "/var/www/virtual/#{fetch :user}/www.#{fetch :domain}"
        execute    "ln -nfs #{path} #{wwwpath}"
      end
      upload! StringIO.new(htaccess), "#{path}/.htaccess"
      execute           "chmod +r #{path}/.htaccess"
      execute           "uberspace-add-domain -qwd #{fetch :domain} ; true" if fetch(:domain)
      execute           "uberspace-add-domain -qwd www.#{fetch :domain} ; true" if fetch(:domain)
    end
  end
end

namespace :deploy do
  task :start do
    on roles(:all) do
      execute "svc -u #{fetch :home}/service/rails-#{fetch :application}"
    end
  end

  task :stop do
    on roles(:all) do
      execute "svc -d #{fetch :home}/service/rails-#{fetch :application}"
    end
  end

  task :restart do
    on roles(:all) do
      execute "svc -du #{fetch :home}/service/rails-#{fetch :application}"
    end
  end
end

namespace :db do
  desc "Make symlink for database yaml"
  task :symlink do
    on roles(:all) do
      execute "ln -nfs #{fetch :shared_path}/config/database.yml #{fetch :release_path}/config/database.yml"
    end
  end
end


namespace :deploy do
  task :setup do
  end

  task :symlink_secret_token do
    on roles(:all) do
      execute "ln -nfs #{fetch :shared_path}/config/secrets.yml #{fetch :release_path}/config/secrets.yml"
    end
  end

  task :update_bower_assets do
    on roles(:all) do
      execute "cd #{fetch :release_path};#{fetch :home}/lib/node_modules/bower/bin/bower install"
    end
  end

  task :install_bower do
    on roles(:all) do
      execute "cd #{fetch :shared_path} ; ls ; pwd ; npm install -g bower"
    end
  end
end

namespace :mysql do
  task :setup_database_and_config do
    on roles(:all) do
      my_cnf = capture('cat ~/.my.cnf')
      config = {}
      %w(development staging production test).each do |env|

        config[env] = {
          'adapter' => 'mysql2',
          'encoding' => 'utf8',
          'database' => "#{fetch :user}_rails_#{fetch :application}_#{env}",
          'host' => 'localhost'
        }

        my_cnf.match(/^user=(\w+)/)
        config[env]['username'] = $1

        my_cnf.match(/^password=(\w+)/)
        config[env]['password'] = $1

        my_cnf.match(/^port=(\d+)/)
        config[env]['port'] = $1.to_i

        execute "mysql -e 'CREATE DATABASE IF NOT EXISTS #{config[env]['database']} CHARACTER SET utf8 COLLATE utf8_general_ci;'"
      end

      execute "mkdir -p #{fetch :shared_path}/config"

      upload! StringIO.new(config.to_yaml), "#{fetch :shared_path}/config/database.yml"
    end
  end
end

before  'deploy:setup',    'uberspace:setup_shared_path'
before  'deploy:setup',    'uberspace:setup_bashrc'
before  'deploy:setup',    'uberspace:setup_bowerrc'
before  'deploy:setup',    'uberspace:setup_npmrc'
before  'deploy:setup',    'uberspace:setup_gemrc'
before  'deploy:setup',    'uberspace:setup_passenger_port'
after   'deploy:setup',    'uberspace:setup_svscan'
after   'deploy:setup',    'uberspace:setup_bundler'
after   'deploy:setup',    'uberspace:setup_secrets'
after   'deploy:setup',    'daemontools:setup_daemon'
after   'deploy:setup',    'apache:setup_reverse_proxy'
after   'deploy:setup',    'mysql:setup_database_and_config'
after   'deploy:setup',    'deploy:install_bower'
after   'deploy',          'deploy:cleanup'

after   'deploy:updating', 'db:symlink'
after   'deploy:updating', 'deploy:symlink_secret_token'
after   'deploy:updating', 'deploy:update_bower_assets'
after   'deploy:restart',  'deploy:cleanup'
