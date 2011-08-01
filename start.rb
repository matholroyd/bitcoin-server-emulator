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
  
  puts " data => #{data.inspect}"
  
  method = data['method']
  params = data['params']
  
  begin
    result = {'result' => wallet.send(method, *params)}
  rescue ArgumentError
    result = {"code" => -1, "message" => "Wrong number of arguments"}
  end
  
  puts " result => #{result.to_json}"
  result.to_json
end

def wallet
  @wallet ||= Wallet.new
end

