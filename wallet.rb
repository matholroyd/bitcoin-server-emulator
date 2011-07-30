require 'pstore'

class Wallet
  def getbalance
    db.transaction do 
      db[:balance] ||= '0.0' 
      {'balance' => '0.0'}
    end
  end
  
  private
  
  def db
    @db ||= PStore.new('bitcoin-wallet.cache')
  end
end