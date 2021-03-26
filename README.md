# BlockChainWallet
This is a blockchain wallet, which imitates imToken and integrates the core code of [imToken open source](https://github.com/consenlabs/token-core-ios).  
You can use this APP to test the transaction of BTC or ETH on testnet or mainnet.  

## Installation and Run the Example   
I've already uploaded all files, just download and run it.  

## Try the APP
### Create new Identity and backup mnemonic words
<img src="SampleImage/CreateIdentity.PNG" width="300" alt="CreateIdentity"/>    <img src="SampleImage/SetPassword.PNG" width="300" alt="SetPassword"/>    <img src="SampleImage/Backup.PNG" width="300" alt="Backup"/>

### Use Faucet to get test coins and check the balance on home page
BTC faucet:  
https://coinfaucet.eu/en/btc-testnet/  
ETH faucet:  
https://faucet.kovan.network/  
<img src="SampleImage/HomePage.PNG" width="375" alt="HomePage"/>

### Transfer test and check the transaction result on explore
BTC explore:  
https://live.blockcypher.com/btc-testnet/  
ETH explore:  
https://kovan.etherscan.io/  
<img src="SampleImage/Transfer.PNG" width="375" alt="Transfer"/>

## Troubleshooting
If you use pod to re-import third-party frameworks, the bigInt framework will have problems due to version reasons, please follow the simulator prompts to modify the code.  

## TODO
- [ ] Transfer USDT on Omni
- [ ] Recover Identity
- [ ] Switch address mode(Legal address or Segwit address)
- [ ] Import wallet from mnemonic words
- [ ] Import BTC wallet from WIF
- [ ] Import ETH wallet from private key
- [ ] Import ETH wallet from keystore
- [ ] Select or custom miner fee for different transaction speed
- [ ] Backup mnemonic words
- [ ] Scan code

## Thanks and more info
Thanks imToken open source.

