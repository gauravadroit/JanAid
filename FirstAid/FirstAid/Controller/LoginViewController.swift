//
//  LoginViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Toast_Swift
import NVActivityIndicatorView

class LoginViewController: UIViewController {

    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        submitBtn.layer.cornerRadius = 5
        submitBtn.addTarget(self, action: #selector(self.submitBtnAction(sender:)), for: .touchUpInside)
        self.navigationController?.navigationBar.isHidden = true
        Utility.setGradient(view: self.view)
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func submitBtnAction(sender:UIButton) {
        self.view.endEditing(true)
        
        if emailText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "User name is required.")
            return
        }
        
        if passwordText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Password is required.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        let parameter:[String:String] = [
        "FlagNo":"0",
        "UserID":"0",
        "UserName":emailText.text!,
        "Password":passwordText.text!,
        "Description":"IOS",
        "DescriptionDetail" : "LoggedIN",
        "DeviceID":UIDevice.current.identifierForVendor?.uuidString ?? "null",
        "DeviceType":"iOS"
        ]
        
       
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.gpLogin, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
                
                if json["Data"]["UserType"].stringValue == "GP User" {
                    GPUser.name = json["Data"]["UserName"].stringValue
                    GPUser.merchantKey = json["Data"]["Merchantkey"].stringValue
                    GPUser.UserId = json["Data"]["UserID"].stringValue
                    GPUser.descr = json["Data"]["Description"].stringValue
                    GPUser.active = "true"
                
                    UserDefaults.standard.setValue(GPUser.name, forKey: "GPName")
                    UserDefaults.standard.setValue(GPUser.active, forKey: "GPActive")
                    UserDefaults.standard.setValue(GPUser.merchantKey, forKey: "GPKey")
                    UserDefaults.standard.setValue(GPUser.UserId, forKey: "GPUserId")
                    UserDefaults.standard.setValue(GPUser.descr, forKey: "GPDescription")
                    UserDefaults.standard.setValue("GP", forKey: "UserType")
                    UserDefaults.standard.setValue("yes", forKey: "login")
                
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "GP", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    
                }else  if json["Data"]["UserType"].stringValue == "Pacific User" {
                    
                    PIUser.name = json["Data"]["UserName"].stringValue
                    PIUser.merchantKey = json["Data"]["Merchantkey"].stringValue
                    PIUser.UserId = json["Data"]["UserID"].stringValue
                    PIUser.descr = json["Data"]["Description"].stringValue
                    
                    UserDefaults.standard.setValue(PIUser.name, forKey: "PIName")
                    UserDefaults.standard.setValue(PIUser.merchantKey, forKey: "PIKey")
                    UserDefaults.standard.setValue(PIUser.UserId, forKey: "PIUserId")
                    UserDefaults.standard.setValue(PIUser.descr, forKey: "PIDescription")
                    UserDefaults.standard.setValue("PI", forKey: "UserType")
                    UserDefaults.standard.setValue("yes", forKey: "login")
                    
                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "PI", bundle: nil)
                    let viewController = mainStoryboard.instantiateViewController(withIdentifier: "PITabBarcontroller") as! UITabBarController
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                }
                
            }else{
                self.view.makeToast("Invalid user.", duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
