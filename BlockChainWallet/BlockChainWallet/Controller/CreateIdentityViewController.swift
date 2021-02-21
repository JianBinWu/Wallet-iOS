//
//  CreateIdentityViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/18.
//

import UIKit

class CreateIdentityViewController: UIViewController {
    
    @IBOutlet weak var identityNameTxtF: UITextField!
    @IBOutlet weak var passwordTxtF: UITextField!
    @IBOutlet weak var confirmPwdTxtF: UITextField!
    
    var mnemonicStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func create(_ sender: Any) {
        guard isParamValid() else {
            return
        }
        generateIdentity()
    }
    
    func isParamValid() -> Bool {
        if identityNameTxtF.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("请输入身份名")
            return false
        }
        if passwordTxtF.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("请输入密码")
            return false
        }
        if confirmPwdTxtF.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("请输入确认密码")
            return false
        }
        if passwordTxtF.text! != confirmPwdTxtF.text! {
            popToast("密码和确认密码不匹配")
            return false
        }
        return true
    }
    
    func generateIdentity(){
        let identityName = identityNameTxtF.text!
        let password = passwordTxtF.text!
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "正在生成助记词"
        DispatchQueue.global().async { [weak self] in
            do {
                let source = WalletMeta.Source.newIdentity
                var metadata = WalletMeta(source: source)
                metadata.network = Network.testnet
                metadata.segWit = .p2wpkh
                metadata.name = identityName
                (self!.mnemonicStr, _) = try Identity.createIdentity(password: password, metadata: metadata)
                Identity.currentIdentity?.wallets.forEach({ (wallet) in
                    UserDefaults.standard.setValue(wallet.address, forKey: wallet.chainType!.rawValue)
                })
                UserDefaults.standard.setValue(password, forKey: "password")
            } catch {
                print("createIdentity failed, error:\(error)")
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self!.view, animated: true)
                    popToast("生成助记词失败")
                }
                return
            }
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self!.view, animated: true)
                let backUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BackUpMnemonicViewController") as! BackUpMnemonicViewController
                backUpVC.mnemonicStr = self!.mnemonicStr
                self!.navigationController?.pushViewController(backUpVC, animated: true)
            }
        }
    }
    
}
