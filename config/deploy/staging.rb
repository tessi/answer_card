server 'mirfac.uberspace.de',
       user: 'test22',
       roles: [:app, :web, :cron, :db],
       primary: true,
       ssh_options: {
         keys: %w{~/.ssh/id_rsa},
         forward_agent: true,
         auth_methods: %w(publickey)
       }

set :domain, 'antwort.hochzeit.tessenow.com'
set :user, 'test22'
