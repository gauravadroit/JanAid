//
//  PayDetailViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 02/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class PayDetailViewController: UIViewController {

    @IBOutlet weak var discountAmtLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var offerAmtLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var payNowBtn: UIButton!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    
    
    var fees:String!
    var discount:String!
    var discountAmount:String!
    var discountedFees:String!
    var imageUrl:String!
    var name:String!
    var speciality:String!
    var doctorId:String!
    var doctorDescription: String = ""
    
    var gender:String!
    var rating:String!
    var qualification:String!
    var experience:String!
    
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var doctorNameLabel: UILabel!
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.payNowBtn.layer.cornerRadius = 5
        self.descriptionLabel.text = self.doctorDescription
        self.title = "Detail"
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.getDoctorDetails()
    }
    
    func setData() {
        
        doctorNameLabel.text = name
        let attributeString =  NSMutableAttributedString(string: "₹\(fees!)")
        
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                     value: NSUnderlineStyle.styleSingle.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        self.feesLabel.attributedText = attributeString
        self.offerAmtLabel.text = "₹\(discountedFees!)"
        self.discountLabel.text = " \(discount!)%"
        self.doctorNameLabel.text = name
        
        self.qualificationLabel.text = qualification
        self.specialityLabel.text = speciality
        self.ratingLabel.text = " " +  rating + " ★ "
        self.experienceLabel.text = experience
        
        self.descriptionLabel.text = self.doctorDescription
        self.discountAmtLabel.text = "₹\(discountAmount!)"
        
        if gender == "Male" {
            self.genderImageView.image = #imageLiteral(resourceName: "man")
        }else{
            self.genderImageView.image = #imageLiteral(resourceName: "girl")
        }
        
        
        doctorImageView.sd_setImage(with: URL(string: Webservice.baseUrl + self.imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
    }
    
    
    func getDoctorDetails() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getDoctorFees + doctorId , headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Data"][0]["Message"].stringValue == "Success" {
               
                self.fees = json["Data"][0]["Fee"].stringValue
                self.discount = json["Data"][0]["DiscountPercentage"].stringValue
                self.discountedFees = json["Data"][0]["OfferAmount"].stringValue
                self.imageUrl = json["Data"][0]["DocImage"].stringValue
                self.name = json["Data"][0]["DoctorName"].stringValue
                self.doctorDescription = json["Data"][0]["Description"].stringValue
                self.qualification =  json["Data"][0]["Qualification"].stringValue
                self.rating =  json["Data"][0]["Ratings"].stringValue
                self.experience =  json["Data"][0]["Experience"].stringValue
                self.speciality =  json["Data"][0]["SpecialityName"].stringValue
                self.gender = json["Data"][0]["GenderName"].stringValue
                self.setData()
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }

    
    func getOrderId() {
        let parameter:[String:String] = [
            "OrderType":"GP",
            "PatientID":User.patientId,
            "DoctorID": doctorId,
            "DoctorFee":fees,
            "OtherCharges":"0",
            "TotalAmount":fees,
            "DiscountPercentage":discount,
            "DiscountAmount":discountAmount,
            "NetAmount":discountedFees
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getOrderIDForPay, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Data"][0]["Message"].stringValue == "Success" {
                let orderNumber = json["Data"][0]["OrderNumber"].stringValue
                let orderAmt = json["Data"][0]["OrderAmount"].stringValue
                let stroryboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = stroryboard.instantiateViewController(withIdentifier: "PayDoctorFeesViewController") as! PayDoctorFeesViewController
                nextView.orderNumber = orderNumber
                nextView.price = orderAmt
                nextView.orderId = json["Data"][0]["OrderID"].stringValue
                nextView.doctorName = self.name
                nextView.mobile = json["Data"][0]["MobileNumber"].stringValue
                nextView.name = json["Data"][0]["PatientName"].stringValue
                nextView.email = json["Data"][0]["Email"].stringValue
                self.navigationController?.pushViewController(nextView, animated: true)
            }
            
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    @IBAction func payNowAction(_ sender: UIButton) {
        self.getOrderId()
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
