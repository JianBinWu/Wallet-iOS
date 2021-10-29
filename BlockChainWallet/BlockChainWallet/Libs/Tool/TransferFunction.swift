//
//  TransferFunction.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/18.
//

import Foundation
import Alamofire

public enum TransferError: Error {
  case transferFailed
}

func ethTransferFromDApp(_ dataDic: [String: String], password: String) async throws -> String {
    let fromAddress = dataDic["from"]!
    let amountStr = dataDic["value"]!
    let gasStr = String(dataDic["gas"]!)
    let fee = NSDecimalNumber(string: dataDic["fee"]!)
    let weiGasPrice = fee.multiplying(byPowerOf10: 18).dividing(by: NSDecimalNumber(string: gasStr)).doubleValue
    let weiGasPriceStr = String(format:"%.0f", weiGasPrice)
    
    let nonce = try await getTxNonce(chainType: .eth, address: fromAddress.removePrefix0xIfNeeded())
    
    let ethWallet = try WalletManager.findWalletByAddress(fromAddress, on: .eth)
    let data = dataDic["data"]!
    let tId = dataDic["to"]!
    let signedResult = try WalletManager.ethSignTransaction(walletID: ethWallet.walletID, nonce: String(nonce), gasPrice: weiGasPriceStr, gasLimit: gasStr, to: tId, value: amountStr, data: data, password: password, chainID: isMainNet ? 1 : 42)
    let requestUrl = String(format: "\(chainUrlDic[.eth]!)\(pushUrl)\(apiKeyDic[.eth]!)", signedResult.signedTx)
    let result = try await pushEthTransferInfo(requestUrl)
    return result
}

func transferEthToken(tokenId: String, fromAddress: String, toAddress: String, fee: String, gasLimit: Int, password: String, amountStr: String, decimals: Int) async throws -> String {
    let toAddress = toAddress.removePrefix0xIfNeeded()
    //get nonce from api
    let deci = isMainNet ? decimals : 6
    let nonce = try await getTxNonce(chainType: .eth, address: fromAddress.removePrefix0xIfNeeded())
    var amount = NSDecimalNumber(string: amountStr)
    amount = amount.multiplying(byPowerOf10: Int16(deci))
    let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    let weiGasPrice = NSDecimalNumber(string: fee).multiplying(byPowerOf10: 18).dividing(by: NSDecimalNumber(value:gasLimit)).rounding(accordingToBehavior: handler)
    
    let tokenAmountHexStr = BigNumber.parse(amount.stringValue, padding: false, paddingLen: 0).hexString()
    let ethWallet = try WalletManager.findWalletByAddress(fromAddress, on: .eth)
    let data = "0xa9059cbb\(BigNumber.parse(toAddress, padding: true, paddingLen: 32).hexString())\(BigNumber.parse("0x\(tokenAmountHexStr)", padding: true, paddingLen: 32).hexString())"
    let tId = isMainNet ? tokenId : "0xd85476c906b5301e8e9eb58d174a6f96b9dfc5ee"
    let signedResult = try WalletManager.ethSignTransaction(walletID: ethWallet.walletID, nonce: String(nonce), gasPrice: weiGasPrice.stringValue, gasLimit: "\(gasLimit)", to: tId, value: "0", data: data, password: password, chainID: isMainNet ? 1 : 42)
    let requestUrl = String(format: "\(chainUrlDic[.eth]!)\(pushUrl)\(apiKeyDic[.eth]!)", signedResult.signedTx)
    let result = try await pushEthTransferInfo(requestUrl)
    return result
}

func transferMainCoin(chainType: ChainType, fromAddress: String, toAddress: String, fee: String, gasLimit: Int, password: String, amountStr: String) async throws -> String {
    let txPushUrl = "\(chainUrlDic[chainType]!)\(pushUrl)\(apiKeyDic[chainType]!)"
    let toAddress = toAddress.removePrefix0xIfNeeded()
    //get nonce from api
    let nonce = try await getTxNonce(chainType: chainType, address: fromAddress.removePrefix0xIfNeeded())
    //calculate amount and fee
    let amount = NSDecimalNumber(string: amountStr).multiplying(byPowerOf10: 18)
    let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
    let weiGasPrice = NSDecimalNumber(string: fee).multiplying(byPowerOf10: 18).dividing(by: NSDecimalNumber(value:gasLimit)).rounding(accordingToBehavior: handler)
    //start sign and transaction
    let wallet = try WalletManager.findWalletByAddress(fromAddress, on: chainType)
    let signedResult = try WalletManager.ethSignTransaction(walletID: wallet.walletID, nonce: String(nonce), gasPrice: weiGasPrice.stringValue, gasLimit: "\(gasLimit)", to: toAddress, value: amount.stringValue, data: "", password: password, chainID: chainIdDic[chainType]!)
    let requestUrl = String(format: txPushUrl, signedResult.signedTx)
    let result = try await pushEthTransferInfo(requestUrl)
    return result
}

