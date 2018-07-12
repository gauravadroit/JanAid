//
//  Utility.swift
//  Phase
//
//  Created by Mahabir on 19/02/18.
//  Copyright © 2018 Mahabir. All rights reserved.
//

import Foundation
import UIKit

class Utility: NSObject {
    
    class func isValidEmail(email:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    class func showMessageDialog( onController controller: UIViewController, withTitle title: String?,  withMessage message: String?, withError error: NSError? = nil, onClose closeAction: (() -> Void)? = nil) {
        var mesg: String?
        if let err = error {
            mesg = "\(message)\n\n\(err.localizedDescription)"
            NSLog("Error: %@ (error=%@)", message!, (error ?? ""))
        } else {
            mesg = message
        }
        
        let alert = UIAlertController(title: title, message: mesg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
            if let action = closeAction {
                action()
            }
        })
        controller.present(alert, animated: true, completion: nil)
    }
    
    class func showMessageDialogWithCancel( onController controller: UIViewController, withTitle title: String?,  withMessage message: String?, withError error: NSError? = nil, onClose closeAction: (() -> Void)?, onCancel cancelCloseAction: (() -> Void)? = nil) {
        var mesg: String?
        if let err = error {
            mesg = "\(message ?? " ")\n\n\(err.localizedDescription)"
            NSLog("Error: %@ (error=%@)", message!, (error ?? ""))
        } else {
            mesg = message
        }
        
        let alert = UIAlertController(title: title, message: mesg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
            if let action = closeAction {
                action()
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            if let action = cancelCloseAction {
                action()
            }
        })
        controller.present(alert, animated: true, completion: nil)
    }
    
    
   /* class func showMessageDialogWithCancel (controller: UIViewController ,withTitle title: String?,  withMessage message: String?, _ okBlock:@escaping ()->Void , cancelBlock: @escaping () -> Void ){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { (_) in
           okBlock()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            cancelBlock()
        })
        controller.present(alert, animated: true, completion: nil)
    }
    */
    
    class  func setGradient(view:UIView) {
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.colors = [UIColor(red: 188.0/255.0, green: 238.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor , UIColor(red: 36.0/255.0, green: 189.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
