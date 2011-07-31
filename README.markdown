# BitCoin Server Emulator

A basic Sinatra app to emulate the JSON-RPC commands of the open source BitCoin server daemon, for testing purposes.  It is in used to speed up tests for [BitPiggy](http://bitpiggy.com).

## Why emulate the BitCoin server?

In a word: speed. BitCoin transactions take on average ~10 minutes to be verified by the BitCoin network, and thats on the live network. On the testnet BitCoin blockchain transactions can take hours to process. Hence trying to run tests on the live or test blockchain could take literally days to get results, not to mention cost money in BitCoin transaction fees.

## What if the BitCoin server API changes?

If it does change, we'll have to update this code. Please let me know if this happens!

That said, considering the wide adoptance of the current open source project and hence its current API, with literally millions of dollars on the line, change is likely to be slow. The managers of the open source project would upset a lot of people if they changed the core methods of the API.  

As said above though, please send me a message (on GitHub) if the interface changes! 

# Installing and running

Currently this is not a gem, so you'll need to clone this repository to a directory.

    git clone git://github.com/matholroyd/bitcoin-server-emulator.git
    
The app is a [Sinatra app](http://sinatrarb.com), so to run it you will need to install Sinatra:
    
    gem install sinatra

To run, use the following in the directory you cloned this repository to:

    ruby -rubygems start.rb (defaults to port 4567)

Or if you prefer to use Shotgun:

    gem install shotgun
    shotgun start.rb  (defaults to port 9393)
    


## Command reference - impletemented 

Note that for the following the `[minconf=1]` option is not implemented.

    getbalance [account] [minconf=1]
    getaccount <bitcoinaddress>
    getreceivedbyaccount <account> [minconf=1]
    getreceivedbyaddress <bitcoinaddress> [minconf=1]
    getaddressesbyaccount <account>
    listaccounts [minconf=1]

    getnewaddress [account]

## Command reference - to impletement

    sendfrom <fromaccount> <tobitcoinaddress> <amount> [minconf=1] [comment] [comment-to]
    move <fromaccount> <toaccount> <amount> [minconf=1] [comment]
    listtransactions [account] [count=10]

## Command reference - not impletemented

    backupwallet <destination>

    getaccountaddress <account>
    getblockcount
    getblocknumber
    getconnectioncount
    getdifficulty
    getgenerate
    gethashespersec
    getinfo
    gettransaction <txid>
    getwork [data]

    help [command]

    listreceivedbyaccount [minconf=1] [includeempty=false]
    listreceivedbyaddress [minconf=1] [includeempty=false]

    sendmany <fromaccount> {address:amount,...} [minconf=1] [comment]
    sendtoaddress <bitcoinaddress> <amount> [comment] [comment-to]
    setaccount <bitcoinaddress> <account>
    setgenerate <generate> [genproclimit]

    stop
    validateaddress <bitcoinaddress>

