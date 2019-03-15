//
//  ViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 07/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Toast_Swift
//import NotificationBannerSwift
import NVActivityIndicatorView
import FacebookLogin
import FacebookCore
import SwiftyJSON

class RegisterViewController: UIViewController {

    @IBOutlet weak var alreadyView: UIView!
    @IBOutlet weak var scrollingView: UIView!
    @IBOutlet weak var termsTextView: UITextView!
    @IBOutlet weak var backgroundViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var submitBtn: UIButton!
   /* @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var addressText: UITextField!
    @IBOutlet weak var circleView6: DesignableView!
    @IBOutlet weak var circleView5: DesignableView!
    @IBOutlet weak var cityView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var addressInfoView: UIView!
    @IBOutlet weak var addressInfoHeightConstraint: NSLayoutConstraint!*/
    
    @IBOutlet weak var mobileNumberText: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var codeView: DesignableView!
    @IBOutlet weak var codeText: UITextField!
    
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    let termsAndConditionsURL = "http://www.example.com/terms";
    let privacyURL = "http://www.example.com/privacy";
    var acceptTermsFlag:Int = 0
    var acceptPrivacyFlag:Int = 0
    
    var isAgree:String = "false"
    
    var codeFlag:String = "0"
    var genderId:Int = 0
    var conditionView:TermsCondition!
    var OTPValue:String = ""
    
    @IBOutlet weak var conditionFlagBtn: UIButton!
    @IBOutlet weak var codeFlagBtn: UIButton!
    @IBOutlet weak var otpText: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var otpView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        firstNameTxt.delegate = self
        lastNameTxt.delegate = self
        
       
        mobileNumberText.delegate = self
        mobileNumberText.keyboardType = .numberPad
        
        firstNameTxt.autocorrectionType = .no
        lastNameTxt.autocorrectionType = .no
        
       
        codeText.delegate = self
        submitBtn.layer.cornerRadius = 5
        otpView.layer.cornerRadius = 5
        alreadyView.layer.cornerRadius = 5
        
        backView.isHidden = true
        otpView.isHidden = true
        self.alreadyView.isHidden = true
        
        submitBtn.addTarget(self, action: #selector(self.registrationAction(sender:)), for: UIControlEvents.touchUpInside)
        let icon2 = #imageLiteral(resourceName: "unchecked").withRenderingMode(.alwaysTemplate)
        conditionFlagBtn.setImage(icon2, for: UIControlState.normal)
        codeFlagBtn.setImage(icon2, for: UIControlState.normal)
        
        let icon = #imageLiteral(resourceName: "radio").withRenderingMode(.alwaysTemplate)
        maleBtn.setImage(icon, for: UIControlState.normal)
        femaleBtn.setImage(icon, for: UIControlState.normal)
        otherBtn.setImage(icon, for: UIControlState.normal)
      
        self.termsTextView.delegate = self
        termsTextView.isSelectable = true
        termsTextView.isEditable = false
        //termsTextView.isScrollEnabled = false
        termsTextView.isUserInteractionEnabled = true
        let myAttribute = [ NSAttributedStringKey.foregroundColor: UIColor(red: 86.0/255.0, green: 86.0/255.0, blue: 86.0/255.0, alpha: 1.0), NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 17) ]
        let attributedString = NSMutableAttributedString(string: "I agree with the Terms of use and Privacy policy.", attributes: myAttribute )
        attributedString.addAttribute(.link, value: termsAndConditionsURL, range: NSRange(location: 17, length: 12))
        attributedString.addAttribute(.link, value: privacyURL, range: NSRange(location: 34, length: 15))
        termsTextView.attributedText = attributedString
       
