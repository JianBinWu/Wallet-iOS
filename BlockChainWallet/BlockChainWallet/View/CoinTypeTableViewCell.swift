//
//  CoinTypeTableViewCell.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/11.
//

import UIKit

class CoinTypeTableViewCell: UITableViewCell {
    
    let imgV = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(imgV)
        imgV.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-15)
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.centerX.centerY.equalToSuperview()
        }
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
