server 'mirfac.uberspace.de',
       user: 'test8',
       roles: [:app, :web, :cron, :db],
       primary: true,
       ssh_options: {
         keys: %w{~/.ssh/id_rsa},
         forward_agent: true,
         auth_methods: %w(publickey)
       }

set :user, 'test8'
set :branch, :master
set :domain, 'antwort.hochzeit.tessenow.org'
set :log_level, :debug
set :state, :staging
