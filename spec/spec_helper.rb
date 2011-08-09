require File.dirname(__FILE__) + '/../wallet'

BitCoinAddressRexExp = /^1[#{Wallet::Base58Chars}]{33}$/
TestPath = File.dirname(__FILE__) + '/../bitcoin-wallet.cache.test'

def bg(amount)
  BigDecimal.new(amount.to_s)
end
