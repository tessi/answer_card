abort "You must run this using 'bundle exec ...'" unless ENV['BUNDLE_BIN_PATH'] || ENV['BUNDLE_GEMFILE']
lock '3.4.0'

set :application, 'AnswerCard'
set :repo_url, 'git@github.com:tessi/answer_card.git'

require 'json'
secret = {}
secret_file = "config/secret/#{fetch(:stage)}.json"
if (File.exists? secret_file)
  File.open( secret_file, "r" ) do |f|
    secret = JSON.load( f )
  end
end

set :rollbar_token, "#{secret['rollbar']['token']}"
set :rollbar_env, Proc.new { fetch :stage }
set :rollbar_role, Proc.new { :app }

set :extra_env_variables, -> {
  {
    'ROLLBAR_ACCESS_TOKEN' => fetch(:rollbar_token)
  }
}
