require 'pstore'
require 'bigdecimal'

class Wallet
  Base58Chars = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a - %w{0 O I l}
  
  attr_reader :db_path
  
  def initialize(db_path = 'bitcoin-wallet.cache')
    @db_path = db_path
    
    ensure_account("")
  end
  
  def getbalance(account_name = "")
    balance = t_accounts[account_name] ? t_accounts[account_name].balance : bg(0)
    {'balance' => balance}
  end
  
  def listaccounts
    result = {}
    t_accounts.each do |account_name, account|
      result[account_name] = account.balance
    end
    result
  end
  
  def getnewaddress(account_name = "")
    result = "1" + (1..33).collect { Base58Chars[rand(Base58Chars.length)] }.join

    ensure_account(account_name)

    address = Address.new(result, bg(0))
    t_accounts do |accounts|
      accounts[account_name].addresses[result] = address
    end
    t_addresses do |addresses|
      addresses[address.address] = account_name
    end
    result
  end
  
  def getaccount(address)
    t_addresses[address]
  end
    
  def getaddressesbyaccount(account_name)
    
    if t_accounts[account_name]
      t_accounts[account_name].addresses.collect {|raw_address, address| raw_address}
    else
      []
    end
  end
  
  def getreceivedbyaddress(address)
    account_name = t_addresses[address]
    t_accounts[account_name].addresses[address].balance
  end
  
  def move(from_name, to_name, amount)
    t_accounts do |accounts|
      from = accounts[from_name]
      to = accounts[to_name]
      
      from.balance -= amount
      to.balance += amount
    end
  end

  def sendfrom(from_name, to_address, amount)
    to_name = t_addresses[to_address]
    
    t_accounts do |accounts|
      from = accounts[from_name]
      to = accounts[to_name]
      
      from.balance -= amount
      to.balance += amount
    end
  end
  
  # Testing methods
  
  def test_reset
    File.delete(db.path) if File.exists?(db.path)
    ensure_account("")
    self
  end

  def test_adjust_balance(account_name, amount)
    ensure_account(account_name)
    
    t_accounts do |accounts|
      accounts[account_name].balance = amount
    end
  end
  
  def test_incoming_payment(address, amount)
    account_name = t_addresses[address]
    
    t_accounts do |accounts|
      account = accounts[account_name]
      account.balance += amount
      account.addresses[address].balance += amount
    end
  end
  
  private
  
  def bg(amount)
    BigDecimal.new(amount.to_s)
  end
  
  def ensure_account(account_name)
    db.transaction do 
      accounts = db[:accounts] || {}
      if accounts[account_name].nil?
        accounts[account_name] = Account.new(account_name, {}, bg(0))
      end
      db[:accounts] = accounts
    end
  end
  
  def t_accounts(&block)
    db.transaction do 
      accounts = db[:accounts]
      yield(accounts) if block
      db[:accounts] = accounts
      db[:accounts]
    end
  end
    
  def t_addresses(&block)
    db.transaction do 
      addresses = db[:addresses] || {}
      yield(addresses) if block
      db[:addresses] = addresses
      db[:addresses]
    end
  end
            
  def db
    @db ||= PStore.new(db_path)
  end
  
  class Account < Struct.new(:name, :addresses, :balance)
  end
  
  class Address < Struct.new(:address, :balance)
  end
end

