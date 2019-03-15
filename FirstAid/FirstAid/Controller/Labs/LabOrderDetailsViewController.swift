//
//  LabOrderDetailsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ActionSheetPicker_3_0
import Toast_Swift

class LabOrderDetailsViewController: UIViewController, SelectAddressDelegate {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pincodeLabel: UILabel!
    @IBOutlet weak var localitylabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var mobileText: UITextField!
   
  //  @IBOutlet weak var precautionLabel: UILabel!
    @IBOutlet weak var dateTimeText: UITextField!
    @IBOutlet weak var ageText: UITextField!
    @IBOutlet weak var genderText: UITextField!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var precautionLabel: UILabel!
    
    var selectedSlot:String!
    var tmpTextField:UITextField!
    
    struct address {
        var name:String!
        var state:String!
        var city:String!
        var street:String!
        var contact:String!
        var pincode:String!
        var id:String!
        var country:String!
        var locality:String!
    }
    
    struct locality {
        var name:String!
        var pincode:String!
    }
    
    var localityArr:[locality] = []
    
 var addressArr:[address] = []
    var selectedIndex:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mobileText.text = User.mobileNumber
        nameText.text = User.firstName + " " +  User.lastName
       
        ageText.delegate = self
        genderText.delegate = self
        nameText.delegate = self
        dateTimeText.delegate = self
        
        nameText.text = LabAddress.nameText
        ageText.text = LabAddress.ageText
        genderText.text = LabAddress.genderText
        
        self.nameText.text = LabAddress.nameText
        self.streetLabel.text = LabAddress.nameText
        self.localitylabel.text = LabAddress.localityText
        self.cityLabel.text =  LabAddress.cityText
        self.pincodeLabel.text = LabAddress.cityText + "," + LabAddress.stateText + " - " + LabAddress.pincodeText
 
