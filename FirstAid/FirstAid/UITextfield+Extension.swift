//
//  UITextfield+Extension.swift
//  Phase
//
//  Created by Mahabir on 15/02/18.
//  Copyright © 2018 Mahabir. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
open class DesignTextfield: UITextField {
    
    @IBInspectable var conerRadius:CGFloat = 0.0 {
        didSet{
            layer.cornerRadius = conerRadius
        }
        
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) { 
     // Drawing code
     }
     */
    
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            
            if (self.placeholder?.contains("*"))! {
                let attString = NSMutableAttributedString(string:self.placeholder! )
                attString.addAttribute(NSAttributedStringKey.foregroundColor, value: newValue!, range: NSRange(location: 0, length: (self.placeholder?.count)! - 1))
                attString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red.withAlphaComponent(0.7) , range: NSRange(location: (self.placeholder?.count)! - 1, length: 1))
                self.attributedPlaceholder = attString
                
            }else{
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
            }
        }
        
        
    }
}
