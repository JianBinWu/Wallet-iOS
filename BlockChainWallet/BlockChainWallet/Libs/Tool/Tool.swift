//
//  Tool.swift
//  HuanXiRead
//
//  Created by user on 2020/6/16.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation
import Alamofire

func popToast(_ text: String) {
    keyWindow.makeToast(text, duration: 1, position: .center)
}

func dPrint(_ item: Any) {
    #if DEBUG
    print(item)
    #endif
}

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

@MainActor func getRequest(url: String) async throws -> AFDataResponse<Any> {
    showHUD()
    typealias GetContinuation = CheckedContinuation<AFDataResponse<Any>, Error>
    return try await withCheckedThrowingContinuation({ (continuation: GetContinuation) in
        AF.request(url).responseJSON {response in
            if let error = response.error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: response)
            }
            hideHUD()
        }
    })
}





