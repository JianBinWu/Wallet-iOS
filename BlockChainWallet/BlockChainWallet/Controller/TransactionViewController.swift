//
//  TransactionViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/16.
//

import UIKit
import Alamofire

class TransactionViewController: UIViewController {
    
    var fromAddress: String!
    var chainType: ChainType!
    var coinName: CoinName!
    @IBOutlet weak var receiveAddressTxtF: UITextField!
    @IBOutlet weak var amountTxtF: UITextField!
    @IBOutlet weak var balanceLab: UILabel!
    @IBOutlet weak var feeTxtF: UITextField!
    @IBOutlet weak var feeUnitLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
        initData()
    }
    
    func initUI() {
        title = "transaction_title".localized
        receiveAddressTxtF.placeholder = "\(coinName.rawValue) \("wallet_address".localized)"
        feeUnitLab.text = chainCoinNameDic[chainType]
    }
    
    func initData() {
        fromAddress = UserDefaults.standard.string(forKey: chainType.rawValue)
        Task {
            try? await getFee()
        }
    }
    
    @MainActor func getFee() async throws {
        if chainType == .eth {
            let response = try await getRequest(url: "https://api.blockcypher.com/v1/eth/main")
            if let value = response.value as? [String: Any], let weiGasPrice = value["high_gas_price"] as? Int64 {
                let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 9, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
                let ethGasPrice = NSDecimalNumber(value: weiGasPrice).dividing(by: NSDecimalNumber(value: 1e18)).multiplying(by: NSDecimalNumber(value: 21000)).rounding(accordingToBehavior: handler)
                feeTxtF.text = ethGasPrice.stringValue
            }
        } else {
            let response = try await getRequest(url: btcUrl)
            if let value = response.value as? [String: Any], let satFeePerKb = value["high_fee_per_kb"] as? Int {
                let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 8, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
                let btcFee = NSDecimalNumber(value: satFeePerKb).dividing(by: NSDecimalNumber(value: 1024)).multiplying(by: NSDecimalNumber(value: 180)).dividing(by: NSDecimalNumber(value: 1e8)).rounding(accordingToBehavior: handler)
                feeTxtF.text = btcFee.stringValue
            }
        }
    }
    
    //MARK: - event handler
    @IBAction func transfer(_ sender: Any) {
        if !isParamValid() {
            return
        }
        let alertController = UIAlertController.init(title: "remind_inputPassword".localized, message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction.init(title: "btn_cancel".localized, style: .cancel, handler: nil)
        let confirmAction = UIAlertAction.init(title: "btn_confirm".localized, style: .default) {[weak self] (action) in
            self!.startTransfer(pwd: alertController.textFields?.first?.text)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @MainActor func startTransfer(pwd: String?) {
        showHUD()
        let toAddress = receiveAddressTxtF.text!
        let feeStr = feeTxtF.text!
        let amountStr = amountTxtF.text!
        Task {
            var result: String!
            do {
                switch coinName {
                case .btc:
                    result = try await transferBTC(fromAddress: fromAddress, toAddress: toAddress, password: pwd!, amountStr: amountStr, feeStr: feeStr)
                case .eth, .ht, .bnb:
                    result = try await transferMainCoin(chainType: chainType, fromAddress: fromAddress, toAddress: toAddress, fee: feeStr, gasLimit: 21000, password: pwd!, amountStr: amountStr)
                case .usdtErc20:
                    result = try await transferEthToken(tokenId: "0xdac17f958d2ee523a2206206994597c13d831ec7", fromAddress: fromAddress, toAddress: toAddress, fee: feeStr, gasLimit: 60000, password: pwd!, amountStr: amountStr, decimals: 8)
                case .usdtOmni:
                    result = try await transferOmniToken(fromAddress: fromAddress, toAddress: toAddress, password: pwd!, amountStr: amountStr, feeStr: feeStr)
                default:
                    break
                }
                if result.hasPrefix("Transfer_Success") {
                    result = "Transfer_Success"
                }
            } catch PasswordError.incorrect {
                result = "Transfer_RemindPasswordIncorrect"
            } catch GenericError.amountLessThanMinimum {
                result = "Transfer_RemindNotSufficient"
            } catch is AFError {
                result = "Transfer_BadRequest"
            } catch {
                print(error)
                result = "Transfer_Failed"
            }
            hideHUD()
            popToast(result.localized)
        }
    }
    
    func isParamValid() -> Bool{
        guard receiveAddressTxtF.text?.count != 0 else {
            popToast("transaction_remind_inputReceiveAddress".localized)
            return false
        }
        guard amountTxtF.text?.count != 0 else {
            popToast("transaction_remind_inputPayAmount".localized)
            return false
        }
        guard feeTxtF.text?.count != 0, Int(feeTxtF.text!) != 0 else {
            popToast("transaction_remind_inputFee".localized)
            return false
        }
        return true
    }

}
