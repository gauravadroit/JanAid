//
//  AddSlotViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 14/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class AddSlotViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var pincodeLabel: UILabel!
    @IBOutlet weak var alternateMobileLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var datelabel: UILabel!
    
    @IBOutlet weak var confirmBtn: UIButton!
    var testData:[String:String]!
    
    @IBOutlet weak var backView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Order Summary"
        var gender:String = ""
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if testData["GenderID"]! == "1" {
            gender = "Male"
        }else if testData["GenderID"]! == "2" {
            gender = "Female"
        }else if testData["GenderID"]! == "3" {
            gender = "Other"
        }

        nameLabel.text = testData["FirstName"]! + " " +  testData["LastName"]!
        ageLabel.text = testData["Age"]
        genderLabel.text = gender
        mobileLabel.text = testData["ContactNumber"]
        alternateMobileLabel.text = testData["AlternameNumber"]!
        datelabel.text = testData["SampleCollectionDate"]!
        pincodeLabel.text = testData["SampleCollectionSlot"]!
        addressLabel.text = testData["Address"]! + " " +  testData["City"]! + " " +  testData["State"]! + " Pincode:-" +  testData["Zipcode"]!
        
        confirmBtn.layer.cornerRadius = confirmBtn.frame.size.height/2
        confirmBtn.addTarget(self, action: #selector(self.confirmTest), for: .touchUpInside)
        
        backView.dropShawdow()
        
    }
    
    @objc func confirmTest(){
        self.validateHealthCoupon(parameter: testData)
    }
    
    func validateHealthCoupon(parameter:[String:String]) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.validateHealthCoupon, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.BookLabTestOnNiramaya(mrn: json["Data"][0]["mrn"].stringValue, orderRef: json["Data"][0]["order_reference"].stringValue)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popToRootViewController(animated: true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    /*let parameter:[String:String] = [
     "PatientID": User.patientId,
     "PromoUsedID": User.UsedPromoID,
     "IsSelf": "True",
     "FirstName": nameText.text!,
     "LastName": lastNameText.text!,
     "GenderID": "1",
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
     ]*/
    
    func BookLabTestOnNiramaya(mrn:String,orderRef:String) {
        
        var gender:String = ""
        
        if testData["GenderID"]! == "1" {
            gender = "Male"
        }else if testData["GenderID"]! == "2" {
            gender = "Female"
        }else if testData["GenderID"]! == "3" {
            gender = "Other"
        }
        
        let parameter:[String:Any] = [
            "authorization": "eCgAOnk4Ik1USJHrBRl0",
            "first_name": testData["FirstName"]!,
            "last_name": testData["LastName"]!,
            "gender": gender,
            "age": testData["Age"]!,
            "contact_number": testData["ContactNumber"]!,
            "address": testData["Address"]!,
            "locality": testData["Locality"]!,
            "city":testData["City"]!,
            "state":testData["State"]!,
            "zip_code": testData["Zipcode"]!,
            "landmark": testData["AlternameNumber"]!,
            "sample_date": self.convertDateFormater(testData["SampleCollectionDate"]!), //yyyy-mm-dd
            "sample_time":testData["SampleCollectionSlotID"]!,
            "order_reference": orderRef,
            "mrn": mrn,
            "email": testData["eMailID"]!,
            "discount_amt": "0",
            "remarks": "booking via JanAid API",
            "market_value":"",
            "net_amount":"",
            "test_code": ["JANA01"]
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        ShowLoader.startLoader(view: self.view)
        
        let header:[String:String] = ["Content-Type":"application/json","cache-control": "no-cache"]
        DataProvider.sharedInstance.sendDataUsingHeaderAndPostWithHeader(path: "https://www.niramayahealthcare.com/api/addorder", dataDict: parameter, headers: header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["message"].stringValue == "OK" {
                self.confirmBooking(mrn: mrn, orderId: json["result"].stringValue)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    func convertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return  dateFormatter.string(from: date!)
        
    }
    
    
    func confirmBooking(mrn:String,orderId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.confirmNiramayaBooking + "\(User.patientId!)&mrn=\(mrn)&OrderID=\(orderId)", dataDict: [:], headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
