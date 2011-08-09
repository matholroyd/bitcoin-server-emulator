require File.dirname(__FILE__) + '/../spec_helper'


describe Wallet do
  let(:wallet) { Wallet.new(TestPath).helper_reset }
  let(:addressA) { wallet.getnewaddress("A") }
  let(:addressB) { wallet.getnewaddress("B") }
  let(:external_address) { wallet.helper_random_address }

  describe "simulate_incoming_payment" do
    
    before :each do
      wallet.helper_set_time(999)
      wallet.helper_set_confirmations(555)
    
      @txid = wallet.simulate_incoming_payment(addressA, bg(5))
    end

    it  do
      wallet.listaccounts.should == {"" => bg(0), "A" => bg(5)}
    end
    
    it do
      wallet.getbalance.     should == bg(5)
      wallet.getbalance("A").should == bg(5)
    end
    
    it do
      wallet.gettransaction(@txid).should == {
        "amount" => bg(5),
        "confirmations" => 555,
        "txid" => @txid,
        "time" => 999,
        "details" => [
          {
            "account" => "A",
            "address" => addressA,
            "category" => "receive",
            "amount" => bg(5)
          }
        ]
      }
    end
    
    it do
      wallet.listtransactions.should == [{
        "account" => "A",
        "address" => addressA,
        "category" => "receive",
        "amount" => bg(5),
        "confirmations" => 555,
        "txid" => @txid,
        "time" => 999
      }]
    end
  end
  
end
