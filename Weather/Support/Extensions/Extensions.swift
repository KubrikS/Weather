//
//  Extensions.swift
//  Weather
//
//  Created by Stanislav on 09.11.2020.
//

import UIKit

// Add bottom shadow for current, forecast and favourite cell
extension UIView {
    func addBottomShadow() {
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 3
        layer.masksToBounds = false
    }
}
