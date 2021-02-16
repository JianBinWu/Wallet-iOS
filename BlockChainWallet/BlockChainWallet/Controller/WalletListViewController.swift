//
//  WalletListViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/19.
//

import UIKit

class WalletListViewController: UIViewController {
    
    private let coinTypeImgArr = ["walletIdentity", "walletBitcoin", "walletEth"]
    private let chainTypeArr: [[ChainType]] = [[.btc, .eth], [.btc], [.eth]]
    
    @IBOutlet weak var coinTypeTableView: UITableView!
    @IBOutlet weak var walletTableView: UITableView!
    
    var selectChainTypeBlock: ((_: ChainType)->())!
    
    var coinTypeSelectedIndexPath = IndexPath(row: 0, section: 0)//0:all 1:BTC 2:ETH

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initUI()
    }
    
    func initUI() {
        coinTypeTableView.register(CoinTypeTableViewCell.self, forCellReuseIdentifier: "CoinTypeTableViewCell")
        walletTableView.register(UINib.init(nibName: "WalletTableViewCell", bundle: nil), forCellReuseIdentifier: "WalletTableViewCell")
        walletTableView.register(WalletTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "WalletTableSectionHeaderView")
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

extension WalletListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === coinTypeTableView {
            return 3
        }
        if coinTypeSelectedIndexPath.row == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView === walletTableView {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "WalletTableSectionHeaderView")
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === coinTypeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CoinTypeTableViewCell") as! CoinTypeTableViewCell
            var imgName: String!
            if indexPath == coinTypeSelectedIndexPath {
                imgName = "\(coinTypeImgArr[indexPath.row])Normal"
            } else {
                imgName = coinTypeImgArr[indexPath.row]
            }
            cell.imgV.image = UIImage(named: imgName)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WalletTableViewCell") as! WalletTableViewCell
            cell.updateUI(chainType: chainTypeArr[coinTypeSelectedIndexPath.row][indexPath.row])
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView === walletTableView {
            return 40
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === coinTypeTableView {
            if indexPath != coinTypeSelectedIndexPath {
                let oldSelectedIndexPath = coinTypeSelectedIndexPath
                coinTypeSelectedIndexPath = indexPath
                tableView.reloadRows(at: [oldSelectedIndexPath, coinTypeSelectedIndexPath], with: .automatic)
                walletTableView.reloadData()
            }
        } else {
            selectChainTypeBlock(chainTypeArr[coinTypeSelectedIndexPath.row][indexPath.row])
            self.dismiss(animated: true, completion: nil)
        }
    }
}
