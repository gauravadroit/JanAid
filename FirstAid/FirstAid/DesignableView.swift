//
//  DesignableView.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import Foundation
import UIKit

class DesignableView: UIView {
    // Corner Radius.
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    //Background Color.
    @IBInspectable var backColor: UIColor? {
        didSet {
            backgroundColor = backColor
        }
    }
    //Border Width.
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    //Border Color.
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
