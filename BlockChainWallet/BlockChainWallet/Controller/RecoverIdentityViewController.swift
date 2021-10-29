//
//  RecoverIdentityViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/3/26.
//

import UIKit

class RecoverIdentityViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var passwordTxtF: UITextField!
    @IBOutlet weak var confirmPwdTxtF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }

    func initUI() {
        textView.setupPlaceholder("remind_inputMnemonicPlaceholder".localized)
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor(hexString: "#E7E7EB").cgColor
        textView.layer.cornerRadius = 5
    }
    
    @IBAction func recover(_ sender: Any) {
        guard isParamValid() else {
            return
        }
        startRecoverIdentity()
    }
    
    func isParamValid() -> Bool {
        if textView.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            popToast("remind_inputMnemonic".localized)
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
    
    @MainActor func startRecoverIdentity() {
        let identityName = "identity_name"
        let password = passwordTxtF.text!
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        let mnemonic = textView.text!
        hud.label.text = "remind_MnemonicRecovering".localized
        Task {
            do {
                try await recoverIdentity(identityName, password, mnemonic)
                let tabBarVC = CustomTabBarViewController()
                keyWindow.rootViewController = tabBarVC
            } catch {
                print("recoverIdentity failed, error:\(error)")
                popToast("remind_recoverIdentityFail".localized)
            }
            hud.hide(animated: true)
        }
    }
    
    func recoverIdentity(_ identityName: String, _ password: String, _ mnemonic: String) async throws {
        let source = WalletMeta.Source.recoveredIdentity
        var metadata = WalletMeta(source: source)
        metadata.network = netType
        metadata.segWit = .p2wpkh
        metadata.name = identityName
        let identity = try Identity.recoverIdentity(metadata: metadata, mnemonic: mnemonic, password: password)
        identity.wallets.forEach({ (wallet) in
            UserDefaults.standard.setValue(wallet.address, forKey: wallet.chainType!.rawValue)
        })
        UserDefaults.standard.setValue(password, forKey: "password")
    }

}
