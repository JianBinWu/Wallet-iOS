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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func create(_ sender: Any) {
        guard isParamValid() else {
            return
        }
        startGenerateIdentity()
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
    
    @MainActor func startGenerateIdentity() {
        let identityName = identityNameTxtF.text!
        let password = passwordTxtF.text!
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "remind_MnemonicCreating".localized
        Task {
            do {
                let mnemonicStr = try await generateIdentity(identityName, password)
                let backUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BackUpMnemonicViewController") as! BackUpMnemonicViewController
                backUpVC.mnemonicStr = mnemonicStr
                navigationController?.pushViewController(backUpVC, animated: true)
            }catch {
                print("createIdentity failed, error:\(error)")
                popToast("remind_createMnemonicFail".localized)
            }
            hud.hide(animated: true)
        }
    }
    
    func generateIdentity(_ identityName: String, _ password: String) async throws -> String {
        let source = WalletMeta.Source.newIdentity
        var metadata = WalletMeta(source: source)
        metadata.network = netType
        metadata.segWit = .p2wpkh
        metadata.name = identityName
        let (mnemonicStr, _) = try Identity.createIdentity(password: password, metadata: metadata)
        Identity.currentIdentity?.wallets.forEach({ (wallet) in
            UserDefaults.standard.setValue(wallet.address, forKey: wallet.chainType!.rawValue)
        })
        UserDefaults.standard.setValue(password, forKey: "password")
        return mnemonicStr
    }
    
}
