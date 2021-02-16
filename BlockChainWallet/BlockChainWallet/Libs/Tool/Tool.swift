//
//  Tool.swift
//  HuanXiRead
//
//  Created by user on 2020/6/16.
//  Copyright © 2020 DaLianJieJing. All rights reserved.
//

import Foundation

//阿拉伯数字转中文
extension Int {
    var cn: String {
        get {
            if self == 0 {
                return "零"
            }
            let zhNumbers = ["零", "一", "二", "三", "四", "五", "六", "七", "八", "九"]
            let units = ["", "十", "百", "千", "万", "十", "百", "千", "亿", "十","百","千"]
            var cn = ""
            var currentNum = 0
            var beforeNum = 0
            let intLength = Int(floor(log10(Double(self))))
            for index in 0...intLength {
                currentNum = self/Int(pow(10.0,Double(index)))%10
                if index == 0{
                    if currentNum != 0 {
                        cn = zhNumbers[currentNum]
                        continue
                    }
                } else {
                    beforeNum = self/Int(pow(10.0,Double(index-1)))%10
                }
                if [1,2,3,5,6,7,9,10,11].contains(index) {
                    if currentNum == 1 && [1,5,9].contains(index) && index == intLength { // 处理一开头的含十单位
                        cn = units[index] + cn
                    } else if currentNum != 0 {
                        cn = zhNumbers[currentNum] + units[index] + cn
                    } else if beforeNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                    continue
                }
                if [4,8,12].contains(index) {
                    cn = units[index] + cn
                    if (beforeNum != 0 && currentNum == 0) || currentNum != 0 {
                        cn = zhNumbers[currentNum] + cn
                    }
                }
            }
            return cn
        }
    }
}

//展示提示
func popToast(_ text: String) {
    keyWindow.makeToast(text, duration: 1, position: .center)
}

//debug下打印
func dPrint(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}

//清除userDefault数据
func clearAllUserDefaultsData(){
   let userDefaults = UserDefaults.standard
   let dics = userDefaults.dictionaryRepresentation()
   for key in dics {
       userDefaults.removeObject(forKey: key.key)
   }
   userDefaults.synchronize()
}




