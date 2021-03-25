//
//  LocalizationTool.swift
//  BlockChainWallet
//
//  Created by user on 2021/3/23.
//

import Foundation
import UIKit

enum Language:String {
    case en
    case zhHans = "zh-Hans"
    case zhHant = "zh-Hant"
    case ko
    case ja
}

let currentLanguageKey = "appLanguage"

class LocalizationTool {
    static let shared = LocalizationTool()
    
    let defaults = UserDefaults.standard
    var bundle: Bundle?
    var currentLanguage: Language = .en
    
    func valueWithKey(key: String) -> String {
        let bundle = LocalizationTool.shared.bundle
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: "Localization", bundle: bundle, value: "", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    func setLanguage(language: Language) {
        if currentLanguage == language {
            return
        }
        defaults.setValue(language.rawValue, forKey: currentLanguageKey)
        defaults.synchronize()
        currentLanguage = getLanguage()
        
        let tabBarVC = CustomTabBarViewController()
        UIApplication.shared.windows.first!.rootViewController = tabBarVC
    }
    
    func checkLanguage() {
        currentLanguage = getLanguage()
    }
    
    private func getLanguage() -> Language {
        var str = ""
        if let language = defaults.value(forKey: currentLanguageKey) as? String {
            str = language
        } else {
            str = getSystemLanguage()
        }
        if let path = Bundle.main.path(forResource: str, ofType: "lproj") {
            bundle = Bundle(path: path)
        }
        return Language(rawValue: str)!
    }
    
    private func getSystemLanguage() -> String {
        let preferredLang = String(describing: Bundle.main.preferredLocalizations.first! as NSString)
        if preferredLang.hasPrefix("zh-Hans") {
            return "zh-Hans"
        }
        if preferredLang.hasPrefix("zh-Hant") || preferredLang.hasPrefix("zh-HK") || preferredLang.hasPrefix("zh-TW") {
            return "zh-Hant"
        }
        if preferredLang.hasPrefix("en") {
            return "en"
        }
        if preferredLang == "ko" || preferredLang == "ja" {
            return preferredLang
        }
        return "en"
    }
}

extension String {
    var localized: String {
        return LocalizationTool.shared.valueWithKey(key: self)
    }
}
