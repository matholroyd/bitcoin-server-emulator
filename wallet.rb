require 'pstore'
require 'bigdecimal'

class Wallet
  Base58Chars = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a - %w{0 O I l}
  
  attr_reader :db_path
  
  def initialize(db_path = 'bitcoin-wallet.cache')
    @db_path = db_path
  end
  
  def getbalance(account_name = "")
    ensure_account(account_name)
    
    {'balance' => t_accounts[account_name].balance}
  end
  
  def listaccounts
    {'' => BigDecimal.new('0')}
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
  
  # Testing methods
  
  def test_adjust_balance(account_name, amount)
    t_accounts do |accounts|
      accounts[account_name].balance = amount
    end
  end
  
  def test_reset
    File.delete(db.path) if File.exists?(db.path)
    self
  end
  
  private
  
  def ensure_account(account_name)
    db.transaction do 
      accounts = db[:accounts] || {}
      if accounts[account_name].nil?
        accounts[account_name] = Account.new(account_name, [], BigDecimal.new('0'))
      end
      db[:accounts] = accounts
    end
  end
  
  def t_accounts(&block)
    ensure_account("")
    
    db.transaction do 
      accounts = db[:accounts]
      yield(accounts) if block
      db[:accounts] = accounts
      db[:accounts]
    end
  end
            
  def db
    @db ||= PStore.new(db_path)
  end
  
  class Account < Struct.new(:name, :addresses, :balance)
  end
end

