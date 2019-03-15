//
//  CustomerRegisterViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 07/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class CustomerRegisterViewController: UIViewController {

    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var confirmPasswordText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    var otpValue:String!
    
    var pickerView:PickerTool!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitBtn.layer.cornerRadius = 5
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        genderText.delegate = self
        emailText.delegate = self
        mobileText.delegate = self
        submitBtn.addTarget(self, action: #selector(self.submitAction), for: .touchUpInside)
        
        pickerView = PickerTool.loadClass() as? PickerTool
        genderText.inputView = pickerView
        
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func submitAction(){
        self.submitData()
    }
    
    
    func submitData(otp:String = "0") {
        
        self.view.endEditing(true)
        
        if firstNameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter first name.")
            return
        }
        
        if lastNameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter last name.")
            return
        }
        
        if genderText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select gender.")
            return
        }
        
        if emailText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter email address.")
            return
        }
        
        if mobileText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter mobile number.")
            return
        }
        
        if mobileText.text!.count > 10 || mobileText.text!.count < 10 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter valid mobile number.")
            return
        }
        
        
        if otpValue != otp {
            self.getOTP(mobileNumber: mobileText.text!)
            return
        }
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        var genderId:String = ""
        
        if genderText.text! == "Male" {
            genderId = "1"
        }else if genderText.text! == "Female" {
            genderId = "2"
        }else if genderText.text! == "Other" {
            genderId = "3"
        }
        
        var deviceToken:String = "00"
        if let temp = UserDefaults.standard.string(forKey: "deviceToken") {
            deviceToken = temp
        }
      
        
        
        let parameter:[String:String] = [
            "DeviceType":"IOS",
            "DeviceID":UIDevice.current.identifierForVendor?.uuidString ?? "null",
            "DeviceToken": deviceToken,
            "EmailID":emailText.text!,
            "FirstName": firstNameText.text!,
            "LastName": lastNameText.text!,
            "GenderID": genderId,
            "ProfilePicture":"",
            "Source":"IOS",
            "MobileNumber": mobileText.text!
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registerPatient, dataDict: parameter, headers: Webservice.header, { (json) in
            
            ShowLoader.stopLoader()
            print(json)
            
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            
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
            }else{
                
            }
            
            
        }) { (error) in
            
            print(error)
            ShowLoader.stopLoader()
        }
        
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
                
                self.submitData(otp: self.otpValue)
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
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

extension CustomerRegisterViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == genderText  {
            if genderText.text == "" {
                genderText.text = "Male"
            }
            
            self.setPickerInfo(genderText, withArray: ["Male","Female","Other"])
        }
        
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any])
    {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
}