        // self.checkAlreadyLogin()
        self.addressInfoHide()
        
        
    }
    
    
    override func viewDidLayoutSubviews() {
        Utility.setGradient(view: self.view)
        Utility.setGradient(view: self.scrollingView)
    }
    
    func getOTP(mobileNumber:String) {
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
                if json["Data"]["IsVerificationRequired"].stringValue == "false" {
                    self.OTPValue = "12345"
                    let btn = UIButton()
                    self.registrationAction(sender: btn)
                }else{
                    self.backView.isHidden = false
                    self.otpView.isHidden = false
                    self.OTPValue = json["Data"]["OTPValue"].stringValue
                }
                
            }
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
        }
        
    }
    
 
   
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        backView.isHidden = true
        otpView.isHidden = true
        otpText.text = ""
        self.OTPValue = ""
    }
    
    @IBAction func OkBtnAction(_ sender: UIButton) {
        
        if otpText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter OTP.")
            return
        }
        
        if self.OTPValue == otpText.text! {
            backView.isHidden = true
            otpView.isHidden = true
            otpText.text = ""
            self.registrationAction(sender: sender)
        }else{
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Invalid OTP")
        }
    }
    
    @IBAction func callBtn(_ sender: UIButton) {
        if let url = URL(string: "tel://\(Webservice.callCenter)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
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
        self.conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptPrivacyBtn(sender:)), for: .touchUpInside)
        self.conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreementPrivacy(sender:)), for: UIControlEvents.touchUpInside)
       
        
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/PrivacyPolicy.htm")
        let requestObj = URLRequest(url: url!)
        self.conditionView.webView.loadRequest(requestObj)
        
        
        self.view.addSubview(self.conditionView)
        
    }
    
    @objc func acceptPrivacyBtn(sender:UIButton) {
        if acceptPrivacyFlag == 0 {
            acceptPrivacyFlag = 1
            sender.setImage(#imageLiteral(resourceName: "checksquare"), for: .normal)
        }else{
            acceptPrivacyFlag = 0
            sender.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }
    }
    
    @objc func removeAgreementPrivacy(sender:UIButton) {
       
        self.conditionView.removeFromSuperview()
    }
    
    
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
        self.conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptTermsBtn(sender:)), for: .touchUpInside)
        self.conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreementTerms(sender:)), for: UIControlEvents.touchUpInside)
       
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/TermsAndConditionsForPatient.htm")
        let requestObj = URLRequest(url: url!)
        self.conditionView.webView.loadRequest(requestObj)
        self.view.addSubview(self.conditionView)
        
        
    }
    
   
    @objc func acceptTermsBtn(sender:UIButton) {
        if acceptTermsFlag == 0 {
            acceptTermsFlag = 1
            sender.setImage(#imageLiteral(resourceName: "checksquare"), for: .normal)
        }else{
            acceptTermsFlag = 0
            sender.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }
    }
    
    
    @objc func removeAgreementTerms(sender:UIButton) {
      
        self.conditionView.removeFromSuperview()
    }
    
    @IBAction func agreeAction(_ sender: UIButton) {
        
        let icon = #imageLiteral(resourceName: "unchecked").withRenderingMode(.alwaysTemplate)
        let icon2 = #imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate)
        
        if isAgree == "false" {
            isAgree = "true"
            sender.setImage(icon2, for: UIControlState.normal)
        }else{
            sender.setImage(icon, for: UIControlState.normal)
            isAgree = "false"
        }
    }
    @IBAction func codeAction(_ sender: UIButton) {
        let icon = #imageLiteral(resourceName: "unchecked").withRenderingMode(.alwaysTemplate)
        let icon2 = #imageLiteral(resourceName: "checked").withRenderingMode(.alwaysTemplate)
        if self.codeFlag == "0" {
            self.codeFlag = "1"
            sender.setImage(icon2, for: UIControlState.normal)
            self.addressInfoShow()
        }else{
            self.codeFlag = "0"
            sender.setImage(icon, for: UIControlState.normal)
            self.addressInfoHide()
        }
    }
    
    
    
    
    func addressInfoHide() {
      
        codeText.isHidden = true
        codeView.isHidden = true
        backgroundViewHeightContraint.constant = 785
      
    }
    
    func addressInfoShow() {
      
        codeText.isHidden = false
        codeView.isHidden = false
        backgroundViewHeightContraint.constant = 785
    }
    
    @IBAction func genderSelectionAction(_ sender: UIButton) {
        let icon = #imageLiteral(resourceName: "radio").withRenderingMode(.alwaysTemplate)
        let icon2 = #imageLiteral(resourceName: "radioselected").withRenderingMode(.alwaysTemplate)
    
        if sender == maleBtn {
            genderId = 1
            maleBtn.setImage(icon2, for: UIControlState.normal)
            femaleBtn.setImage(icon, for: UIControlState.normal)
            otherBtn.setImage(icon, for: UIControlState.normal)
        }else if sender == femaleBtn {
            genderId = 2
            maleBtn.setImage(icon, for: UIControlState.normal)
            femaleBtn.setImage(icon2, for: UIControlState.normal)
            otherBtn.setImage(icon, for: UIControlState.normal)
        }else if sender == otherBtn {
            genderId = 3
            maleBtn.setImage(icon, for: UIControlState.normal)
            femaleBtn.setImage(icon, for: UIControlState.normal)
            otherBtn.setImage(icon2, for: UIControlState.normal)
        }
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
                        
                        print(JSON(responseDictionary))
                       
                        
                    }
                }
            })
        }
    }
    
    
    
   @objc func registrationAction(sender:UIButton) {
    
    
        
        if firstNameTxt.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.nofirstName)
            return
        }
    
    
        if lastNameTxt.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noLastName)
            return
        }
    
        if genderId == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.gender)
            return
        }
    
        
        if mobileNumberText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noMobileNumber)
            return
        }
    
    
    
    if (mobileNumberText.text?.count)! < 10 || (mobileNumberText.text?.count)! > 10{
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter valid number")
            return
        }
    
        if codeFlag == "1" {
            if codeText.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill your MFI Code")
            return
            }
        }
    
        if isAgree == "false" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.terms)
            return
        }
    
    
        if codeFlag == "1" && otpText.text! == "" {
            self.getAgentCode(code: codeText.text!)
            return
        }
    
        var ISMFI:String = "fasle"
    
        if codeFlag == "1" {
            ISMFI = "true"
        }
    
        if self.OTPValue == "" {
            self.getOTP(mobileNumber: mobileNumberText.text!)
            return
        
        }
   
        let parameter:[String:Any] = [
            "FlagNo": 0,
            "PatientID": 0,
            "FirstName": firstNameTxt.text!,
            "LastName": lastNameTxt.text!,
            "FatherName": "",
            "GenderID": genderId, // 1 Male 2 Female 3 Other
            "MobileNumber": mobileNumberText.text!,
            "EmailID": "",
            "DeviceType": "iOS",
            "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "null",
            "CountryID": "",
            "StateID": "",
            "CityID": "",
            "AreaID": "",
            "StatusID": 1,
            "MFIID": "",
            "Description": "",
            "DOB": "",
            "Source": "IOS",
            "MFIAgentCode":codeText.text!,
            "ISMFI": ISMFI
        ]
    
   
    if  !Reachability.isConnectedToNetwork() {
        Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            
        })
        
        return
    }
    
     
    ShowLoader.startLoader(view: self.view)
   
    
    DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registartion, dataDict: parameter, headers: Webservice.header, { (json) in
        
    
    
   
        print(json)
         ShowLoader.stopLoader()
        if json["Status"].stringValue == "true" {
            User.firstName = json["Data"]["FirstName"].stringValue
            User.lastName = json["Data"]["LastName"].stringValue
            User.motherName = json["Data"]["MotherName"].stringValue
            User.mobileNumber = json["Data"]["MobileNumber"].stringValue
            User.emailId = json["Data"]["EmailID"].stringValue
            User.patientId = json["Data"]["PatientID"].stringValue
            User.genderId = json["Data"]["GenderID"].stringValue
            User.statusId = json["Data"]["StatusID"].stringValue
            User.flagNumber = json["Data"]["FlagNo"].stringValue
            User.isMFI = json["Data"]["ISMFI"].stringValue
            
            User.oneMGLab = json["Data"]["ISRegisteredOn1mgLAB"].stringValue
            User.oneMGLabToken = json["Data"]["LabAuthorizedToken"].stringValue
            
            User.oneMgPharmacy = json["Data"]["ISRegisteredOn1mgPharmacy"].stringValue
            User.oneMGAuthenticationToken = json["Data"]["PharmacyAuthorizedToken"].stringValue
            
            
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
        
            self.registerDeviceToken()
            
            
            if json["Data"]["StatusText"].stringValue == "Y" {
               self.backView.isHidden = false
                self.alreadyView.isHidden = false
            }else{
                let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
                let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
                let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
                mfSideMenuContainer.leftMenuViewController = leftSideMenuController
                mfSideMenuContainer.centerViewController = dashboard
                let appDelegate  = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = mfSideMenuContainer
            }
        }else{
            self.view.makeToast("Unable to process.", duration: 3.0, position: .bottom)
        }
        
    }) { (error) in
        print(error)
        self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        ShowLoader.stopLoader()
    }
    }
    
    @IBAction func registraionOkAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
        let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        mfSideMenuContainer.leftMenuViewController = leftSideMenuController
        mfSideMenuContainer.centerViewController = dashboard
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mfSideMenuContainer
    }
    
    
    
    
    func getAgentCode(code:String) {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getAgentCode + code, headers: Webservice.header, { (json) in
            print(json)
             ShowLoader.stopLoader()
            
          
            
            if json["Data"]["IsAgenValid"].stringValue == "true" {
               
                self.OTPValue = json["Data"]["OTPValue"].stringValue
                self.otpText.text = self.OTPValue
                let btn = UIButton()
                self.registrationAction(sender: btn)
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
             ShowLoader.stopLoader()
        }
        
    }
    
    func registerDeviceToken() {
        var deviceToken:String = " "
        if let temp = UserDefaults.standard.string(forKey: "deviceToken") {
            deviceToken = temp
        }
        
        let parameter:[String:String] = [
            "FlagNo":"2",
            "UserType":"P",
            "UserID": User.patientId,
            "TokenNo":deviceToken
        ]
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registerDeviceToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
        }) { (error) in
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            print(error)
        }
    }


