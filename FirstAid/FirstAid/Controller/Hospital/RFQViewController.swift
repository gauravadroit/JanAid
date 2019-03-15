//
//  RFQViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RFQViewController: UIViewController {

    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var LastNameText: UITextField!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var tpaBtn: UIButton!
    @IBOutlet weak var cashBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var otherBtn: UIButton!
    @IBOutlet weak var mobileText: UITextField!
    
    var genderId = 0
    var paymentMethod:String = ""
    var packageId:String!
    var packageName:String!
    
    var packageExclusion:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Ask for Quote"
       
        self.setIconInTextfield(textField: emailText)
        self.setIconInTextfield(textField: ageText)
        self.setIconInTextfield(textField: LastNameText)
        self.setIconInTextfield(textField: firstNameText)
        self.setIconInTextfield(textField: mobileText)
        
        self.emailText.delegate = self
        self.ageText.delegate = self
        self.LastNameText.delegate = self
        self.firstNameText.delegate = self
        self.mobileText.delegate = self
        
        self.packageNameLabel.text = self.packageName
        
        self.firstNameText.text = User.firstName
        self.LastNameText.text = User.lastName
        self.mobileText.text = User.mobileNumber
        
        let icon = #imageLiteral(resourceName: "radio")
        let icon2 = #imageLiteral(resourceName: "radioselected")
        
        if User.genderId == "1" {
            genderId = 1
            maleBtn.setImage(icon2, for: UIControlState.normal)
            femaleBtn.setImage(icon, for: UIControlState.normal)
            otherBtn.setImage(icon, for: UIControlState.normal)
        }else if User.genderId == "2"{
            genderId = 2
            maleBtn.setImage(icon, for: UIControlState.normal)
            femaleBtn.setImage(icon2, for: UIControlState.normal)
            otherBtn.setImage(icon, for: UIControlState.normal)
        }else if User.genderId == "3" {
            genderId = 3
            maleBtn.setImage(icon, for: UIControlState.normal)
            femaleBtn.setImage(icon, for: UIControlState.normal)
            otherBtn.setImage(icon2, for: UIControlState.normal)
        }
        
        self.submitBtn.layer.cornerRadius = 5
        self.commentTextView.text = ""
        self.commentTextView.layer.borderWidth = 1
        self.commentTextView.layer.cornerRadius = 5
        self.commentTextView.delegate = self
        self.commentTextView.text = "Comment  "
        self.commentTextView.textColor = UIColor.lightGray
        
        paymentMethod = "Cash"
        cashBtn.setImage(icon2, for: UIControlState.normal)
        tpaBtn.setImage(icon, for: UIControlState.normal)
        
        self.maleBtn.addTarget(self, action: #selector(self.genderSelectionAction(_:)), for: .touchUpInside)
        self.femaleBtn.addTarget(self, action: #selector(self.genderSelectionAction(_:)), for: .touchUpInside)
        self.otherBtn.addTarget(self, action: #selector(self.genderSelectionAction(_:)), for: .touchUpInside)
        
        self.cashBtn.addTarget(self, action: #selector(self.paymentMethodAction(sender:)), for: .touchUpInside)
        self.tpaBtn.addTarget(self, action: #selector(self.paymentMethodAction(sender:)), for: .touchUpInside)
        
        self.submitBtn.addTarget(self, action: #selector(self.submitAction), for: .touchUpInside)
        
        self.getIPDPackageInfo()
    }
    
  
    func setIconInTextfield(textField:UITextField, image:UIImage = #imageLiteral(resourceName: "userblack") ) {
       
        let icon = image.withRenderingMode(.alwaysTemplate)
        let dropdown = UIImageView(image: icon)
        dropdown.tintColor = UIColor.black
        dropdown.frame = CGRect(x: 0.0, y: 0.0, width: dropdown.image!.size.width+15.0, height: dropdown.image!.size.height);
        dropdown.contentMode = UIViewContentMode.center
        textField.leftView = dropdown;
        textField.leftViewMode = UITextFieldViewMode.always
    }
    
    @IBAction func genderSelectionAction(_ sender: UIButton) {
        let icon = #imageLiteral(resourceName: "radio")
        let icon2 = #imageLiteral(resourceName: "radioselected")
        
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
    
    @objc func paymentMethodAction(sender:UIButton) {
        let icon = #imageLiteral(resourceName: "radio")
        let icon2 = #imageLiteral(resourceName: "radioselected")
        
        if sender == cashBtn {
            paymentMethod = "Cash"
            cashBtn.setImage(icon2, for: UIControlState.normal)
            tpaBtn.setImage(icon, for: UIControlState.normal)
        }else if sender == tpaBtn {
            paymentMethod = "Tpa"
            cashBtn.setImage(icon, for: UIControlState.normal)
            tpaBtn.setImage(icon2, for: UIControlState.normal)
        }
    }
    
    
    func getIPDPackageInfo() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.IPDpackagesInfo + packageId, headers: Webservice.header, { (json) in
            print(json)
             ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"]["PackageExclusion"].arrayValue {
                    self.packageExclusion.append(data["ExclusionName"].stringValue)
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    
    @objc func submitAction() {
        
        self.view.endEditing(true)
        
        if firstNameText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.nofirstName)
            return
        }
        
        
        if LastNameText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noLastName)
            return
        }
        
        if ageText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill age.")
            return
        }
        
        
        if mobileText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noMobileNumber)
            return
        }
        
        
        
        if (mobileText.text?.count)! < 10 || (mobileText.text?.count)! > 10{
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter valid number")
            return
        }
        
        
        if Int(ageText.text!)! <= 0  || Int(ageText.text!)! > 105  {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please correct age.")
            return
        }
        
        if emailText.text?.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill email address.")
            return
        }
        
        if paymentMethod == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select payment type.")
            return
        }
        
        var comment:String = ""
        
        /*if commentTextView.text == "Comment  " {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill comments.")
            return
        }else{*/
            comment = commentTextView.text!
       // }
        
        
        let parameter:[String:String] = [
            "PackageID": packageId,
            "PatientID": User.patientId,
            "FirstName": firstNameText.text!,
            "LastName": LastNameText.text!,
            "Age": ageText.text!,
            "GenderID":String(genderId),
            "Type":paymentMethod,
            "EmailID":emailText.text!,
            "MobileNumber":mobileText.text!,
            "Comment": comment
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.submitRQA, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }
           
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
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

extension RFQViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.packageExclusion.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text =  self.packageExclusion[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}

extension RFQViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if (isBackSpace == -92) {
            return true
        }
        
        if firstNameText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textField.text?.count)! < 100 {
                return string == numberFiltered
            }else{
                return false
            }
            
        }else if LastNameText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textField.text?.count)! < 200 {
                return string == numberFiltered
            }else{
                return false
            }
            
        }else if ageText == textField {
            let allowedCharacter = "0123456789"
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textField.text?.count)! < 3 {
                return string == numberFiltered
            }else{
                return false
            }
        }else if emailText == textField {
            if (textField.text?.count)! < 200 {
                return true
            }else{
                return false
            }
        }
        
        return true
    }
    
}

extension RFQViewController:UITextViewDelegate{
    
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text!.count == 0 {
            self.commentTextView.text = "Comment  "
            self.commentTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text! == "Comment  " {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        
        
        if commentTextView == textView {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890.',/;:\" "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = text.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textView.text?.count)! < 500 {
                return text == numberFiltered
            }else{
                return false
            }
            
        }
        
        return true
    }
}


