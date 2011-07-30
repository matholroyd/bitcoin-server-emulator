require File.dirname(__FILE__) + '/../wallet'

BitCoinAddressRexExp = /^1[#{Wallet::Base58Chars}]{33}$/

describe Wallet do
  let(:wallet) { Wallet.new('bitcoin-wallet.cache.test').reset }
  
  context 'getbalance' do
    it 'begins as 0.0' do
      wallet.getbalance.should == {'balance' => '0.0'}
    end
  end
  
  context 'accounts' do
    
  end
  
  context 'getnewaddress' do
    it do
      wallet.getnewaddress.should =~ BitCoinAddressRexExp
    end
    
    it do
      a1 = wallet.getnewaddress
      a2 = wallet.getnewaddress
      a1.should_not == a2
    end
  end
  
  context 'getaddressesbyaccount' do
    it do 
      wallet.getaddressesbyaccount("").should == []
    end
    
    it do
      a = wallet.getnewaddress
      wallet.getaddressesbyaccount("").should == [a]
      a2 = wallet.getnewaddress
      wallet.getaddressesbyaccount("").should == [a, a2]
    end
  end
  
  context 'listaccounts' do
    it do
      result = wallet.listaccounts
      result.length.should == 1
      result.first.should == ["", '0.00000000']
    end
  end
  
end