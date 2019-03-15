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

class PayDoctorFeesViewController: UIViewController, RazorpayPaymentCompletionProtocol {

    @IBOutlet weak var consultationBtn: UIButton!
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
        
        let Attributes1 : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name       : "Helvetica Bold", size: 20),
            NSAttributedStringKey.foregroundColor : Webservice.themeColor,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString1 = NSMutableAttributedString(string: "Try Again", attributes: Attributes1)
        trybtn.setAttributedTitle(attributeString1, for: .normal)
        
        let Attributes2 : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont(name       : "Helvetica Bold", size: 20),
            NSAttributedStringKey.foregroundColor : Webservice.themeColor,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString2 = NSMutableAttributedString(string: "Go to consultation", attributes: Attributes2)
        consultationBtn.setAttributedTitle(attributeString2, for: .normal)
        
        priceFloat = Float(Int(price)! * 100)
        razorpay = Razorpay.initWithKey(Webservice.razorPay, andDelegate: self)
       
        
        homeBtn.isHidden = true
        trybtn.isHidden = true
        consultationBtn.isHidden = true
        
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
        homeBtn.isHidden = false
        trybtn.isHidden = false
        consultationBtn.isHidden = true
        self.resultImageView.isHidden = true
        self.resultImageView.image = UIImage(named: "failed")
        self.paymentIdLabel.text = ""
        self.messageLabel.text = "Payment Un-Successful, try again."
        self.updateStatus(status: "false", paymentId: "0")
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        homeBtn.isHidden = false
        trybtn.isHidden = true
        consultationBtn.isHidden = false
        self.resultImageView.isHidden = false
        self.resultImageView.image = UIImage(named: "success")
        self.paymentIdLabel.text = "Transaction ID:" + payment_id
        self.messageLabel.text = "Payment Successful, we will arrange a call with doctor within 30 mins."
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
            "EmailID":self.email,
            "IsFreeConsultationApplicable" : "false",
            "UsedPromoID": "0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.updatePaymentStatus, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if status == "false" {
                
                UIApplication.shared.keyWindow?.makeToast("Payment Unsuccessful, try again.", duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
        }
        
    }
    
    @IBAction func consultationAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
        let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        dashboard.selectedIndex = 2
        let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        mfSideMenuContainer.leftMenuViewController = leftSideMenuController
        mfSideMenuContainer.centerViewController = dashboard
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mfSideMenuContainer
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
