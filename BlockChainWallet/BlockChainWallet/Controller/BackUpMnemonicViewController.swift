//
//  BackUpMnemonicViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/19.
//

import UIKit

class BackUpMnemonicViewController: UIViewController {
    
    var mnemonicStr: String!
    @IBOutlet weak var mnemonicTxtV: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mnemonicTxtV.text = mnemonicStr
    }
    
    @IBAction func confirm(_ sender: Any) {
        let tabBarVC = CustomTabBarViewController()
        keyWindow.rootViewController = tabBarVC
    }
    
    

}
