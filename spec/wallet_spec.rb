require File.dirname(__FILE__) + '/../wallet'

BitCoinAddressRexExp = /^1[#{Wallet::Base58Chars}]{33}$/
TestPath = File.dirname(__FILE__) + '/../bitcoin-wallet.cache.test'

def bg(amount)
  BigDecimal.new(amount.to_s)
end

describe Wallet do
  let(:wallet) { Wallet.new(TestPath).test_reset }
  
  context 'getbalance' do
    it do
      wallet.getbalance.should == {'balance' => bg(0)}
    end

    it do
      wallet.getbalance("some-account").should == {'balance' => bg(0)}
    end
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
      result.first.should == ["", bg(0)]
    end
  end
  
  context 'getaccount' do
    it do 
      address = wallet.getnewaddress
      wallet.getaccount(address).should == ""
    end
  end
  
  context 'getreceivedbyaddress' do
    it do
      address = wallet.getnewaddress
      wallet.getreceivedbyaddress(address).should == bg(0)
    end
    
    # it do
    #   address = wallet.getnewaddress
    #   wallet.test_incoming_payment address, bg(7)
    #   wallet.getreceivedbyaddress(address).should == bg(7)
    # end
  end
  
  describe 'interface for testing' do

    it 'should adjust the balance' do
      wallet.test_adjust_balance("", bg(1.5))
      wallet.getbalance.should == {'balance' => bg(1.5)}
    end
    
  end
  
end