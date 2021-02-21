//
//  WalletViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/1/19.
//

import UIKit

class WalletViewController: UIViewController {
    
    private let coinNameDic:[ChainType: [CoinName]] = [.btc: [.btc], .eth: [.eth]]
    
    @IBOutlet weak var chainTypeBgView: UIView!
    @IBOutlet weak var chainTypeNameLab: UILabel!
    @IBOutlet weak var addressBtn: UIButton!
    @IBOutlet weak var chainTypeBalanceLab: UILabel!
    @IBOutlet weak var chainTypeBadgeImgV: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    var currentChainType = ChainType.btc
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    func initUI() {
        //add navigationBar btn
        let walletListBtn = UIButton(type: .custom)
        walletListBtn.addTarget(self, action: #selector(showCoinList), for: .touchUpInside)
        walletListBtn.setImage(UIImage(named: "walletList"), for: .normal)
        let walletListBtnItem = UIBarButtonItem(customView: walletListBtn)
        navigationItem.leftBarButtonItem = walletListBtnItem
        
        let scanBtn = UIButton(type: .custom)
        scanBtn.addTarget(self, action: #selector(scan), for: .touchUpInside)
        scanBtn.setImage(UIImage(named: "scan"), for: .normal)
        let scanBtnItem = UIBarButtonItem(customView: scanBtn)
        navigationItem.rightBarButtonItem = scanBtnItem
        
        tableView.register(UINib(nibName: "CoinTableViewCell", bundle: nil), forCellReuseIdentifier: "cellId")
        tableView.tableFooterView = UIView()
    }
    
    func updateUI(_ chainType: ChainType) {
        currentChainType = chainType
        chainTypeBgView.backgroundColor = chainTypeBgColorDic[chainType]
        chainTypeNameLab.text = chainTypeTxtDic[chainType]
        addressBtn.setTitle(UserDefaults.standard.string(forKey: chainType.rawValue), for: .normal)
        chainTypeBadgeImgV.image = UIImage(named: chainTypeImgDic[chainType]!)
        tableView.reloadData()
    }
    
    //MARK: - event handler
    @objc func showCoinList() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WalletListViewController") as! WalletListViewController
        vc.selectChainTypeBlock = {[weak self] chainType in
            self!.updateUI(chainType)
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func scan() {
        
    }
    
    @IBAction func tapAddressAction(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
        vc.chainType = currentChainType
        vc.coinName = coinNameDic[currentChainType]![0]
        navigationController?.pushViewController(vc, animated: true)
    }

}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! CoinTableViewCell
        cell.updateUI(coinName: coinNameDic[currentChainType]![indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let receiveAction = UITableViewRowAction.init(style: .default, title: "收款") {[weak self] (action, indexPath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ReceiveViewController") as! ReceiveViewController
            vc.chainType = self!.currentChainType
            vc.coinName = self!.coinNameDic[self!.currentChainType]![indexPath.row]
            self!.navigationController?.pushViewController(vc, animated: true)
        }
        receiveAction.backgroundColor = UIColor(hexString: "#0FB5CF")

        let payAction = UITableViewRowAction.init(style: .default, title: "付款") {[weak self] (action, indexPath) in
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
            vc.chainType = self!.currentChainType
            vc.coinName = self!.coinNameDic[self!.currentChainType]![indexPath.row]
            self!.navigationController?.pushViewController(vc, animated: true)
        }
        payAction.backgroundColor = UIColor(hexString: "#0182EB")
        return [receiveAction, payAction]
    }
    
}
