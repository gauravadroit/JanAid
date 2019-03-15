//
//  AvailableDoctorViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

class AvailableDoctorViewController: UIViewController {
    
    var specialityId:String!
    var specialityName:String!
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let itemsPerRow:CGFloat = 3
    var selectedPatient:Int = 0
   // var specialityDescription:String!
   
    
    /*struct doctor {
        var discountPercentage:String!
        var gender:String!
        var specialityName:String!
        var doctorName:String!
        var rating:String!
        var doctorId:String!
        var fees:String!
        var offerAmount:String!
        var discountAmt:String!
        var qualification:String!
        var imageUrl:String!
        var experience:String!
        var newImageUrl:String!
    }*/
    
    var doctorArr:[doctor] = []

    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var offerFeesLabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var msgTextView: UITextView!
    @IBOutlet weak var proceedBtn: UIButton!
    
    var pickerView:PickerTool!
    
    struct member {
        var firstName:String = ""
        var lastName:String = ""
        var gender:String = ""
        var mobile:String = ""
        var patientId:String = ""
        var patientCode:String = ""
        var relation:String = ""
        var imageUrl:String!
    }
    
    @IBOutlet weak var relationCollectionView: UICollectionView!
    @IBOutlet weak var addMemberBtn: UIButton!
    var memberArr:[member] = []
    var memberStrArr:[String] = []
    
    var discountPercentage:String!
    var offerAmt:String!
    var discountAmt:String!
    var consultationFee:String!
    var userMsg:String!
    var specialityDescription:String!
    var imageUrl:String!
    var isDiscount:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = specialityName
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.tabBarController?.tabBar.isHidden = true
        
       // if doctorArr.count == 0 {
            self.getDoctorList(specialityId: self.specialityId)
        /*}else{
            self.feesLabel.isHidden = true
            self.offerFeesLabel.text = "Free Consultation"
        }*/
        
        addMemberBtn.layer.cornerRadius = addMemberBtn.frame.size.height/2
        
        msgView.layer.cornerRadius = 5
        msgView.layer.borderWidth = 1
        msgView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        
        infoView.layer.cornerRadius = 5
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = Webservice.themeColor.cgColor
        
        msgTextView.layer.cornerRadius = 5
        msgTextView.layer.borderWidth = 1
        msgTextView.layer.borderColor = Webservice.themeColor.cgColor
        
        proceedBtn.layer.cornerRadius = 5
        
        msgTextView.textColor = UIColor.gray
        msgTextView.text = "Enter your health concern"
        msgTextView.delegate = self
        
        msgLabel.text = "Hello \(User.firstName.capitalizingFirstLetter()), one of the following doctors will take up your consultation."
        
