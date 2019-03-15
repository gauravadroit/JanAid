//
//  PIReassignDoctorViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 16/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PIReassignDoctorViewController: UIViewController {

    @IBOutlet weak var doctorText: UITextField!
    @IBOutlet weak var specialityNameText: UITextField!
    @IBOutlet weak var hospitalNameText: UITextField!
    
    
    
    struct hospital {
        var value:String!
        var text:String!
    }

    struct doctor {
        var name:String!
        var specialityId:String!
        var SpecialityName:String!
        var doctorId:String!
    }
    
    var callId:String!
    
    var doctorArr:[doctor] = []
    var doctorNameArr:[String] = []
    var hospitalArr:[hospital] = []
    var hospitalNameArr:[String] = []
    
    var specialityArr:[hospital] = []
    var specialityNameArr:[String] = []
    var hospitalId:Int!
    var specialityId:Int!
    var doctorId:Int!
    var pickerView:PickerTool!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getHospital()
        pickerView = PickerTool.loadClass() as? PickerTool
        hospitalNameText.inputView = pickerView
        hospitalNameText.delegate = self
        
        specialityNameText.inputView = pickerView
        specialityNameText.delegate = self
        
        doctorText.inputView = pickerView
        doctorText.delegate = self
        
        self.setIconInTextfield(textField: hospitalNameText)
        self.setIconInTextfield(textField: specialityNameText)
        self.setIconInTextfield(textField: doctorText)
        self.title = "Re-assign"
        submitBtn.layer.cornerRadius = 5
    }
    
    func setIconInTextfield(textField:UITextField) {
        let dropdown = UIImageView(image: UIImage(named: "drop"))
        dropdown.frame = CGRect(x: 0.0, y: 0.0, width: dropdown.image!.size.width+15.0, height: dropdown.image!.size.height);
        dropdown.contentMode = UIViewContentMode.center
        textField.rightView = dropdown;
        textField.rightViewMode = UITextFieldViewMode.always
    }

    
    
    func getHospital() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPHospital + callId, headers: Webservice.header, { (json) in
            print(json)
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.hospitalArr.append(hospital.init(
                        value: data["HospitalID"].stringValue,
                        text: data["HospitalName"].stringValue
                    ))
                    
                    self.hospitalNameArr.append(data["HospitalName"].stringValue)
                }
            }
            ShowLoader.stopLoader()
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    func getSpecialist(hospitalId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPgetSpeciality + hospitalId , headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.specialityArr.append(hospital.init(
                        value: data["Value"].stringValue,
                        text: data["Text"].stringValue
                    ))
                    
                    self.specialityNameArr.append(data["Text"].stringValue)
                }
            }
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    
    func getDoctors() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:Any] = [
            "FlagNo":"0",
            "HospitalID":self.hospitalArr[self.hospitalId].value!,
            "SpecialityID":self.specialityArr[self.specialityId].value!
        ]
        
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPgetDoctor, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                self.doctorArr = []
                self.doctorNameArr = []
                for data in json["Data"].arrayValue {
                    self.doctorArr.append(doctor.init(
                        name: data["DoctorName"].stringValue,
                        specialityId: data["SpecialityID"].stringValue,
                        SpecialityName: data["SpecialityName"].stringValue,
                        doctorId: data["DoctorID"].stringValue
                    ))
                    
                    self.doctorNameArr.append(data["DoctorName"].stringValue)
                }
               
            }
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }

    @IBAction func nextBtnAction(_ sender: UIButton) {
        self.assignHospital()
    }
    
    
    func assignHospital() {
        
        if hospitalNameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select hospital")
            return
        }
        
        if specialityNameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select speciality")
            return
        }
        
        if doctorText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select doctor.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:String] = [
            "CallID":callId,
            "UserID":PIUser.UserId,
            "MainDoctorID":doctorArr[self.doctorId].doctorId,
            "HospitalID":self.hospitalArr[self.hospitalId].value
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.reassignHospital, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.navigationController?.popViewController(animated: true)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PIReassignDoctorViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if specialityNameText == textField {
            self.setPickerInfo(specialityNameText, withArray: self.specialityNameArr)
        }else if hospitalNameText == textField {
            self.setPickerInfo(hospitalNameText, withArray: self.hospitalNameArr)
        }else{
             self.setPickerInfo(doctorText, withArray: self.doctorNameArr)
        }
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any]) {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == hospitalNameText {
            if textField.text! != "" {
                self.hospitalId = self.hospitalNameArr.index(of: textField.text!)
                self.getSpecialist(hospitalId: self.hospitalArr[self.hospitalId].value)
            }
        }else if textField == specialityNameText{
            if textField.text! != "" {
                self.specialityId = self.specialityNameArr.index(of: textField.text!)
                print(self.specialityId)
                self.getDoctors()
            }
        }else if textField == doctorText {
            if textField.text! != "" {
                self.doctorId = self.doctorNameArr.index(of: textField.text!)
            }
        }
    }
    
}
