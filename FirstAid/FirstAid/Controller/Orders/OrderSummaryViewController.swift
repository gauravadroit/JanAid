//
//  OrderSummaryViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class OrderSummaryViewController: UIViewController {

    @IBOutlet weak var summaryView: UIView!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var Name:String!
    var street:String!
    var city:String!
    var state:String!
    var country:String!
    var mobile:String!
    var addressId:String!
    var pincode:String!
    @IBOutlet weak var prescriptionImageView: UIImageView!
    @IBOutlet weak var confirmOrderBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        summaryView.dropShawdow()
        summaryView.layer.cornerRadius = 5
        summaryView.layer.borderWidth = 1
        summaryView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        confirmOrderBtn.layer.cornerRadius = 5
        
        self.title = "Order Summary"
        nameLabel.text = Name
        streetLabel.text = street
        cityLabel.text = city
        stateLabel.text = city + "," + state + "-" + pincode
        mobileLabel.text = "Mobile: " + mobile
        prescriptionImageView.sd_setImage(with: URL(string: Prescription.prescriptionUrl), placeholderImage: UIImage(named: "Medicine"))
        confirmOrderBtn.addTarget(self, action: #selector(self.confirmOrderAction(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    @objc func confirmOrderAction(sender:UIButton) {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        
        var parameter:[String:Any] = [:]
        var comment:String = ""
        
        if Prescription.labTest == 1 {
            comment = Prescription.comment! + " also include lab test"
        }else{
            comment = Prescription.comment!
        }
        
        if Prescription.durationInDays! == "1" {
        
            parameter = [
                "addressId": Int(Prescription.addressId)!,
                "prescriptionIds": Int(Prescription.prescriptionId)!,
                "apply1mgCash" : "false",
                "comment": comment,
                "order_choice":Prescription.orderChoice!,
                "duration_in_days":Prescription.durationInDays!
            ]
        }else{
                parameter = [
                    "addressId": Int(Prescription.addressId)!,
                    "prescriptionIds": Int(Prescription.prescriptionId)!,
                    "apply1mgCash" : "false",
                    "comment": comment,
                    "order_choice":Prescription.orderChoice!
            ]
        }
        
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.placeOrderTo1MG, dataDict: parameter, headers: headers, { (json) in
            print(json)
             ShowLoader.stopLoader()
            if json["result"].stringValue != "" {
                let date = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM dd, yyyy"
                print(formatter.string(from: date))
                
                MedicineData.OrderStatus_1mg = "placed"
                MedicineData.OrderID = json["result"].stringValue
                MedicineData.OrderDate = formatter.string(from: date)
                MedicineData.ShippingAmount = "0"
                MedicineData.ActualAmount = "0"
                MedicineData.DiscountAmount = "0"
                MedicineData.TotalAmount = "0"
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "OrderPlacedViewController") as! OrderPlacedViewController
                nextView.orderId = json["result"].stringValue
                nextView.fromMedicine = "true"
                self.navigationController?.pushViewController(nextView, animated: true)
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
