require File.dirname(__FILE__) + '/../spec_helper'


describe Wallet do
  let(:wallet) { Wallet.new(TestPath).helper_reset }
  let(:addressA) { wallet.getnewaddress("A") }
  let(:addressB) { wallet.getnewaddress("B") }
  let(:external_address) { wallet.helper_random_address }

  describe "move" do
    
    before :each do
      wallet.helper_set_time(999)
      wallet.move("A", "B", bg(3)).should == true
    end
      
    it do
      wallet.getbalance.     should == bg(0)
      wallet.getbalance("A").should == bg(-3)
      wallet.getbalance("B").should == bg(3)
    end
    
    it do
      wallet.listaccounts.should == {"" => bg(0), "A" => bg(-3), "B" => bg(3)}
    end
    
    it do
      wallet.listtransactions.should == [
        {
             "account" => "B",
             "category" => "move",
             "time" => 999,
             "amount" => bg(3),
             "otheraccount" => "A",
             "comment" => ""
         },
         {
             "account" => "A",
             "category" => "move",
             "time" => 999,
             "amount" => -bg(3),
             "otheraccount" => "B",
             "comment" => ""
         }
      ]
    end
    
    context "second move" do
      before :each do
        wallet.move("A", "C", bg(2)).should == true
      end
      
      it do
        wallet.getbalance.     should == bg(0)
        wallet.getbalance("A").should == bg(-5)
        wallet.getbalance("B").should == bg(3)
        wallet.getbalance("C").should == bg(2)
      end

      it do
        wallet.listaccounts.should == {"" => bg(0), "A" => bg(-5), "B" => bg(3), "C" => bg(2)}
      end

      it do
        wallet.listtransactions.should == [
          {
               "account" => "B",
               "category" => "move",
               "time" => 999,
               "amount" => bg(3),
               "otheraccount" => "A",
               "comment" => ""
           },
           {
               "account" => "A",
               "category" => "move",
               "time" => 999,
               "amount" => -bg(3),
               "otheraccount" => "B",
               "comment" => ""
           },
           {
                "account" => "C",
                "category" => "move",
                "time" => 999,
                "amount" => bg(2),
                "otheraccount" => "A",
                "comment" => ""
            },
            {
                "account" => "A",
                "category" => "move",
                "time" => 999,
                "amount" => -bg(2),
                "otheraccount" => "C",
                "comment" => ""
            }
        ]
      end
      
    end
  
  end
end
