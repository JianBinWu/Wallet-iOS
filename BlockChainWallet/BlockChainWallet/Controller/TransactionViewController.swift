//
//  TransactionViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/16.
//

import UIKit

class TransactionViewController: UIViewController {
    
    var group: DispatchGroup!
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
        title = "转账"
        receiveAddressTxtF.placeholder = "\(coinName.rawValue)地址"
        feeUnitLab.text = coinName.rawValue
        
    }
    
    func initData() {
        fromAddress = UserDefaults.standard.string(forKey: chainType.rawValue)
        group = DispatchGroup()
        MBProgressHUD.showAdded(to: view, animated: true)
        getBalance()
        getFee()
        group.notify(queue: .main) { [weak self] in
            MBProgressHUD.hide(for: self!.view, animated: true)
        }
    }
    
    //MARK: - custom method
    func getBalance() {
        group.enter()
        if coinName == .btc {
            let url = "https://testnet.blockchain.info/unspent?active=\(fromAddress!)"
            AF.request(url).responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let utxos = value["unspent_outputs"] as? [[String: Any]] {
                        var balance: UInt64 = 0
                        for utxo in utxos {
                            balance += utxo["value"] as! UInt64
                        }
                        let decimalValue = NSDecimalNumber(value: balance).dividing(by: NSDecimalNumber(1e8))
                        self!.balanceLab.text = "\(decimalValue) BTC"
                    }
                default:
                    break
                }
                self!.group.leave()
            }
        } else {
            let url = "https://api-kovan.etherscan.io/api?module=account&action=balance&address=0x\(fromAddress!)&tag=latest&apikey=SJMGV3C6S3CSUQQXC7CTQ72UCM966KD2XZ"
            AF.request(url).responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let weiBalance = value["result"] as? NSDecimalNumber {
                        let ethBalance = weiBalance.dividing(by: NSDecimalNumber.init(value: 1e18))
                        self!.balanceLab.text = "\(ethBalance) ETH"
                    }
                default:
                    break
                }
                self!.group.leave()
            }
        }
    }
    
    func getFee() {
        group.enter()
        if coinName == .btc {
            let url = "https://api.blockcypher.com/v1/eth/main"
            AF.request(url).responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let weiGasPrice = value["high_gas_price"] as? NSDecimalNumber {
                        let ethGasPrice = weiGasPrice.dividing(by: NSDecimalNumber.init(value: 1e18)).multiplying(by: NSDecimalNumber.init(value: 21000))
                        self!.feeTxtF.text = ethGasPrice.stringValue
                    }
                default:
                    break
                }
                self!.group.leave()
            }
        } else {
            let url = "https://api.blockcypher.com/v1/btc/test3"
            AF.request(url).responseJSON {[weak self] (response) in
                switch response.result {
                case .success:
                    if let value = response.value as? [String: Any], let satFeePerKb = value["high_fee_per_kb"] as? NSDecimalNumber {
                        let btcFee = satFeePerKb.dividing(by: NSDecimalNumber.init(value: 1024)).multiplying(by: NSDecimalNumber.init(value: 78)).dividing(by: NSDecimalNumber.init(value: 100000000))
                        self!.feeTxtF.text = btcFee.stringValue
                    }
                default:
                    break
                }
                self!.group.leave()
            }
        }
    }
    
    //MARK: - event handler
    @IBAction func transfer(_ sender: Any) {
        if !isParamValid() {
            return
        }
        let alertController = UIAlertController.init(title: "请输入密码", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = true
        }
        let cancelAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction.init(title: "确定", style: .default) {[weak self] (action) in
            self!.startTransfer(pwd: alertController.textFields?.first?.text)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func startTransfer(pwd: String?) {
        var result = "无结果"
        switch coinName {
        case .btc:
            result = transferBTC(fromAddress: fromAddress, toAddress: receiveAddressTxtF.text!, password: pwd!, amountStr: amountTxtF.text!, feeStr: feeTxtF.text!)
        case .eth:
            result = transferEth(fromAddress: fromAddress, toAddress: receiveAddressTxtF.text!, ethGasPrice: feeTxtF.text!, gasLimit: 21000, password: pwd!, amountStr: amountTxtF.text!)
        case .usdtErc20:
            result = transferEthToken(tokenId: "", fromAddress: fromAddress, toAddress: receiveAddressTxtF.text!, ethGasPrice: feeTxtF.text!, gasLimit: 60000, password: pwd!, amountStr: amountTxtF.text!, decimals: 8)
        default:
            break
        }
        popToast(result)
    }
    
    func isParamValid() -> Bool{
        guard receiveAddressTxtF.text?.count != 0 else {
            popToast("请输入收款地址")
            return false
        }
        guard amountTxtF.text?.count != 0 else {
            popToast("请输入付款金额")
            return false
        }
        guard feeTxtF.text?.count != 0, Int(feeTxtF.text!) == 0 else {
            popToast("请输入矿工费且不能为零")
            return false
        }
        return true
    }

}
