require File.dirname(__FILE__) + '/../wallet'

describe Wallet do
  let(:wallet) { Wallet.new }
  
  context 'getbalance' do
    it 'begins as 0.0' do
      wallet.getbalance.should == {'balance' => '0.0'}
    end
  end
  
  context 'accounts' do
    
  end
  
end