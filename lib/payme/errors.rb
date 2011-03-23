# encoding: UTF-8
module Payme
  module Errors
    
    class MissingPath < RuntimeError; end
    class HttpError < RuntimeError; end
    class InvalidFieldsNumber < RuntimeError; end
    class InvalidHttpParameters < RuntimeError; end
  end
end
