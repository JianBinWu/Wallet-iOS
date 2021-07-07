//
//  Dictionary+Extension.swift
//  BlockChainWallet
//
//  Created by user on 2021/7/7.
//

import Foundation

extension Dictionary {
    
    func toJsonString(options: JSONSerialization.WritingOptions = []) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self,
                                                     options: options) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
     }
    
}
