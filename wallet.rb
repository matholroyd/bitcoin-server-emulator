require 'pstore'
require 'bigdecimal'

class Wallet
  Base58Chars = ('a'..'z').to_a + ('A'..'Z').to_a + (0..9).to_a - %w{0 O I l}
  Base16Chars = (0..9).to_a + ('a'..'f').to_a
  DefaultPath = File.dirname(__FILE__) + '/bitcoin-wallet.cache'
  
  attr_reader :db_path
  
  def initialize(db_path = DefaultPath)
    @db_path = db_path
    
    t_ensure_account("")
  end
  
  def getbalance(account_name = nil)
    if account_name
      t_accounts[account_name] ? t_accounts[account_name].balance : bg(0)
    else
      t_accounts.collect {|name, a| a}.inject(0) {|sum, a| sum += a.balance}
    end
  end
  
  def listaccounts
    result = {}
    t_accounts.each do |account_name, account|
      result[account_name] = account.balance
    end
    result
  end
  
  def getnewaddress(account_name = "")
    result = helper_random_address

    t_ensure_account(account_name)

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
    t_ensure_account(from_name)
    t_ensure_account(to_name)
    
    t_accounts do |accounts|
      from = accounts[from_name]
      to = accounts[to_name]
      
      from.balance -= amount
      to.balance += amount
    end
    true
  end
  
  def listtransactions
    t_transactions
  end

  def sendfrom(from_name, to_address, amount)
    to_name = t_addresses[to_address]
    fee = t_fee

    t_accounts do |accounts|
      from = accounts[from_name]
      to = accounts[to_name]
      
      from.balance -= (amount + fee)
      if to
        to.balance += amount 
      end
    end
    
    tx_hash, txid = t_transaction_grouped_hash(from_name, to_address, amount)
    t_transactions_grouped do |transactions_grouped|
      transactions_grouped[txid] = tx_hash
     end
    txid
  end
  
  def gettransaction(txid)
    t_transactions_grouped[txid]
  end
  
  # Simlulate methods
    
  def simulate_incoming_payment(address, amount)
    account_name = t_addresses[address]
    
    t_accounts do |accounts|
      account = accounts[account_name]
      account.balance += amount
      account.addresses[address].balance += amount
    end
  end
  
  # helper methods

  def helper_reset
    File.delete(db.path) if File.exists?(db.path)
    t_ensure_account("")
    self
  end
  
  def helper_random_address
    "1" + (1..33).collect { random_char(Base58Chars) }.join
  end
  
  def helper_random_txid
    (1..64).collect { random_char(Base16Chars) }.join
  end
  
  def helper_set_fee(fee)
    db.transaction do 
      db[:fee] = fee
    end
  end

  def helper_set_confirmations(confirmations)
    db.transaction do 
      db[:confirmations] = confirmations
    end
  end

  def helper_set_time(time)
    db.transaction do 
      db[:time] = time
    end
  end

  def helper_adjust_balance(account_name, amount)
    t_ensure_account(account_name)
    
    t_accounts do |accounts|
      accounts[account_name].balance = amount
    end
  end
  
  private
  
  def t_transaction_grouped_hash(from_name, to_address, amount)
    txid = helper_random_txid
    
    tx_hash = {
      "amount" => -amount,
      "fee" => -t_fee,
      "confirmations" => t_confirmations,
      "txid" => txid,
      "time" => t_time,
      "details" => [
        {
          "account" => from_name,
          "address" => to_address,
          "category" => "send",
          "amount" => -amount
        }
      ]
    }
    
    if t_fee > bg(0)
      tx_hash['details'].first['fee'] = -t_fee
    end

    to_name = t_addresses[to_address]
    if to_name
      t_accounts do |accounts|
        to = accounts[to_name]
      
        tx_hash['amount'] = bg(0)
        tx_hash['details'] << {
          "account" => to_name,
          "address" => to_address,
          "category" => "receive",
          "amount" => amount
        }
      end
    end
    
    [tx_hash, txid]
  end
  
  def random_char(chars)
    chars[rand(chars.length)]
  end
  
  def bg(amount)
    BigDecimal.new(amount.to_s)
  end
  
  def t_ensure_account(account_name)
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
    end
  end
    
  def t_addresses(&block)
    db.transaction do 
      addresses = db[:addresses] || {}
      yield(addresses) if block
      db[:addresses] = addresses
    end
  end

  def t_transactions(&block)
    db.transaction do 
      transactions = db[:transactions] || []
      yield(transactions) if block
      db[:transactions] = transactions
    end
  end

  def t_transactions_grouped(&block)
    db.transaction do 
      transactions_grouped = db[:transactions_grouped] || {}
      yield(transactions_grouped) if block
      db[:transactions_grouped] = transactions_grouped
    end
  end
  
  def t_fee
    db.transaction do 
      db[:fee] ||= bg(0)
    end
  end

  def t_confirmations
    db.transaction do 
      db[:confirmations] ||= 1
    end
  end

  def t_time
    db.transaction do 
      db[:time] ||= 0
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

