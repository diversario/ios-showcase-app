//
//  MaterialButton.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {
    override func awakeFromNib() {
        layer.cornerRadius = 2
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 2)
    }
}
