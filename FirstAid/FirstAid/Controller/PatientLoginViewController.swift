//
//  PatientLoginViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 28/11/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import SwiftyJSON
import GoogleSignIn

class PatientLoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var termsBtn: UIButton!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var doctorLoginBtn: UIButton!
    @IBOutlet weak var privacyBtn: UIButton!
    
    var otpValue:String!
    var otpId:String!
    var fbJson:JSON!
    
    var conditionView:TermsCondition!
    var acceptPrivacyFlag:Int = 0
    var acceptTermsFlag:Int = 0
    
    
    
    var googleInfo:[String:String] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()

       registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = Webservice.themeColor.cgColor
        self.navigationController?.navigationBar.isHidden = true
        submitBtn.addTarget(self, action: #selector(self.submitAction), for: .touchUpInside)
        
        googleBtn.layer.borderWidth = 1
        googleBtn.layer.borderColor = UIColor(red: 192.0/255.0, green: 57.0/255.0, blue: 43.0/255.0, alpha: 1.0).cgColor
        googleBtn.addTarget(self, action: #selector(self.googleSignIn), for: .touchUpInside)
        
        facebookBtn.layer.borderWidth = 1
        facebookBtn.layer.borderColor = UIColor(red: 30.0/255.0, green: 54.0/255.0, blue: 110.0/255.0, alpha: 1.0).cgColor
        facebookBtn.addTarget(self, action: #selector(self.facebookLoginAction(_:)), for: .touchUpInside)
        
        termsBtn.addTarget(self, action: #selector(self.termsUseAction(_:)), for: .touchUpInside)
        privacyBtn.addTarget(self, action: #selector(self.privacyPolicyAction(_:)), for: .touchUpInside)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        mobileText.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.googleAction(notification:)), name: NSNotification.Name(rawValue: "googleSignIn"), object: nil)
    }
    
    
    // Terms and Uses

    @IBAction func termsUseAction(_ sender: UIButton) {
        self.conditionView = TermsCondition(frame: CGRect(x: 15, y: 25, width: self.view.frame.size.width - 30, height: self.view.frame.size.height - 50))
        self.conditionView.headerLabel.text = "Terms of use"
        self.conditionView.dropShawdow()
        if self.acceptTermsFlag == 0 {
            self.conditionView.acceptBtn.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }else{
            self.conditionView.acceptBtn.setImage(#imageLiteral(resourceName: "checksquare"), for: .normal)
        }
        
        self.conditionView.acceptBtn.isHidden = true
        self.conditionView.okBtn.isHidden = true
        self.conditionView.closeBtn.addTarget(self, action: #selector(self.removeAgreementTerms(sender:)), for: UIControlEvents.touchUpInside)
       // self.conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptTermsBtn(sender:)), for: .touchUpInside)
        self.conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreementTerms(sender:)), for: UIControlEvents.touchUpInside)
        
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/TermsAndConditionsForPatient.htm")
        let requestObj = URLRequest(url: url!)
        self.conditionView.webView.loadRequest(requestObj)
        self.view.addSubview(self.conditionView)
        
    }
    
    //Privacy Policy
    
    @IBAction func privacyPolicyAction(_ sender: UIButton) {
        self.conditionView = TermsCondition(frame: CGRect(x: 15, y: 25, width: self.view.frame.size.width - 30, height: self.view.frame.size.height - 50))
        self.conditionView.headerLabel.text = "Privacy Policy"
        self.conditionView.dropShawdow()
        if self.acceptPrivacyFlag == 0 {
            self.conditionView.acceptBtn.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }else{
            self.conditionView.acceptBtn.setImage(#imageLiteral(resourceName: "checksquare"), for: .normal)
        }
        self.conditionView.acceptBtn.isHidden = true
        self.conditionView.okBtn.isHidden = true
        self.conditionView.closeBtn.addTarget(self, action: #selector(self.removeAgreementTerms(sender:)), for: UIControlEvents.touchUpInside)
      //  self.conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptPrivacyBtn(sender:)), for: .touchUpInside)
        //self.conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreementPrivacy(sender:)), for: UIControlEvents.touchUpInside)
        
        
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/PrivacyPolicy.htm")
        let requestObj = URLRequest(url: url!)
        self.conditionView.webView.loadRequest(requestObj)
        
        
        self.view.addSubview(self.conditionView)
        
    }
    
    
    
    @objc func removeAgreementTerms(sender:UIButton) {
        self.conditionView.removeFromSuperview()
    }
    
    
    
    @objc func submitAction(){
       self.getOTP(mobileNumber: mobileText.text!)
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
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.loginWithVerifiedNumber + mobileNumber, headers: Webservice.header, { (json) in
            ShowLoader.stopLoader()
            print(json)
            
            if json["Status"].stringValue == "true" {
                if json["Data"]["IsVerificationRequired"].stringValue == "false" {
                    self.otpValue = json["Data"]["OTPValue"].stringValue
                    self.otpId = json["Data"]["OTPID"].stringValue
                    self.inputOTP()
                }
                
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
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
                
                self.loginWithOTP(otp: (textField?.text)!)
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func loginWithOTP(otp:String) {
        
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
            "MobileNumber": mobileText.text!,
            "OTPID": self.otpId,
            "DeviceToken": deviceToken,
            "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "null",
            "DeviceType":"IOS"
        ]
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.loginOTP, dataDict: parameter, headers: Webservice.header, { (json) in
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
    
    
    @objc func googleAction(notification:NSNotification) {
        let userInfo : [String:String] = (notification.userInfo as? [String:String])!
        print(userInfo)
        
        self.googleInfo = userInfo
        self.loginWithSocialMedia(SocialId: userInfo["socialid"]!, SocialType: "GOGL")
    
    }
    
    
    @objc func googleSignIn(){
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    // Facebook Integration
    
    @IBAction func facebookLoginAction(_ sender: UIButton) {
        
        
        if !Reachability.isConnectedToNetwork() {
            //  let banner = NotificationBanner(title: "Alert", subtitle:Message.noInternet , style: .danger)
            //  banner.show(queuePosition: .front)
            return
        }
        
        let loginManager = LoginManager()
        
        
        loginManager.loginBehavior = LoginBehavior.systemAccount
        
        loginManager.logOut()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                
                
                print("Logged in!")
                self.getFBUser()
            }
        }
    }
    
    
    func getFBUser() {
        if AccessToken.current != nil {
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,gender"], accessToken: AccessToken.current, httpMethod: .POST, apiVersion: GraphAPIVersion.defaultVersion).start({ (response, result) in
                
                print(response as Any)
                print(result)
                
                switch result {
                case .failed(let error):
                    print("error in graph request:", error)
                    break
                case .success(let graphResponse):
                    if let responseDictionary = graphResponse.dictionaryValue {
                        
                       self.fbJson = JSON(responseDictionary)
                        print(self.fbJson)
                        
                        self.loginWithSocialMedia(SocialId: self.fbJson["id"].stringValue, SocialType: "FCBK")
                        
                    }
                }
            })
        }
    }
    
    
    func loginWithSocialMedia(SocialId:String, SocialType:String) {
        
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
            "ThirdPartyID": SocialId,
            "ThirdPartyTypeCode":SocialType,   //(FCBK for Facebok, GOGL for Google)
            "DeviceType":"IOS",         //(APK or IOS)
            "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "null",
            "DeviceToken": deviceToken
        ]
        
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.thirdPartyLogin, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Code"].stringValue == "200" && json["Status"].stringValue == "false" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "MobileOtpViewController") as! MobileOtpViewController
                nextView.json = self.fbJson
                nextView.socialType = SocialType
                nextView.googleInfo = self.googleInfo
                self.navigationController?.pushViewController(nextView, animated: true)
                
            }else if json["Code"].stringValue == "200" && json["Status"].stringValue == "true" {
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

extension PatientLoginViewController:UITextFieldDelegate {
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
