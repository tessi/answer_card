source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'rails-i18n'

gem 'sass-rails', '~> 5.0'
gem 'haml-rails'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'

gem 'validates_lengths_from_database', github: 'rubiety/validates_lengths_from_database'
gem 'has_defaults'

gem 'inherited_resources'
gem 'simple_form'

gem 'rollbar', '~> 1.5.1'

# deployment
gem 'passenger'

group :production do
  gem 'pg'
end

group :development do
  gem 'capistrano',       '~> 3.4'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rails-console'
  gem 'capistrano-uberspace', github: 'tessi/capistrano-uberspace'
end

group :development, :test do
  gem 'sqlite3'

  gem 'byebug'
  gem 'web-console', '~> 2.0'

  gem 'factory_girl_rails'

  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-remote'
  gem 'pry-byebug'
  gem 'rspec-rails'
  gem 'rspec-collection_matchers'

  gem 'faker'
  gem 'letter_opener'
end

group :test do
  gem 'database_cleaner'
  gem 'launchy'
  gem 'cucumber-rails', :require => false

  gem 'cucumber_factory'
  gem 'timecop'
  gem 'capybara'
  gem 'spreewald'

  gem 'email_spec'
  gem 'poltergeist'

  gem 'selenium-webdriver'
  gem 'shoulda', :require => false
  gem 'shoulda-matchers', :require => false
  gem 'rspec_candy'
  gem 'rspec-its'

  gem 'vcr'
  gem 'webmock'
end
