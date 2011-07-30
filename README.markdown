# BitCoin Server Emulator

A basic Sinatra app to emulate the JSON-RPC commands of the open source BitCoin server daemon, for testing purposes.  It is in used to speed up tests for [BitPiggy](http://bitpiggy.com).

## Why emulate the BitCoin server?

In a word: speed. BitCoin transactions take on average ~10 minutes to be verified by the BitCoin network, and thats on the live network. On the testnet BitCoin blockchain, transactions can take hours to process. Hence trying to run tests on the live or test blockchain could take literally days to get results, not to mention cost money in BitCoin transaction fees.

