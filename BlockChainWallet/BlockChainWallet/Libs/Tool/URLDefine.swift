//
//  URLDefine.swift
//  BlockChainWallet
//
//  Created by user on 2021/3/19.
//

import Foundation

let btcApiKey = "dffbba3e3f6d4824ba8bd9ed57d3fb6f"
let ethApiKey = "945FN2WEW1TDQ2URGXVPSN9S5H7E6CHXQN"
let hecoApiKey = "PGKI9S46WRYMNCB1MGISDG2FHZJF9S892Q"
let bscApiKey = "ASXJXN16B1UYFBNUDCPPSKVM53EJHW1ERD"

let isMainNet = false
let netType: Network = isMainNet ? .mainnet : .testnet
let ethUrl = isMainNet ? "https://api-cn.etherscan.com" : "https://api-kovan.etherscan.io"
let btcUrl = isMainNet ? "https://api.blockcypher.com/v1/btc/main" : "https://api.blockcypher.com/v1/btc/test3"
let hecoUrl = isMainNet ? "https://api.hecoinfo.com" : "https://api-testnet.hecoinfo.com"
let bscUrl = isMainNet ? "https://api.bscscan.com" : "https://api-testnet.bscscan.com"

let ethChainId = isMainNet ? 1 : 42
let hecoChainId = isMainNet ? 128 : 256
let bscChainId = isMainNet ? 56 : 97

//btc url
let btcBalanceUrl = "\(btcUrl)/addrs/%@/balance"
let btcUtxoUrl = "\(btcUrl)/addrs/%@?unspentOnly=true&includeScript=true"
let btcPushTx = "\(btcUrl)/txs/push?token=\(btcApiKey)"

//eth,heco,bsc universal url
let pushUrl = "/api?module=proxy&action=eth_sendRawTransaction&hex=%@&apikey="
let nonceUrl = "/api?module=proxy&action=eth_getTransactionCount&address=0x%@&tag=latest&apikey="
let balanceUrl = "/api?module=account&action=balance&address=0x%@&tag=latest&apikey="