        self.precautionLabel.text = Lab.precautions
       // self.getPatientAddressFrom1MG()
    }
    
    func selectedIndex(index: Int) {
        self.selectedIndex = index
        self.getPatientAddressFrom1MG()
    }

    @IBAction func changeAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        nextView.fromMedicine = "yes"
        nextView.delegate = self
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func selectDateAndTime(sender:UITextField) {
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
      
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getTimeslot + User.location! + "&product_category=" + Lab.labType, headers: headers, { (json) in
            print(json)
            
     
            let timeArr:[String] =  json["time_slots"].arrayValue.map { $0.stringValue}
            let dateArray:[String] = json["date_slots"].arrayValue.map { $0.stringValue}
        
            
        ActionSheetMultipleStringPicker.show(withTitle: "Select Date and Time", rows: [
            dateArray,timeArr], initialSelection: [0, 0], doneBlock: {
                picker, indexes, values in
                
                print("values = \(values)")
                print("indexes = \(indexes)")
                print("picker = \(picker)")
                print(indexes as! [Int])
                let index = indexes as! [Int]
               
                print(json["date_time_slots"][dateArray[index[0]]][index[1]]["available"].stringValue)
                
                if json["date_time_slots"][dateArray[index[0]]][index[1]]["available"].stringValue == "true" {
                    let str = dateArray[index[0]] + " " + timeArr[index[1]]
                    self.dateTimeText.text = str
                    self.selectedSlot = json["date_time_slots"][dateArray[index[0]]][index[1]]["epoch_slot"].stringValue
                }
                print(self.selectedSlot)
                
                return
        }, cancel: { ActionMultipleStringCancelBlock in return }, origin: sender)
            
        }) { (error) in
           // ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            print(error)
        }
        
    }
    
    
    func getPatientAddressFrom1MG() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getAddressFrom1MG, headers: headers, { (json) in
            print(json)
            self.addressArr = []
            for data in json["result"].arrayValue {
                self.addressArr.append(address.init(
                    name: data["name"].stringValue,
                    state: data["state"].stringValue,
                    city: data["city"].stringValue,
                    street: data["street1"].stringValue,
                    contact: data["contact_number"].stringValue,
                    pincode: data["pincode"].stringValue,
                    id: data["id"].stringValue,
                    country: data["country"].stringValue,
                    locality: data["locality"].stringValue
                ))
            }
            
            self.nameText.text = self.addressArr[self.selectedIndex].name
            self.streetLabel.text = self.addressArr[self.selectedIndex].name
            self.localitylabel.text = self.addressArr[self.selectedIndex].street
            self.cityLabel.text = self.addressArr[self.selectedIndex].locality
            self.pincodeLabel.text = self.addressArr[self.selectedIndex].city + "," + self.addressArr[self.selectedIndex].state + " - " + self.addressArr[self.selectedIndex].pincode
            
            self.getLocality(state: self.addressArr[self.selectedIndex].state, city: self.addressArr[self.selectedIndex].city, pincode: self.addressArr[self.selectedIndex].pincode)
            
            ShowLoader.stopLoader()
           
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
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
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getLocality, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            if json["Message"].stringValue == "Success" {
                self.localityArr = []
                for data in json["Data"].arrayValue {
                    self.localityArr.append(locality.init(
                        name: data["LocalityName"].stringValue,
                        pincode: data["PinCode"].stringValue
                    ))
                }
            }
            
            ShowLoader.stopLoader()
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    @IBAction func continueAction(_ sender: UIButton) {
        self.bookTest()
    }
    func bookTest() {
        
        if self.selectedSlot == nil {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select date and time.")
            return
        }
        if self.nameText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill name.")
            return
        }
        
        if self.ageText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill age.")
            return
        }
        
        if self.genderText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select gender.")
            return
        }
        
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken,
            "THIRD-PARTY":"panasonic"
        ]
        
        self.nameText.text = LabAddress.nameText
        self.streetLabel.text = LabAddress.nameText
        self.localitylabel.text = LabAddress.localityText
        
     
        
        
       let parameter:[String:Any] =
                [
                    "cart":Lab.skusArr,
                    "city":LabAddress.cityText!,
                    "state":LabAddress.stateText!,
                    "street":LabAddress.flatText!,
                    "locality_id":"",
                    "locality":LabAddress.localityText!,
                    "landmark":"",
                    "email":User.emailId!,
                    "patient_name":LabAddress.nameText!,
                    "gender":LabAddress.genderText!,
                    "age":LabAddress.ageText!,
                    "mobile_number":LabAddress.contactText!,
                    "collection_time":selectedSlot!,
                    "pin_code":LabAddress.pincodeText!,
                    "payment_mode":"CASH",
                    "referral": "PANASONIC",
                    "coupon_code":"",
                    "merchant_id":"bb4ff3af-dc64-4b7e-be29-4f038e3781d9",
                    "policy_id":"",
                    "referrence_id":"",
                    "merchant_paid":0,
                    "user_paid":Int(LabAddress.price!)!
        ]
        
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPostWithHeader(path: Webservice.bookLab, dataDict: parameter, headers: headers, { (json) in
            print(json)
            
             ShowLoader.stopLoader()
            
            if json[0]["_status"].stringValue == "booked" {
                
                
                for data in json.arrayValue {
                
                let parameter:[String:String] = [
                    "PatientID":User.patientId,
                    "BookingID": data["_booking_id"].stringValue,
                    "OrderGroupID": data["_order_group_id"].stringValue,
                    "EntryTime": data["_entry_time"].stringValue,
                    "Date": data["_collection_time_slot"]["date"].stringValue,
                    "Slot": data["_collection_time_slot"]["slot"].stringValue,
                    "Price": data["_price"].stringValue,
                    "PayablePrice": data["_payable_price"].stringValue,
                    "PatientName": data["_patient_name"].stringValue,
                    "Age": data["_age"].stringValue,
                    "MobileNumber": data["_mobile_number"].stringValue,
                    "LabID":  data["_lab_id"].stringValue,
                    "TestID": data["_test_id"].stringValue,
                    "LabName": data["_lab_name"].stringValue,
                    "TestName": data["_test_name"].stringValue,
                    "OrderStatus_1mg": data["_status"].stringValue,
                ]
                
                    print(parameter)
                    self.saveStatusOf1MG(param: parameter)
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "OrderPlacedViewController") as! OrderPlacedViewController
                nextView.orderId = json[0]["_booking_id"].stringValue
                nextView.fromLab = "true"
                self.navigationController?.pushViewController(nextView, animated: true)
            }else{
                if json["error"]["user_message"].stringValue != "" {
                    self.view.makeToast(json["error"]["user_message"].stringValue, duration: 3.0, position: .bottom)
                }
            }
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    func saveStatusOf1MG(param:[String:String]) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGLabOrder, dataDict: param, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
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

extension LabOrderDetailsViewController:UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == genderText {
            self.dropDown(textField, selector: ["Male","Female","other"])
            return false
        }else if textField == dateTimeText {
            self.self.selectDateAndTime(sender: textField)
            return false
        }else{
            return true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LabOrderDetailsViewController : UIPopoverPresentationControllerDelegate,PopViewControllerDelegate {
    
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



