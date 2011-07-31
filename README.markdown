# BitCoin Server Emulator

A basic Sinatra app to emulate the JSON-RPC commands of the open source BitCoin server daemon, for testing purposes.  It is in used to speed up tests for [BitPiggy](http://bitpiggy.com).

## Why emulate the BitCoin server?

In a word: speed. BitCoin transactions take on average ~10 minutes to be verified by the BitCoin network, and thats on the live network. On the testnet BitCoin blockchain transactions can take hours to process. Hence trying to run tests on the live or test blockchain could take literally days to get results, not to mention cost money in BitCoin transaction fees.

## What if the BitCoin server API changes?

If it does change, we'll have to update this code. Please let me know if this happens!

That said, considering the wide adoptance of the current open source project and hence its current API, it seems highly unlikely the API would change. The managers of the open source project would upset a lot of people if they changed the API, at least for the core methods.  On top of that, the current API works fine, so why would they change it?

## Command reference

    backupwallet <destination>

    getaccount <bitcoinaddress>
    getaccountaddress <account>
    getaddressesbyaccount <account>
    getbalance [account] [minconf=1]
    getblockcount
    getblocknumber
    getconnectioncount
    getdifficulty
    getgenerate
    gethashespersec
    getinfo
    getreceivedbyaccount <account> [minconf=1]
    getreceivedbyaddress <bitcoinaddress> [minconf=1]
    gettransaction <txid>
    getwork [data]

    help [command]

    listaccounts [minconf=1]
    listreceivedbyaccount [minconf=1] [includeempty=false]
    listreceivedbyaddress [minconf=1] [includeempty=false]
    listtransactions [account] [count=10]

    getnewaddress [account]

    move <fromaccount> <toaccount> <amount> [minconf=1] [comment]
    sendfrom <fromaccount> <tobitcoinaddress> <amount> [minconf=1] [comment] [comment-to]
    sendmany <fromaccount> {address:amount,...} [minconf=1] [comment]
    sendtoaddress <bitcoinaddress> <amount> [comment] [comment-to]
    setaccount <bitcoinaddress> <account>
    setgenerate <generate> [genproclimit]

    stop
    validateaddress <bitcoinaddress>
