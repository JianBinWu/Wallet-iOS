//
//  CoinTableViewCell.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/19.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet weak var coinImgV: UIImageView!
    @IBOutlet weak var coinNameLab: UILabel!
    @IBOutlet weak var coinAmountLab: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        coinImgV.layer.cornerRadius = 20
        coinImgV.layer.borderWidth = 0.5
        coinImgV.layer.borderColor = UIColor(hexString: "#E5E5EA").cgColor
        
    }
    
    func updateUI(coinName: CoinName) {
        coinImgV.image = UIImage(named: coinNameLogoDic[coinName]!)
        coinNameLab.text = coinNameDic[coinName]
    }
    
    
    
}
