//
//  Tool.swift
//  HuanXiRead
//
//  Created by user on 2020/6/16.
//  Copyright © 2020 DaLianJieJing. All rights reserved.
//

import Foundation

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

func generateQRCode(str: String) -> UIImage? {
    
    let data = str.data(using: String.Encoding.ascii)
    
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    
    filter.setValue(data, forKey: "inputMessage")
    
    let transform = CGAffineTransform(scaleX: 9, y: 9)
    
    guard let output = filter.outputImage?.transformed(by: transform) else { return nil }
    
    return UIImage(ciImage: output)
}

func showHUD() {
    MBProgressHUD.showAdded(to: keyWindow, animated: true)
}

func hideHUD() {
    MBProgressHUD.hide(for: keyWindow, animated: false)
}





