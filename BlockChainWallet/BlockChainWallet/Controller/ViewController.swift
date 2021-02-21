//
//  ViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var viewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        viewContainer.layer.borderWidth = 0.5
        viewContainer.layer.cornerRadius = 15
        viewContainer.layer.borderColor = UIColor(hexString: "#E5E5EA").cgColor
    }

}

