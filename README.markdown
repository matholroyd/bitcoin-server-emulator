# BitCoin Server Emulator

A basic Sinatra app to emulate the JSON-RPC commands of the open source BitCoin server daemon, for testing purposes.  It is in used to speed up tests for [BitPiggy](http://bitpiggy.com).

**Why emulate the BitCoin server?**

In a word, **speed**. 

BitCoin transactions take on average ~10 minutes to be verified by the BitCoin network, and thats on the live network. On the testnet BitCoin blockchain transactions can take hours to process. Hence trying to run tests on the live or test blockchain could take literally days to get results, not to mention cost money in BitCoin transaction fees.

**What if the BitCoin server API changes?**

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
    
# Using

To interact with the running server, you'll need to send POST requests to the bitcoin server emulator's URL.  The 

The below code is a snippet on the [BitCoin forum](https://en.bitcoin.it/wiki/API_reference_(JSON-RPC\)) for sending POST requests in Ruby:

    =begin
    Make sure to do:
        gem install rest-client
 
    Usage:
        h = ServiceProxy.new('http://user:password@127.0.0.1:8332')
        puts h.getinfo.call
        puts h.getbalance.call 'accname'
    =end
    require 'json'
    require 'rest_client'
 
    class JSONRPCException < RuntimeError
        def initialize()
            super()
        end
    end
 
    class ServiceProxy
        def initialize(service_url, service_name=nil)
            @service_url = service_url
            @service_name = service_name
        end
 
        def method_missing(name, *args, &block)
            if @service_name != nil
                name = "%s.%s" % [@service_name, name]
            end
            return ServiceProxy.new(@service_url, name)
        end
 
        def respond_to?(sym)
        end
 
        def call(*args)
            postdata = {"method" => @service_name, "params" => args, "id" => "jsonrpc"}.to_json
            respdata = RestClient.post @service_url, postdata
            resp = JSON.parse respdata
            if resp["error"] != nil
                raise JSONRPCException.new, resp['error']
            end
            return resp['result']
        end
    end


# Command reference

**Implemented**

Note that for the following the `[minconf=1]` and `[comment]` options are not implemented.

    getbalance [account] [minconf=1]
    getaccount <bitcoinaddress>
    getreceivedbyaccount <account> [minconf=1]
    getreceivedbyaddress <bitcoinaddress> [minconf=1]
    getaddressesbyaccount <account>
    listaccounts [minconf=1]

    getnewaddress [account]
    move <fromaccount> <toaccount> <amount> [minconf=1] [comment]

**To be implemented**

    sendfrom <fromaccount> <tobitcoinaddress> <amount> [minconf=1] [comment] [comment-to]
    listtransactions [account] [count=10]
    gettransaction <txid>

**Not implemented**

    backupwallet <destination>

    getaccountaddress <account>
    getblockcount
    getblocknumber
    getconnectioncount
    getdifficulty
    getgenerate
    gethashespersec
    getinfo
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

