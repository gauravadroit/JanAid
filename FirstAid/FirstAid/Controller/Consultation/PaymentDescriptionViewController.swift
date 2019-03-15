//
//  PaymentDescriptionViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage
import Toast_Swift

class PaymentDescriptionViewController: UIViewController {
    
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var healthConcernLabel: UILabel!
    @IBOutlet weak var specialityNameLabel: UILabel!
    @IBOutlet weak var specialityImage: UIImageView!
    var specialityId:String!
    var specialityName:String!
    var patientName:String!
    @IBOutlet weak var payBtn: UIButton!
    
    
    var patientDescription:String!
    var consultFee:String!
    var discountPercentage:String!
    var discountAmt:String!
    var offerAmt:String!
    var specialityDescription:String!
    var imageUrl:String!
    var patientId:String!
    
    @IBOutlet weak var specialityDescriptionLabel: UILabel!
    @IBOutlet weak var offerFeeLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var consultationFeeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Payment Details"
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if self.specialityDescription == "JanAid Fee Consultation" {
            payBtn.setTitle("Book Now", for: .normal)
        }else{
            payBtn.setTitle("Proceed To Pay", for: .normal)
        }
        
        specialityNameLabel.text = self.specialityName
        payBtn.layer.cornerRadius = 5
        payBtn.addTarget(self, action: #selector(self.getOrderId), for: UIControlEvents.touchUpInside)
        
        self.mobileLabel.text = User.mobileNumber
        self.nameLabel.text = patientName
        self.emailLabel.text = User.valiedEmail
        self.offerFeeLabel.text = "₹" + offerAmt
        self.discountLabel.text = "- ₹" + discountAmt
        self.consultationFeeLabel.text = "₹" + consultFee
        self.specialityDescriptionLabel.text = self.specialityDescription
        healthConcernLabel.text = ""
         specialityImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
    }
    
    
    @IBAction func ViewAction(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "View" {
            healthConcernLabel.text = self.patientDescription
            sender.setTitle("Hide", for: .normal)
        }else{
             healthConcernLabel.text = ""
            sender.setTitle("View", for: .normal)
        }
    }
    
    @objc func getOrderId() {
        let parameter:[String:String] = [
            "OrderType":"SP",
            "PatientID":self.patientId,
            "SpecialityGroupID": self.specialityId,
            "DoctorFee": self.consultFee,
            "OtherCharges":"0",
            "TotalAmount":self.consultFee,
            "DiscountPercentage":self.discountPercentage,
            "DiscountAmount":self.discountAmt,
            "NetAmount":self.offerAmt,
            "ConsultingReason":self.patientDescription,
            "BookedBy": User.patientId,
            "IsFreeConsultationApplicable": User.isFreeConsultationApplicable,
            "UsedPromoID": User.UsedPromoID
        ]
        
      
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getSpecialtyOrderId, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Data"][0]["Message"].stringValue == "Success" {
                let orderNumber = json["Data"][0]["OrderNumber"].stringValue
                let orderAmt = json["Data"][0]["OrderAmount"].stringValue
                let stroryboard = UIStoryboard(name: "Main", bundle: nil)
                
                if json["Data"][0]["IsPaymentRequired"].stringValue == "False" {
                    let orderId = json["Data"][0]["OrderID"].stringValue
                    let name = json["Data"][0]["PatientName"].stringValue
                    let mobile = json["Data"][0]["MobileNumber"].stringValue
                    let email = json["Data"][0]["Email"].stringValue
                    self.updateStatus(orderId: orderId, name: name, mobile: mobile, email: email, status: "false", paymentId: "0000")
                }else{
                    let nextView = stroryboard.instantiateViewController(withIdentifier: "PayDoctorFeesViewController") as! PayDoctorFeesViewController
                    nextView.orderNumber = orderNumber
                    nextView.price = orderAmt
                    nextView.orderId = json["Data"][0]["OrderID"].stringValue
                    nextView.doctorName = "Dr. Gaurav"
                    nextView.mobile = json["Data"][0]["MobileNumber"].stringValue
                    nextView.name = json["Data"][0]["PatientName"].stringValue
                    nextView.email = json["Data"][0]["Email"].stringValue
                    self.navigationController?.pushViewController(nextView, animated: true)
                }
                
            }
            
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
        
    }
    
    
    func updateStatus(orderId:String,name:String,mobile:String,email:String,status:String,paymentId:String) {
        let parameter:[String:String] = [
            "CallOrderID": orderId,
            "PaymentID": paymentId,
            "IsPayment": status,
            "PaymentGetewayMessage":"",
            "PatientName": name ,
            "MobileNumber": mobile,
            "EmailID": email,
            "UsedPromoID" :User.UsedPromoID,
            "IsFreeConsultationApplicable" : User.isFreeConsultationApplicable
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
            
            if json["Status"].stringValue == "false" {
                UIApplication.shared.keyWindow?.makeToast("Payment Unsuccessful, try again.", duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                
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
