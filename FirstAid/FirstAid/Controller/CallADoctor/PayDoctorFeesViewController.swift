//
//  PayDoctorFeesViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 03/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Razorpay
import NVActivityIndicatorView

class PayDoctorFeesViewController: UIViewController , RazorpayPaymentCompletionProtocol {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var paymentIdLabel: UILabel!
    @IBOutlet weak var resultImageView: UIImageView!
    var name:String!
    var mobile:String!
    var email:String!
    var doctorName:String!
    var orderNumber:String!
    var orderId:String!
    var price:String!
    var priceFloat:Float!
    private var razorpay:Razorpay!
    @IBOutlet weak var homeBtn: UIButton!
    
    @IBOutlet weak var trybtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        messageLabel.text = ""
        paymentIdLabel.text = ""
        homeBtn.layer.cornerRadius = 5
        self.title = "Payment"
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name       : "Helvetica Bold", size: 20),
            NSAttributedStringKey.foregroundColor : UIColor(red: 0.0/255.0, green: 91.0/255.0, blue: 151.0/255.0, alpha: 1.0),
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Try Again", attributes: yourAttributes)
        trybtn.setAttributedTitle(attributeString, for: .normal)
        
        priceFloat = Float(Int(price)! * 100)
        razorpay = Razorpay.initWithKey("rzp_test_PJ4YxZi3tiXURY", andDelegate: self)
        
        homeBtn.isHidden = true
        trybtn.isHidden = true
        
        self.showPaymentForm()
    }

    @IBAction func homeAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func tryAgainAction(_ sender: UIButton) {
        self.showPaymentForm()
    }
    
    @objc func showPaymentForm() {
        let options:[String:Any] = [
            "amount" : priceFloat!,
            "description" : orderNumber!,
            "image": Webservice.baseUrl + "Images/Icon/Logo_100X100.png",
            "name": "JanAid",
            "prefill" : [
                "email": self.email!,
                "contact": self.mobile!
            ]
        ]
        print(options)
        razorpay.open(options)
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
       // self.saveStatusToServer(paymentStatus: "false", orderStatus: "failure", Id: "")
      //  UIAlertView.init(title: "Error", message: str, delegate: self, cancelButtonTitle: "OK").show()
        homeBtn.isHidden = false
        trybtn.isHidden = false
        self.resultImageView.image = UIImage(named: "failed")
        self.paymentIdLabel.text = ""
        self.messageLabel.text = "Payment Un-Successful, try again."
        self.updateStatus(status: "false", paymentId: "0")
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        //self.saveStatusToServer(paymentStatus: "true", orderStatus: "success", Id: payment_id)
       // UIAlertView.init(title: "Payment Successful", message: payment_id, delegate: self, cancelButtonTitle: "OK").show()
        homeBtn.isHidden = false
        trybtn.isHidden = true
        self.resultImageView.image = UIImage(named: "success")
        self.paymentIdLabel.text = "Payment ID:" + payment_id
        self.messageLabel.text = "Payment Successful, we will arrange a call with \(doctorName!) within 10 mins."
        self.updateStatus(status: "true", paymentId: payment_id)
    }
    
    func updateStatus(status:String,paymentId:String) {
        let parameter:[String:String] = [
            "CallOrderID":orderId,
            "PaymentID":paymentId,
            "IsPayment":status,
            "PaymentGetewayMessage":"",
            "PatientName":self.name ,
            "MobileNumber":self.mobile,
            "EmailID":self.email
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.updatePaymentStatus, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
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
