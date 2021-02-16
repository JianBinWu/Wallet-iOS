//
//  WalletTableViewCell.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/11.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var coinTypeLab: UILabel!
    @IBOutlet weak var addressLab: UILabel!
    @IBOutlet weak var coinTypeImgV: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updateUI(chainType: ChainType) {
        bgView.backgroundColor = chainTypeBgColorDic[chainType]
        coinTypeLab.text = chainTypeTxtDic[chainType]
        addressLab.text = UserDefaults.standard.string(forKey: chainType.rawValue)
        coinTypeImgV.image = UIImage(named: chainTypeImgDic[chainType]!)
    }
    
}
