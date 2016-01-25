//
//  MaterialTextField.swift
//  ios-app-showcase
//
//  Created by Ilya Shaisultanov on 1/24/16.
//  Copyright © 2016 Ilya Shaisultanov. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {
    override func awakeFromNib() {
        layer.cornerRadius = 2
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1
    }
    
    // for placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    // for editable text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
}
