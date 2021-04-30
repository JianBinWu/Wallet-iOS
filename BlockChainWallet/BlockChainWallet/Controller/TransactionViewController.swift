//
//  TransactionViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/16.
//

import UIKit

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
        feeUnitLab.text = chainType == .btc ? "BTC" : "ETH"
    }
    
    func initData() {
        fromAddress = UserDefaults.standard.string(forKey: chainType.rawValue)
        getFee()
    }
    
    func getFee() {
        showHUD()
        if chainType == .eth {
            AF.request("https://api.blockcypher.com/v1/eth/main").responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let weiGasPrice = value["high_gas_price"] as? Int64 {
                        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 9, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
                        let ethGasPrice = NSDecimalNumber(value: weiGasPrice).dividing(by: NSDecimalNumber(value: 1e18)).multiplying(by: NSDecimalNumber(value: 21000)).rounding(accordingToBehavior: handler)
                        self!.feeTxtF.text = ethGasPrice.stringValue
                    }
                default:
                    break
                }
                hideHUD()
            }
        } else {
            AF.request(btcUrl).responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let satFeePerKb = value["high_fee_per_kb"] as? Int {
                        let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 8, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
                        let btcFee = NSDecimalNumber(value: satFeePerKb).dividing(by: NSDecimalNumber(value: 1024)).multiplying(by: NSDecimalNumber(value: 180)).dividing(by: NSDecimalNumber(value: 1e8)).rounding(accordingToBehavior: handler)
                        self!.feeTxtF.text = btcFee.stringValue
                    }
                default:
                    break
                }
                hideHUD()
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
    
    func startTransfer(pwd: String?) {
        showHUD()
        let toAddress = receiveAddressTxtF.text!
        let feeStr = feeTxtF.text!
        let amountStr = amountTxtF.text!
        DispatchQueue.global().async {[weak self] in
            var result: String!
            switch self!.coinName {
            case .btc:
                result = transferBTC(fromAddress: self!.fromAddress, toAddress: toAddress, password: pwd!, amountStr: amountStr, feeStr: feeStr)
            case .eth:
                result = transferEth(fromAddress: self!.fromAddress, toAddress: toAddress, fee: feeStr, gasLimit: 21000, password: pwd!, amountStr: amountStr)
            case .usdtErc20:
                result = transferEthToken(tokenId: "0xdac17f958d2ee523a2206206994597c13d831ec7", fromAddress: self!.fromAddress, toAddress: toAddress, fee: feeStr, gasLimit: 60000, password: pwd!, amountStr: amountStr, decimals: 8)
            case .usdtOmni:
                result = transferOmniToken(fromAddress: self!.fromAddress, toAddress: toAddress, password: pwd!, amountStr: amountStr, feeStr: feeStr)
            default:
                break
            }
            DispatchQueue.main.async {
                hideHUD()
                popToast(result.localized)
            }
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
