# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails',         '~> 6.0.0'
gem 'pg',            '~> 1.2.3'
gem 'puma',          '~> 3.12'
gem 'sass-rails',    '~> 5'
gem 'webpacker',     '~> 4.0'
gem 'turbolinks',    '~> 5'
gem 'jbuilder',      '~> 2.7'
gem 'nexmo',         '~> 6.1.0'
gem 'cancancan',     '~> 3.1.0'
gem 'twilio-ruby',   '~> 5.31.1'
gem 'business_time', '~> 0.9.3'
gem 'phonelib',      '~> 0.6.43'

gem 'devise',           '~> 4.7.1'
gem 'omniauth-github',  '~> 1.3.0'
gem 'bootsnap',         '>= 1.4.2', require: false
gem 'rubocop',          require: false

group :development, :test do
  gem 'rspec-rails',    '~> 4.0.0.rc1'
  gem 'pry'
end

group :development do
  gem 'listen',                '>= 3.0.5', '< 3.2'
  gem 'web-console',           '>= 3.3.0'
  gem 'spring',                '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara',            '>= 2.15'
  gem 'selenium-webdriver',  '~> 3.142.4'
  gem 'webdrivers',          '~> 4.1.2'
  gem 'factory_bot_rails',   '~> 5.1.1'
  gem 'shoulda-matchers',    '~> 4.1'
  gem 'database_cleaner',    '~> 1.7.0'
  gem 'timecop'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
