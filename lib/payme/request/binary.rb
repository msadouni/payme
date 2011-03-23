# encoding: UTF-8
module Payme
  module RequestBinary
    def self.included(klass)
      klass.class_eval do
        
        #
        # Executes the binary call, gets the datas
        # Validates that the the code is correct
        # And returns the form
        #
        def launch
          if options[:http_host]
            result = call
            raise Payme::Errors::HttpError if result.code != '200'
            raise Payme::Errors::InvalidHttpParameters unless result.body =~ /<form\s/i
            result.body
          else
            result = exec.split('!')
            raise Payme::Errors::MissingPath if result.empty? or (result[1].empty? && result[2].empty?)
            result
          end
        end
        
        private
        #
        # Executes the binary call
        #
        def exec
          path = File.join(options[:bin_path], 'request')
          `#{path} #{parse_params}` || ''
        end

        def call
Net::HTTP.post_form(URI.parse("#{options[:http_host]}:#{options[:http_port] ||= 80}#{options[:request_uri]}"), parse_http_params)
        end
      end
    end
  end
end

Payme::Request.send(:include, Payme::RequestBinary)
