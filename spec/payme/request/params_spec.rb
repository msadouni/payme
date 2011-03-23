# encoding: UTF-8
require 'spec_helper'

describe Payme::Params do
  
  describe 'parse_params' do
    it 'should parse the default params' do
      Payme::Request.new(300).parse_params.should match(/([a-z\_]+)=([0-z]+)/)
    end    
    
    it 'should parse defined params' do
      Payme::Request.new(300, {
        :merchant_id => '0000',
        :amount => 15,
        :merchant_country => 'uk',
        :currency_code => 42
      }).parse_params.should match(/([a-z\_]+)=([0-z]+)/)
    end
    
    it 'should have the merchant id' do
      Payme::Request.new(300).parse_params.should match(/merchant_id=014213245611111/)
    end
    
    it 'should have the merchant country' do
      Payme::Request.new(300).parse_params.should match(/merchant_country=fr/)
    end
    
    it 'should have the currency code' do
      Payme::Request.new(300).parse_params.should match(/currency_code=978/)
    end
    
    it 'should have the pathfile' do
      Payme::Request.new(300).parse_params.should match(/pathfile=\//)
    end
    
    it 'should have the amount' do
      Payme::Request.new(300).parse_params.should match(/amount=300/)
    end
  end

  describe 'parse_http_params' do
    before :each do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
    end

    it 'should be a hash with the default keys' do
      params = Payme::Request.new(300).parse_http_params.should include(:merchant_id, :merchant_country, :currency_code)
    end

    it 'should be a hash with defined params' do
      params = Payme::Request.new(300, {
        :merchant_id => '0000',
        :merchant_country => 'uk',
        :currency_code => 42
      }).parse_http_params.should include(
        :merchant_id => '0000',
        :merchant_country => 'uk',
        :currency_code => 42,
        :amount => 300
      )
    end

    it 'should include the amount' do
      Payme::Request.new(300).parse_http_params.should include(:amount => 300)
    end

    it 'should not include invalid params' do
      Payme::Request.new(300).parse_http_params.should_not include(:http_host, :http_port, :request_uri)
    end
  end
end
