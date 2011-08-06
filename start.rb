require 'sinatra'
require 'json'
require './wallet'

post '/' do
  process_jsonrpc
end

post '/:name' do |db_name|
  process_jsonrpc(db_name)
end

def process_jsonrpc(db_name = 'bitcoin-wallet')
  data = JSON.parse request.body.read
  
  puts " db-name => #{db_name}"
  puts " data => #{data.inspect}"
    
  begin
    result = {'result' => wallet(db_name).send(data['method'], *data['params'])}
  rescue ArgumentError
    result = {"code" => -1, "message" => "Wrong number of arguments"}
  end
  
  puts " result => #{result.to_json}"
  result.to_json
end

def wallet(name)
  dir = File.dirname(__FILE__) + "/tmp"
  `mkdir #{dir}` unless Dir.exists?(dir)

  path = "#{dir}/#{name}.cache"
  Wallet.new(path)
end

