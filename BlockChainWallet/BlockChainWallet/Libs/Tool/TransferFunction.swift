//
//  TransferFunction.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/18.
//

import Foundation

fileprivate var nonce:Int = 0

func transferEthToken(tokenId: String, fromAddress: String, toAddress: String, fee: String, gasLimit: Int, password: String, amountStr: String, decimals: Int) -> String {
    do {
        let toAddress = toAddress.removePrefix0xIfNeeded()
        //get nonce from api
        let deci = isMainNet ? decimals : 6
        getEthTxNonce(address: fromAddress.removePrefix0xIfNeeded())
        var amount = NSDecimalNumber(string: amountStr)
        amount = amount.multiplying(byPowerOf10: Int16(deci))
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        let weiGasPrice = NSDecimalNumber(string: fee).multiplying(byPowerOf10: 18).dividing(by: NSDecimalNumber(value:gasLimit)).rounding(accordingToBehavior: handler)
        
        let tokenAmountHexStr = BigNumber.parse(amount.stringValue, padding: false, paddingLen: 0).hexString()
        let ethWallet = try WalletManager.findWalletByAddress(fromAddress, on: .eth)
        let data = "0xa9059cbb\(BigNumber.parse(toAddress, padding: true, paddingLen: 32).hexString())\(BigNumber.parse("0x\(tokenAmountHexStr)", padding: true, paddingLen: 32).hexString())"
        let tId = isMainNet ? tokenId : "0xd85476c906b5301e8e9eb58d174a6f96b9dfc5ee"
        let signedResult = try WalletManager.ethSignTransaction(walletID: ethWallet.walletID, nonce: String(nonce), gasPrice: weiGasPrice.stringValue, gasLimit: "\(gasLimit)", to: tId, value: "0", data: data, password: password, chainID: isMainNet ? 1 : 42)
        let requestUrl = String(format: ethPushUrl, signedResult.signedTx) 
        let result = pushEthTransferInfo(requestUrl)
        return result
    } catch PasswordError.incorrect {
        return "Transfer_RemindPasswordIncorrect"
    } catch {
        print(error)
        return "Transfer_Failed"
    }
}

func transferEth(fromAddress: String, toAddress: String, fee: String, gasLimit: Int, password: String, amountStr: String) -> String {
    do {
        let toAddress = toAddress.removePrefix0xIfNeeded()
        //get nonce from api
        getEthTxNonce(address: fromAddress.removePrefix0xIfNeeded())
        //计算金额和矿工费
        let amount = NSDecimalNumber(string: amountStr).multiplying(byPowerOf10: 18)
        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 0, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        let weiGasPrice = NSDecimalNumber(string: fee).multiplying(byPowerOf10: 18).dividing(by: NSDecimalNumber(value:gasLimit)).rounding(accordingToBehavior: handler)
        //开始签名转账
        let ethWallet = try WalletManager.findWalletByAddress(fromAddress, on: .eth)
        // chainID 42:kovan 0 testnet, 1 mainnet
        let signedResult = try WalletManager.ethSignTransaction(walletID: ethWallet.walletID, nonce: String(nonce), gasPrice: weiGasPrice.stringValue, gasLimit: "\(gasLimit)", to: toAddress, value: amount.stringValue, data: "", password: password, chainID: isMainNet ? 1 : 42)
        let requestUrl = String(format: ethPushUrl, signedResult.signedTx) 
        let result = pushEthTransferInfo(requestUrl)
        return result
    } catch PasswordError.incorrect {
        return "Transfer_RemindPasswordIncorrect"
    } catch {
        print(error)
        return "Transfer_Failed"
    }
}

func getEthTxNonce(address: String) {
    let semaphore = DispatchSemaphore(value: 0)
    AF.request(String(format: ethNonceUrl, address)).responseJSON { (response) in
        switch response.result {
        case .success:
            let dic = response.value as? [String: Any]
            var hexiStr = dic!["result"] as! String
            hexiStr.removeFirst(2)
            nonce = Int(hexiStr, radix: 16)!
            print("nonce:\(nonce)")
        default:
            print("getEthTxNonce failure")
        }
        semaphore.signal()
    }
    semaphore.wait()
}

func transferBTC(fromAddress: String, toAddress: String, password: String, amountStr: String, feeStr: String) -> String  {
    do {
        let toAddress = toAddress.removePrefix0xIfNeeded()
        let amount = NSDecimalNumber(string: amountStr).multiplying(byPowerOf10: 8)
        let fee = NSDecimalNumber(string: feeStr).multiplying(byPowerOf10: 8)
        
        if fee.int64Value == 0 {
            return "Transfer_FeeNotZero"
        }
        
        let btcWallet = try WalletManager.findWalletByAddress(fromAddress, on: .btc)
        
        let utxoReq = String(format: btcUtxoUrl, fromAddress)
        let unspentsStr = get(utxoReq)
        let json = try unspentsStr.tk_toJSON()
        let unspentsJson = json["txrefs"] as? [JSONObject] ?? [JSONObject]()
        let signed = try WalletManager.btcSignTransaction(walletID: btcWallet.walletID, to: toAddress, amount: amount.int64Value, fee: fee.int64Value, password: password, outputs: unspentsJson, changeIdx: 0, isTestnet: !isMainNet, segWit: .p2wpkh)
        
        let signedResult = signed.signedTx
        let pushTxReq = "\(btcPushTx)"
        let reqBody: Parameters = [
            "tx": signedResult
        ]
        let result = pushBtcTransferInfo(pushTxReq, body: reqBody)
        return result
    } catch PasswordError.incorrect {
        return "Transfer_RemindPasswordIncorrect"
    } catch GenericError.amountLessThanMinimum {
        return "Transfer_RemindNotSufficient"
    }catch {
        print(error)
        return "Transfer_Failed"
    }
}

//get request method
fileprivate func get(_ url: String) -> String {
    var result: String = ""
    let semaphore = DispatchSemaphore(value: 0)
    AF.request(url).responseJSON { response in
        if let json = response.value {
            print("JSON: \(json)") // serialized json response
        }
        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            print("Data: \(utf8Text)") // original server data as UTF8 string
            result = utf8Text
        }
        semaphore.signal()
    }
    semaphore.wait()
    return result
}

//MARK: - push transfer info
fileprivate func pushEthTransferInfo(_ url: String) -> String {
    var result: String = "Transfer_RequestTimeOut"
    let semaphore = DispatchSemaphore(value: 0)
    AF.request(url).responseJSON { response in
        if let json = response.value {
            print("JSON: \(json)") // serialized json response
        }
        switch response.result {
        case .success:
            let value = response.value as! [String: Any]
            if let error = value["error"] as? [String: Any] {
                result = error["message"] as! String
            } else {
                result = "Transfer_Success"
            }
        default:
            result = "Transfer_BadRequest"
        }
        semaphore.signal()
    }
    semaphore.wait()
    return result
}

fileprivate func pushBtcTransferInfo(_ url: String, body: Parameters) -> String {
    var result: String = "Transfer_RequestTimeOut"
    let semaphore = DispatchSemaphore(value: 0)
    AF.request(url, method: .post, parameters: body, encoding: JSONEncoding.default).responseJSON { response in
        if let json = response.value {
            print("JSON: \(json)") // serialized json response
        }
        switch response.result {
        case .success:
            let value = response.value as! [String: Any]
            if let _ = value["tx"] {
                result = "Transfer_Success"
            } else {
                result = "Transfer_Failed"
            }
        default:
            result = "Transfer_BadRequest"
        }
        semaphore.signal()
    }
    semaphore.wait()
    return result
}