func getTxNonce(chainType: ChainType, address: String) async throws -> Int{
    let txNonceUrl = "\(chainUrlDic[chainType]!)\(nonceUrl)\(apiKeyDic[chainType]!)"
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<Int, Error>) in
        AF.request(String(format: txNonceUrl, address)).responseJSON { (response) in
            switch response.result {
            case .success:
                let dic = response.value as? [String: Any]
                var hexiStr = dic!["result"] as! String
                hexiStr.removeFirst(2)
                let nonce = Int(hexiStr, radix: 16)!
                print("nonce:\(nonce)")
                continuation.resume(returning: nonce)
            default:
                continuation.resume(throwing: response.error!)
            }
        }
    })
}



func transferBTC(fromAddress: String, toAddress: String, password: String, amountStr: String, feeStr: String) async throws -> String  {
    let toAddress = toAddress.removePrefix0xIfNeeded()
    let amount = NSDecimalNumber(string: amountStr).multiplying(byPowerOf10: 8)
    let fee = NSDecimalNumber(string: feeStr).multiplying(byPowerOf10: 8)
    
    if fee.int64Value == 0 {
        return "Transfer_FeeNotZero"
    }
    
    let btcWallet = try WalletManager.findWalletByAddress(fromAddress, on: .btc)
    
    let utxoReq = String(format: btcUtxoUrl, fromAddress)
    let unspentsStr = await get(utxoReq)
    let json = try unspentsStr.tk_toJSON()
    let unspentsJson = json["txrefs"] as? [JSONObject] ?? [JSONObject]()
    let signed = try WalletManager.btcSignTransaction(walletID: btcWallet.walletID, to: toAddress, amount: amount.int64Value, fee: fee.int64Value, password: password, outputs: unspentsJson, changeIdx: 0, isTestnet: !isMainNet, segWit: .p2wpkh)
    
    let signedResult = signed.signedTx
    let pushTxReq = "\(btcPushTx)"
    let reqBody: Parameters = [
        "tx": signedResult
    ]
    let result = try await pushBtcTransferInfo(pushTxReq, body: reqBody)
    return result
}

func transferOmniToken(fromAddress: String, toAddress: String, password: String, amountStr: String, feeStr: String) async throws -> String  {
    let toAddress = toAddress.removePrefix0xIfNeeded()
    var amount = NSDecimalNumber(string: amountStr)
    amount = amount.multiplying(byPowerOf10: 8)
    var fee = NSDecimalNumber(string: feeStr)
    fee = fee.multiplying(byPowerOf10: 8)
    
    if fee.int64Value == 0 {
        return "Transfer_FeeNotZero"
    }
    
    let btcWallet = try WalletManager.findWalletByAddress(fromAddress, on: .btc)
    let utxoReq = String(format: btcUtxoUrl, fromAddress)
    let unspentsStr = await get(utxoReq)
    let json = try unspentsStr.tk_toJSON()
    let unspentsJson = json["txrefs"] as? [JSONObject] ?? [JSONObject]()
    let signed = try WalletManager.omniTokenSignTransaction(walletID: btcWallet.walletID, to: toAddress, amount: amount.int64Value, fee: fee.int64Value, password: password, outputs: unspentsJson, changeIdx: 0, isTestnet: !isMainNet, segWit: .p2wpkh)
    
    let signedResult = signed.signedTx
    let pushTxReq = "\(btcPushTx)"
    let reqBody: Parameters = [
        "tx": signedResult
    ]
    let result = try await pushBtcTransferInfo(pushTxReq, body: reqBody)
    return result
}

//get request method
fileprivate func get(_ url: String) async -> String {
    return await withCheckedContinuation { (continuation: CheckedContinuation<String, Never>) in
        var result: String = ""
        AF.request(url).responseJSON { response in
            if let json = response.value {
                print("JSON: \(json)") // serialized json response
            }
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)") // original server data as UTF8 string
                result = utf8Text
            }
            continuation.resume(returning: result)
        }
    }
}

//MARK: - push transfer info
fileprivate func pushEthTransferInfo(_ url: String) async throws -> String {
    return try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<String, Error>) in
        var result: String!
        AF.request(url).responseJSON { response in
            if let json = response.value {
                print("JSON: \(json)") // serialized json response
            }
            switch response.result {
            case .success:
                let value = response.value as! [String: Any]
                if let error = value["error"] as? [String: Any] {
                    result = error["message"] as? String
                } else {
                    let hashStr:String = value["result"] as! String
                    result = "Transfer_Success" + hashStr
                }
                continuation.resume(returning: result)
            default:
                continuation.resume(throwing: response.error!)
            }
        }
    })
}

fileprivate func pushBtcTransferInfo(_ url: String, body: Parameters) async throws -> String {
    return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
        var result: String!
        AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default).responseJSON { response in
            if let json = response.value {
                print("JSON: \(json)") // serialized json response
            }
            switch response.result {
            case .success:
                let value = response.value as! [String: [String: Any]]
                if let _ = value["tx"] {
                    let hashStr:String = value["tx"]!["hash"] as! String
                    result = "Transfer_Success" + hashStr
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(throwing: TransferError.transferFailed)
                }
            default:
                continuation.resume(throwing: response.error!)
            }
        }
    }
}
