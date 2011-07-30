require 'pstore'
require 'bigdecimal'

class Wallet
  Base58Chars = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a - %w{0 O I l}
  
  attr_reader :db_path
  
  def initialize(db_path = 'bitcoin-wallet.cache')
    @db_path = db_path
  end
  
  def reset
    db.transaction do
      db.delete(:balance)
      db.delete(:accounts)
      db.delete(:addresses)
    end
    self
  end
  
  def getbalance
    db.transaction do 
      balance = db.fetch(:balance, BigDecimal.new('0.0'))
      {'balance' => balance.to_s}
    end
  end
  
  def listaccounts
    {'' => '0.00000000'}
  end
  
  def getnewaddress 
    result = "1" + (1..33).collect { Base58Chars[rand(Base58Chars.length)] }.join
    t_accounts do |accounts|
      accounts[""].addresses << result 
    end
    result
  end
  
  def getaddressesbyaccount(account_name)
    t_accounts[account_name].addresses
  end
  
  private
  
  def t_accounts(&block)
    db.transaction do 
      accounts = db.fetch(:accounts,  {"" => Account.new("", []) })
      yield(accounts) if block
      db[:accounts] = accounts
      accounts
    end
  end
            
  def db
    @db ||= PStore.new(db_path)
  end
  
  class Account < Struct.new(:name, :addresses)
  end
end

