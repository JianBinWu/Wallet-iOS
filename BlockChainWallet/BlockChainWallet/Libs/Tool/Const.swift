//
//  Const.swift
//  HuanXiRead
//
//  Created by user on 2020/6/17.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import UIKit

let kScreenH = UIScreen.main.bounds.height
let kScreenW = UIScreen.main.bounds.width
let kScreenWRatio = UIScreen.main.bounds.width / 375

//
let keyWindow = (UIApplication.shared.windows.first)!
let kDocument = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first)!

//chainType
let chainTypeBgColorDic: [ChainType: UIColor] = [.btc: UIColor(hexString: "#FFAB27"), .eth: UIColor(hexString: "#1894BD"), .heco: UIColor(hexString: "#39A95B"), .bsc: UIColor(hexString: "#41444A")]
let chainTypeTxtDic: [ChainType: String] = [.btc: "BTC", .eth: "ETH", .heco: "HECO", .bsc: "BSC"]
let chainTypeImgDic: [ChainType: String] = [.btc: "btcBadge", .eth: "ethBadge", .heco: "", .bsc: ""]
let chainIdDic: [ChainType: Int] = [.eth: ethChainId, .heco: hecoChainId, .bsc: bscChainId]
let chainUrlDic: [ChainType: String] = [.btc: btcUrl,.eth: ethUrl, .heco: hecoUrl, .bsc: bscUrl]
let apiKeyDic: [ChainType: String] = [.btc: btcApiKey,.eth: ethApiKey, .heco: hecoApiKey, .bsc: bscApiKey]

//coinName
let coinNameLogoDic: [CoinName: String] = [.btc: "btcLogo", .eth: "ethLogo", .usdtErc20: "usdt", .usdtOmni: "usdtOmni", .ht: "walletHecoNormal", .bnb: "walletBscNormal"]
let coinNameDic: [CoinName: String] = [.btc: "BTC", .eth: "ETH", .usdtErc20: "USDT", .usdtOmni: "USDT", .ht: "HT", .bnb: "BNB"]
let chainCoinNameDic: [ChainType: String] = [.btc: "BTC", .eth: "ETH", .heco: "HT", .bsc: "BNB"]
