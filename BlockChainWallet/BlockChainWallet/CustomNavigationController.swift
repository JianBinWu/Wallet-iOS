//
//  CustomNavigationController.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/16.
//

import UIKit

class CustomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if children.count == 1 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
}
