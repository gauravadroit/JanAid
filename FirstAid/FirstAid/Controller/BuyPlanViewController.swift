//
//  BuyPlanViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Razorpay
import NVActivityIndicatorView

class BuyPlanViewController: UIViewController,RazorpayPaymentCompletionProtocol {

    @IBOutlet weak var payNowBtn: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var validityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var price:String!
    var name:String!
    var validity:String!
    var planId:String!
    
    var orderId:String!
    var orderNumber:String!
    private var razorpay:Razorpay!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        priceLabel.text = "₹" + price
        nameLabel.text = name
        validityLabel.text = validity + " Days"
        payNowBtn.layer.cornerRadius = 5
        payNowBtn.addTarget(self, action: #selector(self.showPaymentForm), for: .touchUpInside)
        
        self.title = "Buy Plan"
        razorpay = Razorpay.initWithKey("rzp_test_PJ4YxZi3tiXURY", andDelegate: self)
        self.getOrderId()
    }

   
    @objc func showPaymentForm() {
        let options:[String:Any] = [
            "amount" : Float(self.price),
            "description" : orderNumber
        ]
        razorpay.open(options)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        self.saveStatusToServer(paymentStatus: "false", orderStatus: "failure", Id: "")
        UIAlertView.init(title: "Error", message: str, delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        self.saveStatusToServer(paymentStatus: "true", orderStatus: "success", Id: payment_id)
        UIAlertView.init(title: "Payment Successful", message: payment_id, delegate: self, cancelButtonTitle: "OK").show()
    }
    
    func saveStatusToServer(paymentStatus:String,orderStatus:String,Id:String) {
        let parameter:[String:Any] = [
            "TempOrderID":self.orderId!,
            "PatientName":User.firstName!,
            "PatientID":User.patientId!,
            "PlanID":self.planId!,
            "PaymentStatus":paymentStatus,
            "PaymentID":Id,
            "MobileNumber":User.mobileNumber!,
            "EmailId":"deee@Dee.com",
            "RazorPayOrderId":"",
            "OrderStatus":orderStatus,
            "Description":"Order  purchased successfully"
        ]
        
        print(parameter)
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.sendStatus, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
   
    
    func getOrderId() {
       // getOrderIdForRazorPay
        let parameter:[String:String] = [
            "PatientID": User.patientId,
            "PlanID": self.planId
            //"RazorPayOrderId": "",
            //"FlagNo":"1"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getOrderIdForRazorPay, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
                self.orderId = json["Data"][0]["OrderID"].stringValue
                self.orderNumber = json["Data"][0]["OrderNumber"].stringValue
            }
            
        }) { (error) in
            print(error)
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
