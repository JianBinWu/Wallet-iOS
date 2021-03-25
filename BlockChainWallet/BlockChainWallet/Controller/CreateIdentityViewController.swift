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
            popToast("remind_inputIdentityName".localized)
            return false
        }
        if passwordTxtF.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("remind_inputPassword".localized)
            return false
        }
        if confirmPwdTxtF.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("remind_confirmPassword".localized)
            return false
        }
        if passwordTxtF.text! != confirmPwdTxtF.text! {
            popToast("remind_passwordUnmatched".localized)
            return false
        }
        return true
    }
    
    func generateIdentity(){
        let identityName = identityNameTxtF.text!
        let password = passwordTxtF.text!
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "remind_MnemonicCreating".localized
        
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
                    hud.hide(animated: true)
                    popToast("remind_createMnemonicFail".localized)
                }
                return
            }
            DispatchQueue.main.async {
                hud.hide(animated: true)
                let backUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BackUpMnemonicViewController") as! BackUpMnemonicViewController
                backUpVC.mnemonicStr = self!.mnemonicStr
                self!.navigationController?.pushViewController(backUpVC, animated: true)
            }
        }
    }
    
}
