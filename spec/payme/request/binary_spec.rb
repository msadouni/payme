# encoding: UTF-8
require 'spec_helper'

describe Payme::RequestBinary do
  
  describe 'launch' do
    
    it 'should raise an error api call error if the result is an empty string' do
      request = Payme::Request.new(300)
      request.expects(:exec).once.returns('')
      lambda do
        request.launch
      end.should raise_error Payme::Errors::MissingPath
    end
    
    it 'should raise an error api call if there is no error and no code' do
      request = Payme::Request.new(300)
      request.expects(:exec).once.returns('!!!')
      lambda do
        request.launch
      end.should raise_error Payme::Errors::MissingPath
    end

    it 'should raise an error api call error if the http result is not 200' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      request = Payme::Request.new(300)
      stub_request(:post, request.options[:http_host] + request.options[:request_uri]).to_return(:status => 500, :body => "", :headers => {})
      lambda do
        request.launch
      end.should raise_error Payme::Errors::HttpError
    end

    it 'should raise an error api call if the http calls returns no form' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      request = Payme::Request.new(300)
      stub_request(:post, request.options[:http_host] + request.options[:request_uri]).to_return(:status => 200, :body => "<CENTER>Error</CENTER>")
      lambda do
        request.launch
      end.should raise_error Payme::Errors::InvalidHttpParameters
    end
    
    it 'should return the form' do
      request = Payme::Request.new(300)
      request.expects(:exec).once.returns('!0!!Some Form')
      request.launch.should eql(['', '0', '', 'Some Form'])
    end

    it 'should return the form after a successful http call' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      request = Payme::Request.new(300)
      form = YAML::load(File.open('spec/fixtures/form_data.yml'))['form_data']
      expected_result = ['', '0', '', form]
      stub_request(:post, request.options[:http_host] + request.options[:request_uri]).to_return(:status => 200, :body => form)
      request.launch.should eql(expected_result)
    end
  end
  
  describe 'exec' do
    it 'should execute the binary with basic  options' do
      request = Payme::Request.new(300)
      request.expects(:`).with("/request #{request.parse_params}").once
      request.send(:exec)
    end
    
    it 'should execute the binary with a defined path' do
      request = Payme::Request.new(300, :bin_path => '/bin')
      request.expects(:`).with("/bin/request #{request.parse_params}").once
      request.send(:exec)
    end
    
    it "should return an empty string if there is no result" do
      request = Payme::Request.new(300, :bin_path => '/bin')
      request.expects(:`).with("/bin/request #{request.parse_params}").once.returns(nil)
      request.send(:exec).should eql('')
    end
  end

  describe 'call' do
    before :each do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
    end
    it 'should make the http request' do
      request = Payme::Request.new(300)
      url = request.options[:http_host] + request.options[:request_uri]
      expected_body = "merchant_id=#{request.options[:merchant_id]}&merchant_country=#{request.options[:merchant_country]}&currency_code=#{request.options[:currency_code]}&pathfile=%2fpathfile&amount=#{request.amount}"
      stub_request(:post, url).with(:body => expected_body)
      request.send(:call)
      WebMock.should have_requested(:post, url).with(:body => expected_body)
    end

    it 'should make the http request on specified port' do
      request = Payme::Request.new(300, :http_port => 8081)
      url = "#{request.options[:http_host]}:8081#{request.options[:request_uri]}"
      stub_request(:post, url)
      request.send(:call)
      WebMock.should have_requested(:post, url)
    end
  end
end
