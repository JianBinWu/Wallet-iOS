//
//  UITextView+Extension.swift
//  HuanXiRead
//
//  Created by user on 2020/7/2.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import Foundation

extension UITextView {
    func setupPlaceholder(_ placeholder: String) {
        if font == nil {
            font = .systemFont(ofSize: 13)
        }
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = font
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textColor = UIColor(hexString: "#C5C8CA")
        placeholderLabel.sizeToFit()
        addSubview(placeholderLabel)
        setValue(placeholderLabel, forKey: "_placeholderLabel")
    }
}
