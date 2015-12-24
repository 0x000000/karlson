require 'rubygems'
require 'bundler/setup'

require 'karlson'

RSpec.configure do |config|
  config.include(Karlson::DSL)
end
