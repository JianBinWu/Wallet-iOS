//
//  DAppBrowserViewController.swift
//  BlockChainWallet
//
//  Created by user on 2021/7/5.
//

import UIKit
import WebKit
import WalletConnect
import PromiseKit

class DAppBrowserViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    let urlRequest = URLRequest(url: URL(string: "https://app.uniswap.org/")!)
    var interactor: WCInteractor?
    let clientMeta = WCPeerMeta(name: "BCWallet", url: "https://github.com/JianBinWu/Wallet")
    let address = UserDefaults.standard.string(forKey: ChainType.eth.rawValue)?.add0xIfNeeded()
    let defaultChainId = isMainNet ? 1 : 42
    var recommendGasPrice = "0"
    
    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView()
        progressView.progressViewStyle = .bar
        progressView.backgroundColor = UIColor(hexString: "0xC6E6FB")
        progressView.tintColor = UIColor(hexString: "0x499CF7")
        return progressView;
    }()
    lazy var webView: WKWebView = {
        let webView = WKWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.layoutUI()
        webView.load(urlRequest)
        getFee()
    }
    
    func layoutUI() {
        view.backgroundColor = .white
        //layout webView
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        //layout progressView
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(webView)
            make.height.equalTo(1.5)
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        progressView.progress = Float(webView.estimatedProgress)
    }
    
    //custom method
    func getFee() {
        showHUD()
        AF.request("https://api.blockcypher.com/v1/eth/main").responseJSON {[weak self] (response) in
            switch response.result {
            case .success:
                if let value = response.value as? [String: Any], let weiGasPrice = value["high_gas_price"] as? Int64 {
                    let handler = NSDecimalNumberHandler(roundingMode: .plain, scale: 9, raiseOnExactness: false, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
                    let ethGasPrice = NSDecimalNumber(value: weiGasPrice).dividing(by: NSDecimalNumber(value: 1e18)).rounding(accordingToBehavior: handler)
                    self!.recommendGasPrice = ethGasPrice.stringValue
                }
            default:
                break
            }
            hideHUD()
        }
    }
    
    func connect(session: WCSession) {
        print("==> session", session)
        let interactor = WCInteractor(session: session, meta: clientMeta, uuid: UIDevice.current.identifierForVendor ?? UUID())

        configure(interactor: interactor)

        interactor.connect().done {connected in
            if !connected {
                hideHUD()
                print("connected: \(connected)")
            }
        }.catch { error in
            hideHUD()
            print("connect error: \(error.localizedDescription)")
        }

        self.interactor = interactor
    }
    
    func configure(interactor: WCInteractor) {
        let accounts = [address!]
        let chainId = defaultChainId

        interactor.onError = { error in
            print("error: \(error.localizedDescription)")
        }

        interactor.onSessionRequest = { [weak self] (id, peerParam) in
            hideHUD()
            let alert = UIAlertController(title: "\(self!.title!) \("DApp_connectRequest".localized)", message: "DApp_allowGetAddress".localized, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: { _ in
                self?.interactor?.rejectSession().cauterize()
            }))
            alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: { _ in
                self?.interactor?.approveSession(accounts: accounts, chainId: chainId).cauterize()
            }))
            self?.navigationController?.present(alert, animated: true, completion: nil)
        }

        interactor.onDisconnect = { (error) in
            if let error = error {
                print(error)
            }
        }

        interactor.eth.onSign = { [weak self] (id, payload) in
            self!.interactor!.rejectRequest(id: id, message: "").cauterize()
        }

        interactor.eth.onTransaction = { [weak self] (id, event, transaction) in
            let data = try! JSONEncoder().encode(transaction)
            let alert = UIAlertController(title: self!.title, message: "\(self!.title!) \("DApp_accessWalletSignWarn".localized)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .destructive, handler: { _ in
                self?.interactor?.rejectRequest(id: id, message: "DApp_transactionCanceled".localized).cauterize()
            }))
            alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: { _ in
                let dataDic = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                self!.analyseData(dataDic as! [String: String], with: id)
            }))
            self?.navigationController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func analyseData(_ dataDic: [String: String], with id: Int64) {
        let data = dataDic["data"]!
        var amountStr = "0"
        if dataDic["value"] != nil {
            amountStr =  dataDic["value"]!.hexToDecimal()
        }
        let recommendGas = dataDic["gas"]!.hexToDecimal()
        let minerFee = NSDecimalNumber(string: recommendGasPrice).multiplying(by: NSDecimalNumber(string: recommendGas)).stringValue
        
        weak var weakSelf = self
        var transactionDataDic = dataDic
        transactionDataDic["value"] = amountStr
        transactionDataDic["fee"] = minerFee
        transactionDataDic["gas"] = recommendGas
        var alertTitle = ""
        var alertMessage = ""
        if data.hasPrefix("0x095ea7b3") {
            alertTitle = "DApp_applyForAuthorization".localized
            alertMessage = "\(title!) \("DApp_applyForAuthorizationDetail".localized)"
        } else {
            alertTitle = "TransferDetail_PayInfo".localized
            alertMessage = transactionDataDic.toJsonString(options: .prettyPrinted)!
        }
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .destructive, handler: { _ in
            weakSelf!.interactor?.rejectRequest(id: id, message: "DApp_transactionCanceled".localized).cauterize()
        }))
        alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: { _ in
            weakSelf!.showPasswordAlert(dataDic: transactionDataDic, with: id)
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func showPasswordAlert(dataDic: [String: String], with id: Int64) {
        weak var weakSelf = self
        let alert = UIAlertController(title: "Transfer_InputPwdRemind".localized, message: nil, preferredStyle: .alert)
        alert.addTextField {
            $0.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: { action in
            showHUD()
            let password = alert.textFields?.first?.text
            DispatchQueue.global().async {
                let result = ethTransferFromDApp(dataDic, password: password ?? "")
                DispatchQueue.main.async {
                    hideHUD()
                    var hashString = ""
                    if result.contains("Transfer_Success") {
                        hashString = result.replacingOccurrences(of: "Transfer_Success", with: "")
                        weakSelf!.interactor?.approveRequest(id: id, result: hashString).cauterize()
                    } else {
                        popToast(result.localized)
                        weakSelf!.interactor?.rejectRequest(id: id, message: "DApp_transactionFailed").cauterize()
                    }
                }
            }
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    //WKUIDelegate, WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        weak var weakSelf = self
        webView.evaluateJavaScript("document.title") { result, error in
            weakSelf!.title = result as? String
        }
        UIView.animate(withDuration: 0.2) {
            weakSelf!.progressView.progress = 1
        } completion: {_ in
            weakSelf!.progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let uri = navigationAction.request.url?.absoluteString ?? ""
        if uri.contains("wc?uri=") {
            showHUD()
            let wcUri = String(uri.suffix(from: uri.range(of: "wc?uri=")!.upperBound)).removingPercentEncoding!
            guard let session = WCSession.from(string: wcUri) else {
                print("invalid uri: \(String(describing: wcUri))")
                hideHUD()
                return
            }
            connect(session: session)
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: {_ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: {_ in
            completionHandler(false)
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: webView.title, message: prompt, preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "btn_confirm".localized, style: .default, handler: { _ in
            completionHandler(alert.textFields?.first?.text)
        }))
        alert.addAction(UIAlertAction(title: "btn_cancel".localized, style: .cancel, handler: {_ in
            completionHandler("")
        }))
        navigationController?.present(alert, animated: true, completion: nil)
    }
    

}
