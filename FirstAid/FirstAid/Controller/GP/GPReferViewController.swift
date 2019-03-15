//
//  GPReferViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView
//import NotificationBannerSwift

class GPReferViewController: UIViewController, IndicatorInfoProvider {

    
    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Refer")
    }
    
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
    var hospitalArr:[hospital] = []
    var hospitalNameArr:[String] = []
    
    var specialityArr:[hospital] = []
    var specialityNameArr:[String] = []
    var hospitalId:Int!
    var specialityId:Int!
    
    @IBOutlet weak var adviceTextView: UITextView!
    @IBOutlet weak var specialityText: UITextField!
    @IBOutlet weak var hospitalText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var pickerView:PickerTool!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getHospital()
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        pickerView = PickerTool.loadClass() as? PickerTool
        hospitalText.inputView = pickerView
        hospitalText.delegate = self
        
        specialityText.inputView = pickerView
        specialityText.delegate = self
        
        self.setIconInTextfield(textField: specialityText)
        self.setIconInTextfield(textField: hospitalText)
        
        adviceTextView.layer.cornerRadius = 5
        adviceTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        adviceTextView.layer.borderWidth = 1
        adviceTextView.delegate = self
        //adviceLabel.isHidden = true
        adviceTextView.text = "Advice  "
        adviceTextView.textColor = UIColor.lightGray
        
        self.callId = GPAdvice.callId
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
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPHospital + GPAdvice.callId, headers: Webservice.header, { (json) in
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
                for data in json["Data"].arrayValue {
                    self.doctorArr.append(doctor.init(
                        name: data["DoctorName"].stringValue,
                        specialityId: data["SpecialityID"].stringValue,
                        SpecialityName: data["SpecialityName"].stringValue,
                        doctorId: data["DoctorID"].stringValue
                    ))
                }
                self.tableView.reloadData()
            }
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    
   @objc func assignHospital(sender:UIButton) {
        let parameter:[String:String] = [
            "FlagNo":"1",
            "CallID":self.callId,
            "CallStatus":"HS",
            "MainDoctorID":self.doctorArr[sender.tag].doctorId,
            "Advice":adviceTextView.text!,
            "UserID":GPUser.UserId,
            "HospitalID":hospitalArr[hospitalId].value
        ]
    
        print(parameter)
    
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
    
         
        
        ShowLoader.startLoader(view: self.view)
    
    
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAssignHospital, dataDict: parameter, headers: Webservice.header, { (json) in
            ShowLoader.stopLoader()
            print(json)
            if json["Message"].stringValue == "Success" {
                UIApplication.shared.keyWindow?.makeToast("Hospital assigned successfully." , duration: 3.0, position: .bottom)
                self.navigationController?.popToRootViewController(animated: true)
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

extension GPReferViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if specialityText == textField {
            self.setPickerInfo(specialityText, withArray: self.specialityNameArr)
        }else{
            self.setPickerInfo(hospitalText, withArray: self.hospitalNameArr)
        }
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any]) {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == hospitalText {
            if textField.text! != "" {
                self.hospitalId = self.hospitalNameArr.index(of: textField.text!)
                self.getSpecialist(hospitalId: self.hospitalArr[self.hospitalId].value)
            }
        }else{
            if textField.text! != "" {
                self.specialityId = self.specialityNameArr.index(of: textField.text!)
                self.getDoctors()
            }
        }
    }
    
}

extension GPReferViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctorArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GPReferCell", for: indexPath) as! GPReferCell
        cell.doctorNameLabel.text = doctorArr[indexPath.row].name
        cell.specialityLabel.text = doctorArr[indexPath.row].SpecialityName
        cell.assignBtn.tag = indexPath.row
        cell.assignBtn.addTarget(self, action: #selector(self.assignHospital(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
}

extension GPReferViewController:UITextViewDelegate {
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text!.count == 0 {
            adviceTextView.text = "Advice  "
            adviceTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text! == "Advice  " {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
}


