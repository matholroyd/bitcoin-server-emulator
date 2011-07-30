require 'sinatra'
require 'json'
require './wallet'

get '/' do

end

post '/' do
  process_jsonrpc(params)
end

def process_jsonrpc(params)
  data = JSON.parse request.body.read
  
  puts "data => #{data.inspect}"
  
  method = data['method']
  
  result = wallet.send(method)
  result.to_json
end

def wallet
  @wallet ||= Wallet.new
end

