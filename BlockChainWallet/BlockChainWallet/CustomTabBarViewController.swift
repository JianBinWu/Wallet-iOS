//
//  CustomTabBarViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/19.
//

import UIKit

class CustomTabBarViewController: UITabBarController {
    
    let arr = [
        ["className": "WalletViewController", "title": "tabbar_wallet".localized, "icon": "wallet"],
        ["className": "MeViewController", "title": "tabbar_me".localized, "icon": "me"],
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = .systemBlue
        //add child viewController
        addVCToTabBarVC()
    }
    
    func addVCToTabBarVC() {
        for item in arr {
            let className = item["className"]!
            let title = item["title"]
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: className)
            vc.title = title
            
            let nav = CustomNavigationController(rootViewController: vc)
            let icon = item["icon"]!
            nav.tabBarItem.image = UIImage(named: icon)
            addChild(nav)
        }
    }
    
    

}
