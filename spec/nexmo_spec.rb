require 'minitest/autorun'
require 'mocha'

if ARGV.length < 2
  raise "You must call nexmo_spec.rb from the command line with two arguments: the key, then the secret.
        Optionally, you can issue a 3rd argument (a phone number) to be actually texted w/ the send_message test.
        NOTE! You may need a 4th argument, one of your from numbers, if your 'To:' number is in certain regions."
end

require_relative '../lib/nexmo'

describe Nexmo::Client do
  before do    
    @client = Nexmo::Client.new(ARGV.first, ARGV[1])
  end

  describe 'http method' do
    it 'should return a Net::HTTP object that uses SSL' do
      @client.http.must_be_instance_of(Net::HTTP)
      @client.http.use_ssl?.must_equal(true)
    end
  end

  describe 'headers method' do
    it 'should return a hash' do
      @client.headers.must_be_kind_of(Hash)
    end
  end

  describe 'send_message method' do
    before do
      @headers = {'Content-Type' => 'application/x-www-form-urlencoded'}
    end

    it 'should text the number successfully if a number is given' do
      if ARGV.length < 3
        puts "[WARNING] send_message not tested, the number wasn't given."
        return true
      end
      
      data = {
        from: ARGV[3],
        to: ARGV[2],
        text: "Test from minitest on #{DateTime.now.to_time}",
        username: @client.key,
        password: @client.secret
      }

      response = @client.send_message(data)

      response.success?.must_equal(true)
      response.failure?.must_equal(false)
    end
  end
  
  describe 'account_balance method' do
    it 'should return the balance value in euro' do
      response = @client.account_balance
      
      response.failure?.must_equal(false)
      
      (response.value.is_a? ::Float).must_equal(true)
      
      response.success?.must_equal(true)
    end
  end
end
