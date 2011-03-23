# encoding: UTF-8
require 'spec_helper'

describe Payme::ResponseBinary do
  
  describe 'launch' do
    it 'should raise an error api call error if the result is an empty string' do
      response = Payme::Response.new('testing')
      response.expects(:exec).once.returns('')
      lambda do
        response.launch
      end.should raise_error Payme::Errors::MissingPath
    end
    
    it 'should raise an error api call if there is no error and no code' do
      response = Payme::Response.new('testing')
      response.expects(:exec).once.returns('!!!')
      lambda do
        response.launch
      end.should raise_error Payme::Errors::MissingPath
    end
    
    it 'should raise an error api call error if the http result is not 200' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      response = Payme::Response.new('testing')
      stub_request(:post, response.options[:http_host] + response.options[:autoresponse_uri]).to_return(:status => 500, :body => "", :headers => {})
      lambda do
        response.launch
      end.should raise_error Payme::Errors::HttpError
    end

    it 'should raise an error api call if the http calls returns an empty string' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      response = Payme::Response.new('testing')
      stub_request(:post, response.options[:http_host] + response.options[:autoresponse_uri]).to_return(:status => 200, :body => "")
      lambda do
        response.launch
      end.should raise_error Payme::Errors::InvalidHttpParameters
    end

    it 'should not raise an error if the number of elements is not equal to the number of fields' do
      response = Payme::Response.new('testing')
      response.expects(:exec).once.returns('!0!!!!!')
      response.launch.should be_kind_of Hash
    end
    
    it 'should get the response elements' do
      response = Payme::Response.new('testing')
      fields = Payme::Response.new('testing').send(:fields)
      response.expects(:exec).once.returns("!#{fields.join('!')}")
      
      launched = response.launch
      launched.should be_kind_of Hash
      launched.should_not be_empty
    end

    it 'should get the response elements from the http call' do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
      response = Payme::Response.new('testing')
      fields = Payme::Response.new('testing').send(:fields)
      stub_request(:post, response.options[:http_host] + response.options[:autoresponse_uri]).to_return(:status => 200, :body => "!#{fields.join('!')}")

      launched = response.launch
      launched.should be_kind_of Hash
      launched.should_not be_empty
    end
  end
  
  describe 'exec' do
    it 'should execute the binary with basic  options' do
      response = Payme::Response.new('testing')
      response.expects(:`).with("/response pathfile=/ message=testing").once
      response.send(:exec)
    end
    
    it 'should execute the binary with a different message' do
      response = Payme::Response.new('42')
      response.expects(:`).with("/response pathfile=/ message=42").once
      response.send(:exec)
    end
    
    it 'should execute the binary with a defined path' do
      response = Payme::Response.new('testing', :bin_path => '/bin')
      response.expects(:`).with("/bin/response pathfile=/ message=testing").once
      response.send(:exec)
    end
    
    it 'should execute the binary with a defined file' do
      response = Payme::Response.new('testing', :pathfile => '/file')
      response.expects(:`).with("/response pathfile=/file message=testing").once
      response.send(:exec)
    end
  end
  
  describe 'call' do
    before :each do
      Payme::Config.set_config('spec/fixtures/http_config.yml', 'test')
    end
    it 'should make the http request with basic http options' do
      response = Payme::Response.new('testing')
      url = response.options[:http_host] + response.options[:autoresponse_uri]
      expected_body = "pathfile=%2fpathfile&message=testing"
      stub_request(:post, url).with(:body => expected_body)
      response.send(:call)
      WebMock.should have_requested(:post, url).with(:body => expected_body)
    end

    it 'should make the http request with a defined file' do
      response = Payme::Response.new('testing', :pathfile => '/file')
      url = response.options[:http_host] + response.options[:autoresponse_uri]
      expected_body = "pathfile=%2ffile&message=testing"
      stub_request(:post, url).with(:body => expected_body)
      response.send(:call)
      WebMock.should have_requested(:post, url).with(:body => expected_body)
    end

    it 'should make the http request on specified port' do
      response = Payme::Response.new('testing', :http_port => 8081)
      url = "#{response.options[:http_host]}:8081#{response.options[:autoresponse_uri]}"
      stub_request(:post, url)
      response.send(:call)
      WebMock.should have_requested(:post, url)
    end
  end

  describe 'parse_result' do
    it 'should parse the results array' do
      fields = Payme::Response.new('testing').send(:fields)
      result = Payme::Response.new('testing').send(:parse_result, fields)
      result.should be_kind_of Hash
      result.should_not be_empty
    end
  end
  
  describe 'fields' do
    it 'should be an array' do
      Payme::Response.new('testing').send(:fields).should be_kind_of Array
    end
    
    it 'should not be empty' do
      Payme::Response.new('testing').send(:fields).should_not be_empty
    end
  end
end
