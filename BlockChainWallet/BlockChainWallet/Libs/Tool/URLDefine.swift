//
//  URLDefine.swift
//  BlockChainWallet
//
//  Created by user on 2021/3/19.
//

import Foundation

let btcApiKey = "dffbba3e3f6d4824ba8bd9ed57d3fb6f"
let ethApiKey = "945FN2WEW1TDQ2URGXVPSN9S5H7E6CHXQN"

let isMainNet = false
let netType: Network = isMainNet ? .mainnet : .testnet
let ethUrl = isMainNet ? "https://api-cn.etherscan.com" : "https://api-kovan.etherscan.io"
let btcUrl = isMainNet ? "https://api.blockcypher.com/v1/btc/main" : "https://api.blockcypher.com/v1/btc/test3"

//btc url
let btcBalanceUrl = "\(btcUrl)/addrs/%@/balance"
let btcUtxoUrl = "\(btcUrl)/addrs/%@?unspentOnly=true&includeScript=true"
let btcPushTx = "\(btcUrl)/txs/push?token=\(btcApiKey)"

//eth url
let ethBalanceUrl = "\(ethUrl)/api?module=account&action=balance&address=0x%@&tag=latest&apikey=\(ethApiKey)"
let ethNonceUrl = "\(ethUrl)/api?module=proxy&action=eth_getTransactionCount&address=0x%@&tag=latest&apikey=\(ethApiKey)"
let ethPushUrl = "\(ethUrl)/api?module=proxy&action=eth_sendRawTransaction&hex=%@&apikey=\(ethApiKey)"
