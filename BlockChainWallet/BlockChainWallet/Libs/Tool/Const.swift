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
let chainTypeBgColorDic: [ChainType: UIColor] = [.btc: UIColor(hexString: "#FFAB27"), .eth: UIColor(hexString: "#1894BD")]
let chainTypeTxtDic: [ChainType: String] = [.btc: "BTC", .eth: "ETH"]
let chainTypeImgDic: [ChainType: String] = [.btc: "btcBadge", .eth: "ethBadge"]

//coinName
let coinNameLogoDic: [CoinName: String] = [.btc: "btcLogo", .eth: "ethLogo", .usdtErc20: "usdt"]
