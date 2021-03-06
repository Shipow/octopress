# This file is copied to spec/ when you run 'rails generate rspec:install'
require './spec/support/simplecov'
require File.expand_path("../../lib/octopress", __FILE__)
require 'rspec'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path("support/**/*.rb", File.dirname(__FILE__))].each {|f| require f}

RSpec.configure do |config|
  # Include FactoryGirl helpers
  # config.include FactoryGirl::Syntax::Methods

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.include Octopress::Test::Environment
end
