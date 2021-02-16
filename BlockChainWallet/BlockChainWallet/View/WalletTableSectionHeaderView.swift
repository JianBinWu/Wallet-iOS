//
//  WalletTableSectionHeaderView.swift
//  BlockChainWallet
//
//  Created by user on 2021/2/11.
//

import UIKit

class WalletTableSectionHeaderView: UITableViewHeaderFooterView {
    
    var titleLab = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .white
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
        }
        titleLab.text = "身份钱包"
        titleLab.textColor = .lightGray
        titleLab.font = .systemFont(ofSize: 13)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
