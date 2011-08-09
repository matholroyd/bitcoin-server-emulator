require File.dirname(__FILE__) + '/../spec_helper'


describe Wallet do
  let(:wallet) { Wallet.new(TestPath).helper_reset }
  let(:addressA) { wallet.getnewaddress("A") }
  let(:addressB) { wallet.getnewaddress("B") }
  let(:external_address) { wallet.helper_random_address }

  describe "sendfrom" do
    
    before :each do
      wallet.helper_adjust_balance("A", bg(8))
      wallet.helper_set_time(999)
      wallet.helper_set_confirmations(555)
    end
    
    context 'to external - with fee' do
      before :each do
        wallet.helper_set_fee(bg(0.1))
        @txid = wallet.sendfrom "A", external_address, bg(3)
      end
      
      it  do
        wallet.listaccounts.should == {"" => bg(0), "A" => bg(4.9)}
      end
      
      it do
        wallet.getbalance.     should == bg(4.9)
        wallet.getbalance("A").should == bg(4.9)
      end
      
      it do
        wallet.gettransaction(@txid).should == {
          "amount" => bg(-3),
          "fee" => bg(-0.1),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999,
          "details" => [
            {
              "account" => "A",
              "address" => external_address,
              "category" => "send",
              "amount" => bg(-3),
              "fee" => bg(-0.1)
            }
          ]
        }
      end
      
      it do
        wallet.listtransactions.should == [{
          "account" => "A",
          "address" => external_address,
          "category" => "send",
          "amount" => -bg(3),
          "fee" => -bg(0.1),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999
        }]
      end
    end

    context 'to external - no fee' do
      before :each do
        @txid = wallet.sendfrom "A", external_address, bg(3)
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
          "amount" => bg(-3),
          "fee" => bg(0),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999,
          "details" => [
            {
              "account" => "A",
              "address" => external_address,
              "category" => "send",
              "amount" => bg(-3),
              "fee" => bg(0)
            }
          ]
        }
      end
      
      it do
        wallet.listtransactions.should == [{
          "account" => "A",
          "address" => external_address,
          "category" => "send",
          "amount" => -bg(3),
          "fee" => bg(0),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999
        }]
      end
    end
    
    context "to internal - with fee" do
      before :each do
        wallet.helper_set_fee(bg(0.1))
        @txid = wallet.sendfrom "A", addressB, bg(3)
      end
      
      it do
        wallet.listaccounts.should == {"" => bg(0), "A" => bg(4.9), "B" => bg(3)}
      end
      
      it do
        wallet.getbalance.     should == bg(7.9)
        wallet.getbalance("A").should == bg(4.9)
        wallet.getbalance("B").should == bg(3)
      end
      
      it do 
        wallet.gettransaction(@txid).should == {
          "amount" => bg(0),
          "fee" => bg(-0.1),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999,
          "details" => [
            {
              "account" => "A",
              "address" => addressB,
              "category" => "send",
              "amount" => bg(-3),
              "fee" => bg(-0.1)
            },
            {
              "account" => "B",
              "address" => addressB,
              "category" => "receive",
              "amount" => bg(3)
            }
          ]
        }
      end
      
      it do
        wallet.listtransactions.should == [
          {
            "account" => "B",
            "address" => addressB,
            "category" => "receive",
            "amount" => bg(3),
            "confirmations" => 555,
            "txid" => @txid,
            "time" => 999
          },
          {
            "account" => "A",
            "address" => addressB,
            "category" => "send",
            "amount" => -bg(3),
            "fee" => -bg(0.1),
            "confirmations" => 555,
            "txid" => @txid,
            "time" => 999
          }
        ]
      end
    end
    
    context "to internal - no fee" do
      before :each do
        @txid = wallet.sendfrom "A", addressB, bg(3)
      end
      
      it do
        wallet.listaccounts.should == {"" => bg(0), "A" => bg(5), "B" => bg(3)}
      end
      
      it do
        wallet.getbalance.     should == bg(8)
        wallet.getbalance("A").should == bg(5)
        wallet.getbalance("B").should == bg(3)
      end
      
      it do 
        wallet.gettransaction(@txid).should == {
          "amount" => bg(0),
          "fee" => bg(0),
          "confirmations" => 555,
          "txid" => @txid,
          "time" => 999,
          "details" => [
            {
              "account" => "A",
              "address" => addressB,
              "category" => "send",
              "amount" => bg(-3)
            },
            {
              "account" => "B",
              "address" => addressB,
              "category" => "receive",
              "amount" => bg(3)
            }
          ]
        }
      end
      
      it do
        wallet.listtransactions.should == [
          {
            "account" => "B",
            "address" => addressB,
            "category" => "receive",
            "amount" => bg(3),
            "confirmations" => 555,
            "txid" => @txid,
            "time" => 999
          },
          {
            "account" => "A",
            "address" => addressB,
            "category" => "send",
            "amount" => -bg(3),
            "fee" => bg(0),
            "confirmations" => 555,
            "txid" => @txid,
            "time" => 999
          }
        ]
      end
    end
        
  end
end
