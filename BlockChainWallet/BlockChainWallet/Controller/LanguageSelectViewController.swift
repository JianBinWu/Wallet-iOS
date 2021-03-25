//
//  LanguageSelectViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/3/22.
//

import UIKit

class LanguageSelectViewController: UIViewController {
    
    let languageStrArr = ["简体中文", "繁體中文", "English", "日本語", "한국어"]
    let languageArr: [Language] = [.zhHans, .zhHant, .en, .ja, .ko]
    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "me_languages".localized
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension LanguageSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellId")
        }
        cell?.textLabel?.text = languageStrArr[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LocalizationTool.shared.setLanguage(language: languageArr[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
