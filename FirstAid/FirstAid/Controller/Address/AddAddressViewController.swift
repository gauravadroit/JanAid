//
//  AddAddressViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AddAddressViewController: UIViewController {
    @IBOutlet weak var contactText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var streetText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var pincodeText: UITextField!
    @IBOutlet weak var countryText: UITextField!
    @IBOutlet weak var localityText: UITextField!
    @IBOutlet weak var addressTypeText: UITextField!
    
    @IBOutlet weak var submitBtn: UIButton!
    var pickerView:PickerTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "ADD ADDRESS"
        submitBtn.layer.cornerRadius = 5
        
        contactText.keyboardType = .numberPad
        pincodeText.keyboardType = .numberPad
        contactText.delegate = self
        nameText.delegate = self
        streetText.delegate = self
        cityText.delegate = self
        stateText.delegate = self
        pincodeText.delegate = self
        countryText.delegate = self
        localityText.delegate = self
        addressTypeText.delegate = self
        //self.tabBarController?.tabBar.isHidden = true
        
        
        pickerView = PickerTool.loadClass() as? PickerTool
        addressTypeText.inputView = pickerView
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        self.addAddress()
    }
   
    func addAddress() {
        
        if nameText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill name.")
            return
        }
        
        if contactText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill contact.")
            return
        }
        
        if streetText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill street name.")
            return
        }
        
        if cityText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill city name.")
            return
        }
        
        if stateText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill state name.")
            return
        }
        
        if pincodeText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill pincode.")
            return
        }
        
        
        if countryText.text!.trim().count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill country name.")
            return
        }
        
        
        let parameter:[String:String] = [
            "name": nameText.text!.trim(),
            "street1":streetText.text!.trim(),
            "city":cityText.text!.trim(),
            "pincode":pincodeText.text!.trim(),
            "country":countryText.text!.trim(),
            "contactNo":contactText.text!.trim(),
            "state":stateText.text!.trim(),
            "addressType":addressTypeText.text!,
            "locality":localityText.text!.trim(),
            "street2": " "
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addAddress, dataDict: parameter, headers: headers, { (json) in
            print(json)
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["result"]["id"].stringValue != "" {
                self.navigationController?.popViewController(animated: true)
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

extension AddAddressViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == addressTypeText  {
            if addressTypeText.text == "" {
                addressTypeText.text = "Home"
            }
            
            self.setPickerInfo(addressTypeText, withArray: ["Home","Office"])
        }
        
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any])
    {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
}

