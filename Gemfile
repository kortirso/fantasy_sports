# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '7.0.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sassc-rails'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# A framework for building view components
gem 'view_component', '2.40.0', require: 'view_component/engine'

# Manage Procfile-based applications
gem 'foreman', '~> 0.87'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '3.1.16'

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem 'jwt', '2.2.3'

# authorization
gem 'action_policy', '0.6.0'

# validations
gem 'dry-validation', '~> 1.7'

# Catch unsafe migrations in development
gem 'strong_migrations', '~> 0.7'

# api serializer
gem 'jsonapi-serializer', '2.2.0'

# translating
gem 'route_translator', git: 'https://github.com/enriclluelles/route_translator', branch: 'master'

# active jobs adapter
gem 'que', git: 'https://github.com/kortirso/que'

group :development, :test do
  gem 'bullet', git: 'https://github.com/flyerhzm/bullet', branch: 'master'
  gem 'rubocop', '~> 1.23', require: false
  gem 'rubocop-performance', '~> 1.12', require: false
  gem 'rubocop-rails', '~> 2.12', require: false
  gem 'rubocop-rspec', '~> 2.6', require: false
end

group :development do
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem 'rack-mini-profiler', '>= 2.3.3'
end

group :test do
  gem 'database_cleaner', '~> 1.8.5'
  gem 'factory_bot_rails', '6.2.0'
  gem 'json_spec', '1.1.5'
  gem 'rails-controller-testing', '1.0.5'
  gem 'rspec-rails', '5.0.2'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end
