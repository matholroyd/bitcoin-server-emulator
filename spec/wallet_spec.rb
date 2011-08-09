require File.dirname(__FILE__) + '/spec_helper'

describe Wallet do
  let(:wallet) { Wallet.new(TestPath).helper_reset }
  let(:addressA) { wallet.getnewaddress("A") }
  let(:addressB) { wallet.getnewaddress("B") }
  let(:external_address) { wallet.helper_random_address }
  
  context "blank slate" do
    it 'getbalance' do
      wallet.getbalance.                should == bg(0)
      wallet.getbalance("").            should == bg(0)
      wallet.getbalance("some-account").should == bg(0)
    end

    it 'getaddressesbyaccount' do 
      wallet.getaddressesbyaccount("").            should == []
      wallet.getaddressesbyaccount("some-account").should == []
    end

    it 'listaccounts' do
      wallet.listaccounts.should == {"" => bg(0)}
    end
    
    it 'listtransactions' do
      wallet.listtransactions.should == []
    end
    
    describe 'methods do not create new accounts' do
      it 'getbalance' do
        wallet.getbalance("new-account")
        wallet.listaccounts.should == {"" => bg(0)}
      end

      it 'getaddressesbyaccount' do
        wallet.getaddressesbyaccount("new-account").should == []
        wallet.listaccounts.should == {"" => bg(0)}
      end
    end
  end
      
  context 'generating addresses for ""' do
    let!(:address) { wallet.getnewaddress }
    
    it 'getnewaddress' do
      address.should =~ BitCoinAddressRexExp
    end
    
    it 'getaddressesbyaccount' do
      wallet.getaddressesbyaccount("").should == [address]      
    end
    
    it 'getaccount' do
      wallet.getaccount(address).should == ""
    end
    
    it 'getreceivedbyaddress' do
      wallet.getreceivedbyaddress(address).should == bg(0)
    end

    it 'listaccounts' do
      wallet.listaccounts == [["", bg(0)]]
    end
    
    it 'listtransactions' do
      wallet.listtransactions.should == []
    end
    
    it do
      a2 = wallet.getnewaddress
      a2.should_not == address
      wallet.getaddressesbyaccount("").should == [address, a2]
    end
  end

  context 'generating addresses for "savings"' do
    let!(:address) { wallet.getnewaddress("savings") }
    
    it 'getnewaddress' do
      address.should =~ BitCoinAddressRexExp
      a2 = wallet.getnewaddress("savings")
      a2.should_not == address
      wallet.getaddressesbyaccount("savings").should == [address, a2]
    end
    
    it 'getaddressesbyaccount' do
      wallet.getaddressesbyaccount("").       should == []      
      wallet.getaddressesbyaccount("savings").should == [address]      
    end
    
    it 'getaccount' do
      wallet.getaccount(address).should == "savings"
    end
    
    it 'getreceivedbyaddress' do
      wallet.getreceivedbyaddress(address).should == bg(0)
    end
    
    it 'listaccounts' do
      wallet.listaccounts.should == {"" => bg(0), "savings" => bg(0)}
    end
    
  end
  
  context "receiving payments" do
    let(:address) { wallet.getnewaddress }
    
    before :each do
      wallet.simulate_incoming_payment address, bg(7)
    end
    
    it do
      wallet.getbalance.should == bg(7)

      wallet.simulate_incoming_payment address, bg(2)
      wallet.getbalance.should == bg(9)
    end
    
    it do
      wallet.getreceivedbyaddress(address).should == bg(7)

      wallet.simulate_incoming_payment address, bg(2)
      wallet.getreceivedbyaddress(address).should == bg(9)
    end
    
    it do
      wallet.listaccounts.should == {"" => bg(7)}

      wallet.simulate_incoming_payment address, bg(2)
      wallet.listaccounts.should == {"" => bg(9)}
    end
  end
  
  context 'simulate interface' do
    it 'should adjust the balance' do
      wallet.helper_adjust_balance("", bg(1.5))
      wallet.getbalance.should == bg(1.5)
    end
  end
    
end