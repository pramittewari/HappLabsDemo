//
//  UIView.swift
//  StickerApp
//
//  Created by Pramit on 21/02/20.
//  Copyright © 2020 Credencys Solutions Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    /// Adds shadow to a view
    func dropShadow(withColor color: UIColor = UIColor.black, shadowOpacity: Float = 0.5, xOffset: Int = -1, yOffset: Int = 3, scale: Bool = true, viewRadius: CGFloat = 8.0, shouldRasterize: Bool = false) {
        
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = CGSize(width: xOffset, height: yOffset)
        layer.shadowRadius = viewRadius
        layer.cornerRadius = viewRadius
        layer.shouldRasterize = shouldRasterize
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