        self.relationCollectionView.delegate = self
        self.relationCollectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMember()
    }
   
    func getMember() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.getMember + User.patientId, { (json) in
            print(json)
            
            ShowLoader.stopLoader()
            self.memberArr = []
            self.memberStrArr = []
            
            if json["Status"].stringValue == "true" {
                
                self.memberStrArr.append("Myself")
                
                self.memberArr.append(member.init(
                    firstName: "Myself",
                    lastName: User.lastName,
                    gender: User.genderId,
                    mobile: User.mobileNumber,
                    patientId: User.patientId,
                    patientCode: User.patientId,
                    relation: " ",
                    imageUrl: " "
                ))
                
                for data in json["Data"].arrayValue {
                    self.memberArr.append(member.init(
                        firstName: data["FirstName"].stringValue,
                        lastName: data["LastName"].stringValue,
                        gender: data["GenderName"].stringValue,
                        mobile: data["MobileNumber"].stringValue,
                        patientId: data["PatientID"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        relation: data["RelationName"].stringValue,
                        imageUrl: data["Image"].stringValue
                    ))
                    
                    self.memberStrArr.append( data["FirstName"].stringValue + " " + data["LastName"].stringValue)
                }
             
            }
            
            self.relationCollectionView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }

    @IBAction func addMemberAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddMemberViewController") as! AddMemberViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getDoctorList(specialityId:String)  {
        let parameter:[String:String] = [
            "PageSize":"100",
            "PageNumber":"1",
            "Value1":specialityId,
            "Value2":"0",
            "Value3":"0",
            "Value4": User.patientId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getDoctorListForCall, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.doctorArr = []
                for data in json["Data2"].arrayValue {
                    self.doctorArr.append(doctor.init(
                        discountPercentage: data["DiscountPercentage"].stringValue,
                        gender: data["Gender"].stringValue,
                        specialityName: data["SpecialityName"].stringValue,
                        doctorName: data["DoctorName"].stringValue,
                        rating: data["Rating"].stringValue,
                        doctorId: data["DoctorID"].stringValue,
                        fees: data["Fee"].stringValue,
                        offerAmount: data["OfferedAmount"].stringValue,
                        discountAmt: data["DiscountAmount"].stringValue,
                        qualification: data["Qualification"].stringValue,
                        imageUrl: data["DocImage"].stringValue,
                        experience: data["Experience"].stringValue,
                        newImageUrl: data["DoctorProfilePicture"].stringValue,
                        ratingText: data["RatingText"].stringValue
                    ))
                }
                
                
                self.consultationFee = json["Data"][0]["ConsultationFee"].stringValue
                self.discountAmt = json["Data"][0]["DiscountAmount"].stringValue
                self.offerAmt = json["Data"][0]["OfferAmount"].stringValue
                self.discountPercentage = json["Data"][0]["DiscountPercentage"].stringValue
                self.userMsg = json["Data"][0]["UserMessage"].stringValue
               // self.specialityDescription = json["Data"][0]["SpecialityDescription"].stringValue
                self.specialityDescription = json["Data"][0]["Description"].stringValue
                self.imageUrl = json["Data"][0]["IconURL"].stringValue
                self.isDiscount = json["Data"][0]["IsDiscount"].stringValue
                self.userMsg = self.userMsg.replacingOccurrences(of:"@UserName" , with: User.firstName.capitalizingFirstLetter())
                self.msgLabel.text = self.userMsg
                if self.isDiscount == "true" {
                    let attributeString =  NSMutableAttributedString(string: "   ₹\(self.consultationFee!) ")
                    attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                             value: NSUnderlineStyle.styleSingle.rawValue,
                                             range: NSMakeRange(0, attributeString.length))
                    self.feesLabel.attributedText = attributeString
                    self.offerFeesLabel.text = "₹" + self.offerAmt
                }else{
                    self.feesLabel.isHidden = true
                    self.offerFeesLabel.text = "₹" + self.consultationFee
                }
                
              
                
                
                self.collectionView.reloadData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            
            
            
        }
        
    }
   
    @IBAction func paymentAction(_ sender: UIButton) {
        
        
        if self.msgTextView.text! == "Enter your health concern"  || self.msgTextView.text! == ""  {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill health concern.")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "PaymentDescriptionViewController") as! PaymentDescriptionViewController
        nextview.specialityName = self.specialityName
        nextview.specialityId = self.specialityId
        nextview.consultFee = self.consultationFee
        nextview.discountPercentage = self.discountPercentage
        nextview.discountAmt = self.discountAmt
        nextview.offerAmt = self.offerAmt
        nextview.specialityDescription = self.specialityDescription
        nextview.patientDescription = self.msgTextView.text!
        nextview.imageUrl  = self.imageUrl
        if selectedPatient == 0 {
            nextview.patientName = User.firstName
        }else{
            nextview.patientName = self.memberArr[selectedPatient].firstName
        }
        
       // let index:Int = memberStrArr.index(of: relationText.text!)!
        nextview.patientId = memberArr[selectedPatient].patientId
        
        
        self.navigationController?.pushViewController(nextview, animated: true)
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

extension AvailableDoctorViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if relationCollectionView == collectionView {
              return memberArr.count
        }else{
              return doctorArr.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if relationCollectionView == collectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RelationCell", for: indexPath) as! RelationCell
           
            cell.relationImageView.sd_setImage(with: URL(string: Webservice.baseUrl +  self.memberArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
            cell.nameLabel.text = memberArr[indexPath.row].firstName
            cell.relationLabel.text = memberArr[indexPath.row].relation
            if indexPath.row == selectedPatient {
                cell.relationImageView.layer.borderColor =  Webservice.themeColor.cgColor
            }else{
                cell.relationImageView.layer.borderColor =  UIColor.lightGray.withAlphaComponent(0.5).cgColor
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailableDoctorCell", for: indexPath) as! AvailableDoctorCell
            cell.nameLabel.text = doctorArr[indexPath.row].doctorName
            cell.specialityLabel.text = doctorArr[indexPath.row].specialityName
            cell.degreeLabel.text = doctorArr[indexPath.row].qualification
            cell.experienceLabel.text = doctorArr[indexPath.row].experience
            if doctorArr[indexPath.row].rating != "0" {
                cell.starRatingLabel.text = " " + doctorArr[indexPath.row].rating + " ★ "
                cell.starRatingLabel.backgroundColor = UIColor(red: 19.0/255.0, green: 166.0/255.0, blue: 37.0/255.0, alpha: 1.0)
                cell.starRatingLabel.textColor = UIColor.white
                cell.starRatingLabel.font = UIFont(name: "Helvetica", size: 17.0)
                
            }else{
                cell.starRatingLabel.text = ""
                cell.starRatingLabel.backgroundColor = UIColor.clear
                cell.starRatingLabel.textColor = UIColor.black.withAlphaComponent(0.6)
                cell.starRatingLabel.font = UIFont(name: "Helvetica", size: 10.0)
            }
            
            cell.doctorImage.sd_setImage(with: URL(string: self.doctorArr[indexPath.row].newImageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
            return cell
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if relationCollectionView == collectionView {
            return CGSize(width: 74.0 , height: 105.0)
        }else{
            return CGSize(width: 180.0 , height: 210.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if relationCollectionView == collectionView {
            selectedPatient = indexPath.row
            self.relationCollectionView.reloadData()
        }else{
        
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextview = storyboard.instantiateViewController(withIdentifier: "DoctorProfile2ViewController") as! DoctorProfile2ViewController
            nextview.doctorId = doctorArr[indexPath.row].doctorId
            self.navigationController?.pushViewController(nextview, animated: true)
        }
    }
    
}

extension AvailableDoctorViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.gray
            textView.text = "Enter your health concern"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            return true
        }
        
        let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 .,':%&!()-+/"
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = text.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if textView.text.count < 500 {
                return text == numberFiltered
            }else{
                return false
            }
    }
}


extension AvailableDoctorViewController:UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}