func checkAlreadyLogin() {
    
    var Login:String = ""
    if let temp  = UserDefaults.standard.string(forKey: "login") {
        Login = temp
    }
    // check user alerdy login or not
    
    if Login == "yes" {
        if let temp = UserDefaults.standard.string(forKey: "firstName") {
            print(temp)
            User.firstName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "lastName") {
            print(temp)
            User.lastName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "motherName") {
            print(temp)
            User.motherName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "MobileNumber") {
            print(temp)
            User.mobileNumber = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "patientId") {
            print(temp)
            User.patientId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "genderId") {
            print(temp)
            User.genderId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "speciality") {
            print(temp)
            User.speciality = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "specialityId") {
            print(temp)
            User.specialityId = temp
        }

        DispatchQueue.main.async() {
            self.performSegue(withIdentifier: "register", sender: nil)
        }

        
        
    }
}
}


extension RegisterViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == firstNameTxt {
            lastNameTxt.becomeFirstResponder()
        }else if textField == lastNameTxt {
            mobileNumberText.becomeFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        if firstNameTxt == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
            
        }else if lastNameTxt == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
            
        }else if mobileNumberText == textField {
            let allowedCharacter = "0123456789+- "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == codeText {
           // self.getAgentCode(code: textField.text!)
        }
    }
    
}

extension RegisterViewController:UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        let btn = UIButton()
        if (URL.absoluteString == termsAndConditionsURL) {
            self.termsUseAction(btn)
        } else if (URL.absoluteString == privacyURL) {
             self.privacyPolicyAction(btn)
        }
        return false
    }
}



