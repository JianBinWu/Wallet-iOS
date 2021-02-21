//
//  ReceiveViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/17.
//

import UIKit

class ReceiveViewController: UIViewController {
    
    var coinName: CoinName!
    var chainType: ChainType!
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var qrCodeImgV: UIImageView!
    @IBOutlet weak var addressLab: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI() {
        titleLab.text = "扫二维码，转入\(coinName.rawValue)"
        addressLab.text = UserDefaults.standard.string(forKey: chainType.rawValue)
        qrCodeImgV.image = generateQRCode(str: addressLab.text!)
    }
    
    @IBAction func copyAction(_ sender: Any) {
        UIPasteboard.general.string = addressLab.text
    }
    
}
