//
//  MobileOtpViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 08/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SwiftyJSON

class MobileOtpViewController: UIViewController {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var mobileText: UITextField!
    var googleInfo:[String:String]!
    var otpValue:String!
    var json:JSON!
    var socialType:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        submitBtn.addTarget(self, action: #selector(self.submitAction), for: UIControlEvents.touchUpInside)
        mobileText.delegate = self
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func submitAction(){
        let mobileNumber = mobileText.text!
        self.getOTP(mobileNumber: mobileNumber)
    }
    
    
    func getOTP(mobileNumber:String) {
        
        if mobileText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter mobile number.")
            return
        }
        
        if mobileText.text!.count > 10 || mobileText.text!.count < 10 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter valid mobile number.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getOTP + mobileNumber, headers: Webservice.header, { (json) in
            ShowLoader.stopLoader()
            print(json)
            
            if json["Status"].stringValue == "true" {
                if json["Data"]["IsVerificationRequired"].stringValue == "true" {
                    self.otpValue = json["Data"]["OTPValue"].stringValue
                    self.inputOTP()
                }
                
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    func inputOTP()  {
        let alert = UIAlertController(title: "", message: "Enter OTP", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.keyboardType = .numberPad
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print("Text field: \(String(describing: textField?.text))")
            
            if (textField?.text)! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert OTP.")
            }else{
                
                if self.otpValue != (textField?.text)! {
                    Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert valid OTP.")
                    return
                }
                
                if self.socialType == "FCBK" {
                    self.registerWithSocialMedia(socialId: self.json["id"].stringValue, socialType: "FCBK", Email: self.json["email"].stringValue, firstName: self.json["first_name"].stringValue, lastName: self.json["last_name"].stringValue, profilePic: self.json["data"]["url"].stringValue)
                }else{
                    self.registerWithSocialMedia(socialId: self.googleInfo["socialid"] ?? " ", socialType: "GOGL", Email: self.googleInfo["email"] ?? " ", firstName: self.googleInfo["first_name"] ?? " ", lastName: self.googleInfo["last_name"] ?? " ", profilePic: "")
                }
               
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func registerWithSocialMedia(socialId:String, socialType:String, Email:String, firstName:String, lastName:String, profilePic:String) {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        var deviceToken:String = "00"
        if let temp = UserDefaults.standard.string(forKey: "deviceToken") {
            deviceToken = temp
        }
        
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:String] = [
            "ThirdPartyID":socialId,
            "ThirdPartyTypeCode":socialType,
            "DeviceType":"IOS",
            "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "null",
            "DeviceToken":deviceToken,
            "EmailID":Email,
            "FirstName":firstName,
            "LastName":lastName,
            //"GenderName":"Male",
            "ProfilePicture": profilePic,
            "Source":"IOS",
            "MobileNo":mobileText.text!
        ]
        
        print(parameter)
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registerWithSocialMedia, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                User.firstName = json["Data"][0]["FirstName"].stringValue
                User.lastName = json["Data"][0]["LastName"].stringValue
                User.motherName = json["Data"][0]["MotherName"].stringValue
                User.mobileNumber = json["Data"][0]["MobileNumber"].stringValue
                User.emailId = json["Data"][0]["EmailID"].stringValue
                User.patientId = json["Data"][0]["PatientID"].stringValue
                User.genderId = json["Data"][0]["GenderID"].stringValue
                User.statusId = json["Data"][0]["StatusID"].stringValue
                User.flagNumber = json["Data"][0]["FlagNo"].stringValue
                User.isMFI = json["Data"][0]["ISMFI"].stringValue
                
                User.oneMGLab = json["Data"][0]["ISRegisteredOn1mgLAB"].stringValue
                User.oneMGLabToken = json["Data"][0]["LabAuthorizedToken"].stringValue
                
                User.oneMgPharmacy = json["Data"][0]["ISRegisteredOn1mgPharmacy"].stringValue
                User.oneMGAuthenticationToken = json["Data"][0]["PharmacyAuthorizedToken"].stringValue
                
                
                UserDefaults.standard.setValue(User.firstName, forKey: "firstName")
                UserDefaults.standard.setValue(User.lastName, forKey: "lastName")
                UserDefaults.standard.setValue(User.motherName, forKey: "motherName")
                UserDefaults.standard.setValue(User.mobileNumber, forKey: "MobileNumber")
                UserDefaults.standard.setValue(User.patientId , forKey: "patientId")
                UserDefaults.standard.setValue(User.genderId, forKey: "genderId")
                UserDefaults.standard.setValue(User.emailId, forKey: "email")
                UserDefaults.standard.setValue(User.isMFI, forKey: "isMFI")
                
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgPharmacy")
                
                UserDefaults.standard.setValue(User.oneMGLab, forKey: "ISRegisteredOn1mgLAB")
                UserDefaults.standard.setValue(User.oneMGLabToken, forKey: "oneMGLabToken")
                
                UserDefaults.standard.setValue("Patient", forKey: "UserType")
                UserDefaults.standard.setValue("yes", forKey: "login")
                
              //  self.registerDeviceToken()
                
                
               // if json["Data"]["StatusText"].stringValue == "Y" {
                  //  self.backView.isHidden = false
                 //   self.alreadyView.isHidden = false
               // }else{
                    let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
                    let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
                    let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                    let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
                    mfSideMenuContainer.leftMenuViewController = leftSideMenuController
                    mfSideMenuContainer.centerViewController = dashboard
                    let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = mfSideMenuContainer
                //}
            }else{
                self.view.makeToast("Unable to process.", duration: 3.0, position: .bottom)
            }

            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension MobileOtpViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            return true
        }
        
        if textField.text?.count == 10 {
            return false
        }else{
            return true
        }
    }
}

