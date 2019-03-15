//
//  BookLabTestViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 15/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class BookLabTestViewController: UIViewController {
    
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pincodeText: UITextField!
    
    @IBOutlet weak var timeSlotText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var localityText: UITextField!
    
    @IBOutlet weak var stateText: UITextField!
    @IBOutlet weak var cityText: UITextField!
    struct Locality {
        var isServiceAvailable:String!
        var pincode:String!
        var city:String!
        var state:String!
        var Locality: String!
        var pincodeId:String!
    }
    
    var localityArr:[Locality] = []
    var LocalityStr:[String] = []
    var pickerView:PickerTool!
    var timeSlot:[String] = []
    var timeSlotId:[String] = []
    var titleStr:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = titleStr
        pincodeText.delegate = self
        localityText.delegate = self
        timeSlotText.delegate = self
        self.dateText.addTarget(self, action: #selector(self.dp(_:)), for: .editingDidBegin)
        pickerView = PickerTool.loadClass() as? PickerTool
        localityText.inputView = pickerView
        timeSlotText.inputView = pickerView
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.addTarget(self, action: #selector(self.nextAction), for: .touchUpInside)
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.getTimeSlot()
    }
    
    func getLocality() {
        
        if pincodeText.text!.count < 6 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert valid pincode.")
            return
        }
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.validatePincode + pincodeText.text!, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.localityArr = []
            self.LocalityStr = []
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    
                    self.cityText.text = data["City"].stringValue
                    self.stateText.text = data["State"].stringValue
                    
                    if data["IsServiceAvailable"].stringValue == "TRUE" || data["IsServiceAvailable"].stringValue == "true" {
                     
                        self.localityArr.append(Locality.init(
                            isServiceAvailable: data["IsServiceAvailable"].stringValue,
                            pincode: data["Pincode"].stringValue,
                            city: data["City"].stringValue,
                            state: data["State"].stringValue,
                            Locality: data["Locality"].stringValue,
                            pincodeId: data["PincodeID"].stringValue
                            
                        ))
                        
                        self.LocalityStr.append(data["Locality"].stringValue)
                        
                    }
                }
                
                if self.LocalityStr.count == 0 {
                    Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "This service is not available on this pincode.")
                    self.view.endEditing(true)
                }
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.view.endEditing(true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    @IBAction func dp(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date().addingTimeInterval(2678400)
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateText.text = dateFormatter.string(from: sender.date)
    }
    
    func getTimeSlot() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getTimeSlot, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.timeSlot = []
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.timeSlot.append(data["TimeSlot"].stringValue)
                    self.timeSlotId.append(data["TimeSlotID"].stringValue)
                }
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            
        }
    }
    
    
    @objc func nextAction() {
        if pincodeText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter pincode.")
            return
        }
        
        if localityText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select locality.")
            return
        }
        
        if dateText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select date.")
            return
        }
        
        if timeSlotText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select time slot.")
            return
        }
        
        let localityIndex:Int = LocalityStr.index(of:localityText.text!)!
        let timeSlotIndex:Int = timeSlot.index(of: timeSlotText.text!)!
        
        let parameter:[String:String] = [
            "pincode": pincodeText.text!,
            "locality": localityText.text!,
            "city":cityText.text!,
            "state" : stateText.text!,
            "date": dateText.text!,
            "timeslot": timeSlotText.text!,
            "localityId": localityArr[localityIndex].pincodeId,
            "timeSlotId": timeSlotId[timeSlotIndex]
        ]
        
        let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddDetailViewController") as! AddDetailViewController
        nextView.timeSlotData = parameter
        nextView.titleStr = titleStr
        
        self.navigationController?.pushViewController(nextView, animated: true)
        
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
extension BookLabTestViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == pincodeText {
            self.getLocality()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == localityText  {
            if LocalityStr.count == 0 {
                return false
            }else{
                if localityText.text == "" {
                    localityText.text = LocalityStr[0]
                }
                self.setPickerInfo(localityText, withArray: LocalityStr)
                return true
            }
        }else if textField == timeSlotText {
            if timeSlot.count == 0 {
                return false
            }else{
                if timeSlotText.text == "" {
                    timeSlotText.text = timeSlot[0]
                }
                self.setPickerInfo(timeSlotText, withArray: timeSlot)
                return true
            }
        }
        
        return true
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any]) {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
}
