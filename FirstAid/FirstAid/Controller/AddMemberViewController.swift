//
//  AddMemberViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

class AddMemberViewController: UIViewController {

    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var ageView: UIView!
    @IBOutlet weak var relationText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var relationView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    var relationName:[String] = []
    var relationId:[String] = []
    var pickerView:PickerTool!
    
    var genderId:Int = 0
    
    var editFirstName:String!
    var editLastName:String!
    var editRelation:String!
    var editGender:String!
    var editPatientId:String!
    var edit:Bool = false
    var editAge:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Add Member"
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
       // self.tabBarController?.tabBar.isHidden = true
        addBtn.layer.cornerRadius = 5
        addBtn.layer.borderWidth = 1
        addBtn.layer.borderColor = UIColor(red: 22.0/255.0, green: 89.0/255.0, blue: 141.0/255.0, alpha: 1.0).cgColor
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor(red: 22.0/255.0, green: 89.0/255.0, blue: 141.0/255.0, alpha: 1.0).cgColor
        backgroundView.dropShawdow()
        
        relationView.layer.cornerRadius = 5
        relationView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        relationView.layer.borderWidth = 1
        
        firstNameView.layer.cornerRadius = 5
        firstNameView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        firstNameView.layer.borderWidth = 1
        
        lastNameView.layer.cornerRadius = 5
        lastNameView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        lastNameView.layer.borderWidth = 1
        
        ageView.layer.cornerRadius = 5
        ageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        ageView.layer.borderWidth = 1
        
        pickerView = PickerTool.loadClass() as? PickerTool
        relationText.inputView = pickerView
        
        firstNameText.delegate = self
        lastNameText.delegate = self
        relationText.delegate = self
        ageText.delegate = self
        
        if edit == true {
            firstNameText.text = editFirstName
            lastNameText.text = editLastName
            relationText.text = editRelation
            ageText.text = editAge
            addBtn.setTitle("EDIT", for: .normal)
            
            if editGender == "Male" {
                genderId = 1
                maleBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
            }else if editGender == "Female" {
                genderId = 2
                femaleBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
            }else if editGender == "Other" {
                genderId = 3
                otherBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
            }
            
            
        }
        
        
        self.getRelation()
       
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = false
    }

    
    func getRelation() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.getRelation , { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                self.relationId = []
                self.relationName = []
            
                for data in json["Data"].arrayValue {
                    self.relationName.append(data["Text"].stringValue)
                    self.relationId.append(data["Value"].stringValue)
                }
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    @IBAction func genderSelectAction(_ sender: UIButton) {
        if sender == maleBtn {
            genderId = 1
            maleBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
            femaleBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
            otherBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
        }else if sender == femaleBtn {
            genderId = 2
            maleBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
            femaleBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
            otherBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
        }else if sender == otherBtn {
            genderId = 3
            maleBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
            femaleBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
            otherBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
        }

    }
    @IBAction func addAction(_ sender: UIButton) {
        
        if firstNameText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.nofirstName)
            return
        }
        
        if lastNameText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noLastName)
            return
        }
        
        if ageText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill age.")
            return
        }
        
        if Int(ageText.text!)! <= 0  || Int(ageText.text!)! > 105  {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please correct age.")
            return
        }
        
        
        if relationText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select releation.")
            return
        }
        
        if genderId == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select gender.")
            return
        }
        
        
        
        let id = relationId[relationName.index(of:relationText.text!)!]
        
        if sender.titleLabel?.text == "EDIT" {
            
            if Int(ageText.text!)! < 0 || Int(ageText.text!)! > 100  {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert vaild date.")
                return
            }
            
            let parameter:[String:Any] = [
                "FlagNo": 3,
                "PatientID": editPatientId!,
                "FirstName": firstNameText.text!,
                "LastName": lastNameText.text!,
                "GenderID": genderId, // 1 Male 2 Female 3 Other
                "RelationID":id,
                "Age":ageText.text!
            ]
            
            print(parameter)
            print(Webservice.registartion)
            
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                    
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
            
             DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registartion, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                if json["Message"].stringValue == "Success" {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }) { (error) in
                print(error)
                ShowLoader.stopLoader()
                self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            }
            
        }else{
       
            
            if Int(ageText.text!)! < 0 || Int(ageText.text!)! > 100  {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert vaild date.")
                return
            }
        
            let parameter:[String:Any] = [
                "FlagNo": 0,
                "PatientID": 0,
                "FirstName": firstNameText.text!,
                "LastName": lastNameText.text!,
                "MotherName": "",
                "FatherName": "",
                "GenderID": genderId, // 1 Male 2 Female 3 Other
                "MobileNumber": User.mobileNumber!,
                "EmailID": "",
                "Address": "",
                "CountryID": "",
                "StateID": "",
                "CityID": "",
                "AreaID": "",
                "StatusID": 1,
                "MFIID": "",
                "Description": "",
                "DOB": "",
                "Source": "IOS",
                "ParentID":User.patientId!,
                "RelationID":id,
                "Age":ageText.text!
            ]
        
            print(parameter)
            print(Webservice.registartion)
        
        
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                    
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
        
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registartion, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                
                if json["Message"].stringValue == "Success" {
                    self.navigationController?.popViewController(animated: true)
                }
            
            }) { (error) in
                print(error)
                ShowLoader.stopLoader()
                self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            }
            }
        
    }
        
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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

extension AddMemberViewController:UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if firstNameText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
            
        }else if lastNameText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }else if ageText == textField {
            let allowedCharacter = "0123456789"
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        
        return true
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == firstNameText{
           
        }else if textField == relationText  {
            if relationText.text == "" {
                relationText.text = "Brother"
            }
            
            self.setPickerInfo(relationText, withArray: self.relationName)
        }
        
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any])
    {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
}
