//
//  AddLabAddressViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 26/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AddLabAddressViewController: UIViewController {

    @IBOutlet weak var pincodeText: UITextField!
    @IBOutlet weak var localityText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var contactText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var flatText: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    
    var tmpTextField:UITextField!
    var pickerView:PickerTool!
    
    struct locality {
        var name:String!
        var pincode:String!
    }
    
    var localityArr:[locality] = []
    var localityStrArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pincodeText.delegate = self
        self.localityText.delegate = self
        cityText.delegate = self
        stateText.delegate = self
        genderText.delegate = self
        contactText.delegate = self
        ageText.delegate = self
        nameText.delegate = self
        flatText.delegate = self
        
        pickerView = PickerTool.loadClass() as? PickerTool
        localityText.inputView = pickerView
        nextBtn.layer.cornerRadius = 5
    }
    
    
    func submitAction() {
        
        if nameText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill name")
        }
        if flatText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill flat a")
        }
        if contactText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill contact")
        }
        if stateText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill state")
        }
        if ageText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill age")
        }
        if cityText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill city")
        }
        if localityText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select locality")
        }
        if genderText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select gender")
        }
        
        if pincodeText.text == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill pincode")
        }
        
        LabAddress.pincodeText = pincodeText.text!
        LabAddress.localityText = localityText.text!
        LabAddress.cityText = cityText.text!
        LabAddress.contactText = contactText.text!
        LabAddress.ageText = ageText.text!
        LabAddress.nameText = nameText.text!
        LabAddress.flatText = flatText.text!
        LabAddress.stateText = stateText.text!
        LabAddress.genderText = genderText.text!
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LabOrderDetailsViewController") as! LabOrderDetailsViewController
        self.navigationController?.pushViewController(nextView, animated: true)
        
        
    }
    
    @IBAction func nextaction(_ sender: UIButton) {
        self.submitAction()
    }
    
    func getLocality(state:String,city:String,pincode:String) {
        
        let parameter:[String:String] = [
            "FlagNo":"1",
            "Value1":state,
            "Value2":city,
            "Value3":pincode,
            ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getLocality, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            if json["Message"].stringValue == "Success" {
                self.localityArr = []
                self.localityStrArr = []
                for data in json["Data"].arrayValue {
                    self.localityArr.append(locality.init(
                        name: data["LocalityName"].stringValue,
                        pincode: data["PinCode"].stringValue
                    ))
                    
                    self.localityStrArr.append(data["LocalityName"].stringValue)
                }
            }
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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

extension AddLabAddressViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderText {
            self.dropDown(textField, selector: ["Male","Female","other"])
            return false
        }else if textField == localityText  {
            self.setPickerInfo(localityText, withArray: self.localityStrArr)
            return true
        }else{
            return true
        }
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any])
    {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == cityText {
            self.getLocality(state: stateText.text!, city: cityText.text!, pincode: "")
        }else if textField == localityText {
            if localityText.text != "" {
                let index = self.localityStrArr.index(of: textField.text!)
                pincodeText.text = self.localityArr[index!].pincode
            }
        }
        
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == cityText {
            self.getLocality(state: stateText.text!, city: cityText.text! + string, pincode: "")
        }
        return true
    }
    
}

extension AddLabAddressViewController : UIPopoverPresentationControllerDelegate,PopViewControllerDelegate {
    
    func dropDown(_ textField:UITextField , selector:[String]) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
        popController.delegate = self
        popController.arr = selector
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = textField
        popController.popoverPresentationController?.sourceRect = textField.bounds
        popController.preferredContentSize = CGSize(width: 200, height: 170)
        self.present(popController, animated: true, completion: nil)
        tmpTextField = textField
    }
    
    func saveString(_ strText: String) {
        tmpTextField.text = strText
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle{
        return UIModalPresentationStyle.none
    }
    
}
