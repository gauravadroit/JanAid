//
//  AddDetailViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 12/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class AddDetailViewController: UIViewController {

    @IBOutlet weak var addressTextView: UITextView!
    
    @IBOutlet weak var alternateMobileText: UITextField!
    @IBOutlet weak var mobileText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var selfBtn: UIButton!
    
    var timeSlotData:[String:String]!
    var pickerView:PickerTool!
    var isSelf:String!
    var titleStr:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.title = titleStr
        alternateMobileText.delegate = self
        mobileText.delegate = self
        genderText.delegate = self
        ageText.delegate = self
        nameText.delegate = self
        
        mobileText.isUserInteractionEnabled = false
        
        mobileText.text = User.mobileNumber
        nameText.text = User.firstName
        lastNameText.text = User.lastName
        
        pickerView = PickerTool.loadClass() as? PickerTool
        genderText.inputView = pickerView

        selfBtn.setImage(UIImage(named: "radioselected"), for: .normal)
        otherBtn.setImage(UIImage(named: "radio"), for: .normal)
        isSelf = "True"
        
        addressTextView.text = ""
        addressTextView.layer.cornerRadius = 5
        addressTextView.layer.borderWidth = 1
        addressTextView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.addTarget(self, action: #selector(self.nextAction(sender:)), for: .touchUpInside)
        otherBtn.addTarget(self, action: #selector(self.selectOption(sender:)), for: .touchUpInside)
        selfBtn.addTarget(self, action: #selector(self.selectOption(sender:)), for: .touchUpInside)
    }
    
    
    @objc func selectOption(sender:UIButton) {
        if otherBtn == sender {
            otherBtn.setImage(UIImage(named: "radioselected"), for: .normal)
            selfBtn.setImage(UIImage(named: "radio"), for: .normal)
            nameText.text = ""
            lastNameText.text = ""
            isSelf = "False"
        }else{
            selfBtn.setImage(UIImage(named: "radioselected"), for: .normal)
            otherBtn.setImage(UIImage(named: "radio"), for: .normal)
            nameText.text = User.firstName
            lastNameText.text = User.lastName
            isSelf = "True"
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func nextAction(sender:UIButton){
        
        if nameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert first name.")
            return
        }
        
        if ageText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert age .")
            return
        }
        
        if Int(ageText.text!)! <= 0 || Int(ageText.text!)! >= 110 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert valid age .")
            return
        }
        
        if genderText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert gender.")
            return
        }
        
        if mobileText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert mobile.")
            return
        }
        
        if alternateMobileText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert alternate mobile number.")
            return
        }

        
        if addressTextView.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert address.")
            return
        }
        
        var gender:String = ""
        
        if genderText.text! == "Male" {
            gender = "1"
        }else if genderText.text! == "Female" {
            gender = "2"
        }else if genderText.text! == "Other" {
            gender = "3"
        }
        
        
        let parameter:[String:String] = [
            "PatientID": User.patientId,
            "PromoUsedID": User.UsedPromoID,
            "IsSelf": isSelf,
            "FirstName": nameText.text!,
            "LastName": lastNameText.text!,
            "GenderID": gender,
            "Age": ageText.text!,
            "ContactNumber": mobileText.text!,
            "eMailID": User.emailId,
            "Address": addressTextView.text!,
            "Locality": timeSlotData["locality"]!,
            "City": timeSlotData["city"]!,
            "State": timeSlotData["state"]!,
            "IsServiceAvailable": "True",
            "Zipcode": timeSlotData["pincode"]!,
            "AlternameNumber": alternateMobileText.text!,
            "SampleCollectionDate": timeSlotData["date"]!,
            "SampleCollectionSlot": timeSlotData["timeslot"]!,
            "SampleCollectionSlotID": timeSlotData["timeSlotId"]!,
            "PincodeID": timeSlotData["localityId"]!
        ]
        
        print(parameter)
        let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "AddSlotViewController") as! AddSlotViewController
        nextview.testData = parameter
        self.navigationController?.pushViewController(nextview, animated: true)
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

extension AddDetailViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        if textField == genderText  {
            if genderText.text == "" {
                genderText.text = "Male"
            }
            self.setPickerInfo(genderText, withArray: ["Male","Female","Other"])
        }
        
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any]){
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
}
