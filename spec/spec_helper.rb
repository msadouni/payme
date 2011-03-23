# encoding: UTF-8
require 'payme'

require 'rspec'
require 'mocha'
require 'webmock/rspec'

RSpec.configure do |config|
  
  config.before :each do
    Payme::Config.set_config(nil, nil)
    WebMock.reset!
  end
end
