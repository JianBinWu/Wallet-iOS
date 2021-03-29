//
//  UIView+Extension.swift
//  HuanXiRead
//
//  Created by user on 2020/7/2.
//  Copyright © 2020 Steven Wu. All rights reserved.
//

import UIKit

enum ViewShadowType: Int {
    case top
    case right
    case bottom
    case left
}

extension UIView {
    //
    func addShadow(color: UIColor, opacity: Float, radius: CGFloat, type: ViewShadowType, shadowWidth: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        var shadowRect: CGRect = .zero
        let originX: CGFloat = 0, originY: CGFloat = 0, sizeWidth = bounds.width, sizeHeight = bounds.height
        
        switch type {
        case .top:
            shadowRect = .init(x: originX, y: originY - shadowWidth, width: sizeWidth, height: shadowWidth)
        case .bottom:
            shadowRect = .init(x: originX, y: sizeHeight, width: sizeWidth, height: shadowWidth)
        case .left:
            shadowRect = .init(x: originX - shadowWidth, y: originY, width: shadowWidth, height: sizeHeight)
        case .right:
            shadowRect = .init(x: sizeWidth, y: 0, width: shadowWidth, height: sizeHeight)
        }
        
        let bezierPath = UIBezierPath.init(rect: shadowRect)
        layer.shadowPath = bezierPath.cgPath
    }
    
    //
    func addShadow(offset: CGSize) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = offset
    }
    
    //
    func addCorner(_ radius: CGFloat, corners: UIRectCorner) {
        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath
        layer.mask = shape
    }
}
