server 'hercules.uberspace.de',
       user: 'hz',
       roles: [:app, :web, :cron, :db],
       primary: true,
       ssh_options: {
         keys: %w{~/.ssh/id_rsa},
         forward_agent: true,
         auth_methods: %w(publickey)
       }

set :user, 'hz'
set :branch, :production
set :domain, 'antwort.hochzeit.tessenow.org'
