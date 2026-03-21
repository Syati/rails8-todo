source "https://rubygems.org"

gem "rails", "~> 8.1.0"

# Backend assets
gem "puma", ">= 5.0"
# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false
# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# config
gem 'config'
## Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Database and caching
gem "pg"
# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"

# Authentication
gem "devise"
gem 'devise-i18n'
gem "omniauth"
gem 'omniauth-rails_csrf_protection'

# Form
gem "simple_form"

# Frontend assets
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# scss
gem "dartsass-rails", "~> 0.5.1"
# Bootstrap
gem "bootstrap", "~> 5.3"


# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"





group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  gem "annotaterb", require: false
  gem 'letter_opener_web'

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop", require: false
  gem "rubocop-factory_bot", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rubocop-rbs_inline", require: false
  gem "rubocop-rspec", require: false

  # Testing
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-rails", "~> 8.0.2"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
