# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.0'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 5.0'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sassc-rails'

# A framework for building view components
gem 'view_component', '2.74', require: 'view_component/engine'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '3.1.16'

# A ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard
gem 'jwt', '2.4.1'

# authorization
gem 'action_policy', '0.6.0'

# validations
gem 'dry-validation', '~> 1.8'

# Catch unsafe migrations in development
gem 'strong_migrations', '~> 0.7'

# api serializer
gem 'jsonapi-serializer', '2.2.0'

# translating
gem 'route_translator', git: 'https://github.com/enriclluelles/route_translator', branch: 'master'

# active jobs adapter
gem 'que', '~> 2.2.0'

# http client
gem 'faraday', '~> 1.9'
gem 'faraday_middleware', '~> 1.2'

# Pretty print
gem 'awesome_print'

# jsbundling
gem 'jsbundling-rails', '~> 1.0'

gem 'foreman'

# organizing services
gem 'service_operator'

# email tracking system
gem 'emailbutler'

group :development, :test do
  gem 'bullet', git: 'https://github.com/flyerhzm/bullet', branch: 'master'
  gem 'rubocop', '~> 1.35', require: false
  gem 'rubocop-performance', '~> 1.14', require: false
  gem 'rubocop-rails', '~> 2.15', require: false
  gem 'rubocop-rspec', '~> 2.12', require: false
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
