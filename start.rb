require 'sinatra'
require 'json'
require 'erb'
require './wallet'
  
set :views, File.dirname(__FILE__) + '/view'

get '/' do
  ensure_tmp
  @dbs = Dir['tmp/*.cache'].collect {|p| p.sub(/^tmp\//, '').sub(/\.cache$/, '')}
  
  erb :'index.html'
end

get '/:name' do |db_name|
  @db_name = db_name
  @accounts = wallet(db_name).listaccounts
  
  erb :'db.html'
end

get '/:name/adjust_balance' do |db_name|
  wallet(db_name).simulate_incoming_payment(
    wallet(db_name).getnewaddress(params[:account]),
    params[:amount].to_i
  )

  redirect "/#{db_name}"
end

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

def tmp_dir
  File.dirname(__FILE__) + "/tmp"
end

def ensure_tmp
  `mkdir #{tmp_dir}` unless Dir.exists?(tmp_dir)
end

def wallet(name)
  ensure_tmp
  
  path = "#{tmp_dir}/#{name}.cache"
  Wallet.new(path)
end

