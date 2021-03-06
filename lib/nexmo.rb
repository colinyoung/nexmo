require 'net/http'
require 'net/https'
require 'json'
require 'uri'

module Nexmo
  class Client
    
    GET_HEADERS = {'Accept' => 'application/json'}
    
    def initialize(key, secret)
      @key, @secret = key, secret

      @headers = {'Content-Type' => 'application/x-www-form-urlencoded'}

      @http = Net::HTTP.new('rest.nexmo.com', 443)

      @http.use_ssl = true
    end

    attr_accessor :key, :secret, :http, :headers
    
    # Messages
    def send_message(data)
      response = @http.post('/sms/json', encode(data), headers)

      object = JSON.parse(response.body)['messages'].first

      status = object['status'].to_i

      if status == 0
        Response.new(message_id: object['message-id'])
      else
        Response.new(Error.new("#{object['error-text']} (status=#{status})"))
      end
    end
    
    # Account
    def account_balance
      response = @http.get('/account/get-balance' + url_credentials, headers.merge(GET_HEADERS))
      
      if response.body.length == 0 # Nexmo returns a 200, but no data, if invalid credentials.
        return Failure.new(Error.new("Invalid credentials"))
      end
      
      balance = JSON.parse(response.body)
      
      if balance
        Response.new(value: balance['value'])
      else
        Response.new(Error.new("Unexpected error."))
      end
    end

    private

    def encode(data)
      URI.encode_www_form data.merge(:username => @key, :password => @secret)
    end
    
    def url_credentials
      "/#{@key}/#{@secret}"
    end
  end

  class Status
    def initialize(hashOrError)
      @data = hash
    end
    
    def method_missing(name)
      @data[name]
    end
    
    def success?
      !@data.is_a? Error
    end

    def failure?
      @data.is_a? Error
    end
  end
  
  class Error < StandardError
  end
end
