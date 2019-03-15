//
//  ConsultDataViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift
import Alamofire
import SwiftyJSON
import MobileCoreServices
 

class ConsultDataViewController: UIViewController,deleteAttachmentDelegate {
   
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var commentView: UITextView!
    @IBOutlet weak var HCRatingView: HCSStarRatingView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var ratingView: UIView!
    
    @IBOutlet weak var btmConstraintRatingView: NSLayoutConstraint!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var paymentView:PaymentReceipt!
    var paymentImage:UIImage!
    var patientDescription:String!
    var callID:String!
    var doctorId:String!
    var isFeedBack:String!
    
    var dataArr:[[String:String]] = []
    var history:[String] = []
    var investigation:[String] = []
    var symptom:[String] = []
    var medicineList:[MediDetail] = []
    var imagePicker = UIImagePickerController()
    var chosenImage:UIImage!
    var status:String!
    
    var attachmentHeading:String!
    var attachmentCount:String!
    var attachmentMsg:String!
    
    
   
    
    struct Attachment {
        var documentUrl:String!
        var format:String!
        var documentId:String!
        var message:String!
        var fileName:String!
        var uploadedAt:String!
    }
    
    var attachmentArr:[[String:String]] = []
    var prescriptionArr:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.tabBarController?.tabBar.isHidden = true
        self.callBtn.layer.cornerRadius = self.callBtn.frame.size.height/2
        
        self.callBtn.layer.shadowRadius = 10
        self.callBtn.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.callBtn.layer.shadowColor = UIColor.black.cgColor
        self.callBtn.clipsToBounds = false
        self.callBtn.layer.shadowOpacity = 0.3
        self.callBtn.isEnabled = true
        self.callBtn.setTitle(" Call your doctor", for: .normal)
        self.callBtn.backgroundColor = UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1.0)
        let icon = #imageLiteral(resourceName: "phonecall").withRenderingMode(.alwaysTemplate)
        self.callBtn.setImage(icon, for: .normal)
        self.callBtn.tintColor = UIColor.white
        self.callBtn.addTarget(self, action: #selector(self.callAdoctorAction(sender:)), for: .touchUpInside)
        self.imagePicker.allowsEditing = true
        
        self.blackView.isHidden = true
        self.commentView.text = "" 
        submitBtn.layer.cornerRadius = 5
        commentView.layer.cornerRadius = 5
        commentView.layer.borderWidth = 1
        btmConstraintRatingView.constant = -350
        self.ratingView.isHidden = true
        self.ratingView.layer.cornerRadius = 5
        submitBtn.addTarget(self, action: #selector(self.addfeedBack), for: .touchUpInside)
        self.getData()
    }
    
    @IBAction func showRatingView(_ sender: UIButton) {
        if sender.titleLabel?.text == "show" {
            self.blackView.isHidden = false
            self.AnimateBackgroundHeight(height: 20) { (status) in
                print(status)
            }
            sender.setTitle("hide", for: .normal)
        }else{
            self.blackView.isHidden = true
            self.AnimateBackgroundHeight(height: -350) { (status) in
                print(status)
            }
            sender.setTitle("show", for: .normal)
        }
    }
    
    func AnimateBackgroundHeight(height:CGFloat, _ successBlock:@escaping ( _ response: Bool )->Void) {
        UIView.animate(withDuration: 1.0, animations: {
            self.btmConstraintRatingView.constant = height
            self.view.layoutIfNeeded()
            successBlock(true)
            
        })
    }
        
    
    
    @objc func callAdoctorAction(sender:UIButton) {
        
        if sender.backgroundColor == UIColor(red: 172.0/255.0, green: 45.0/255.0, blue:
            53.0/255.0, alpha: 1.0) {
            if let url = URL(string: "tel://\(Webservice.callCenter)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else{
            self.view.makeToast("Please wait while we assign a doctor with your request.", duration: 3.0, position: .bottom)
        }
       
    }
    
    func getData()  {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getConsultationDetails + callID, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                
                self.attachmentCount = json["Data"][0]["AttachmentCount"].stringValue
                self.attachmentHeading = json["Data"][0]["AttachmentHeading"].stringValue
                self.attachmentMsg = json["Data2"]["Attachment"][0]["Message"].stringValue
                self.isFeedBack = json["Data"][0]["IsFeedback"].stringValue
                
                if json["Data"][0]["IsAttachment"].stringValue == "true" {
                    
                    self.attachmentArr = []
                    
                    for data in json["Data2"]["Attachment"].arrayValue {
                        self.attachmentArr.append(
                            ["documentUrl": data["DocumentURL"].stringValue,
                            "format": data["Format"].stringValue,
                            "documentId": data["DocumentID"].stringValue,
                            "message": data["NumberOfAttachment"].stringValue,
                            "fileName": data["FileName"].stringValue,
                            "uploadedAt": data["UploadedAt"].stringValue]
                        )
                    }
                }
                
                if json["Data"][0]["IsPrescriptionAttached"].stringValue == "true" {
                    for data in json["Data2"]["Prescription"].arrayValue {
                        self.prescriptionArr.append(
                            ["documentUrl": data["DocumentURL"].stringValue,
                             "format": data["Format"].stringValue,
                             "documentId": data["DocumentID"].stringValue,
                             "message": data["NumberOfAttachment"].stringValue,
                             "fileName": data["FileName"].stringValue,
                             "uploadedAt": data["UploadedAt"].stringValue]
                        )
                    }
                }
                
                
                let data1:[String:String] = [
                    "title":json["Data"][0]["HealthConcernHeading"].stringValue,
                    "description":json["Data"][0]["HealthConcernMessage"].stringValue
                ]
                
                let data2:[String:String] = [
                    "title": json["Data"][0]["PaymentHeading"].stringValue,
                    "mobile": json["Data"][0]["PatientMobileNumber"].stringValue,
                    "name": json["Data"][0]["PatientName"].stringValue,
                    "orderNumber": json["Data"][0]["OrderNumber"].stringValue,
                    "transactionID": json["Data"][0]["TransactionID"].stringValue,
                    "date": json["Data"][0]["OrderDateTime"].stringValue,
                    "speciality": json["Data"][0]["SpecialityName"].stringValue,
                    "amount" : json["Data"][0]["PaidAmount"].stringValue,
                    "note":  json["Data"][0]["ReceiptNote"].stringValue
                ]
                
                let data3:[String:String] = [
                    "title":json["Data"][0]["JanAidMessageHeading"].stringValue,
                    "description":json["Data"][0]["JanAidMessage"].stringValue
                ]
                
                let data4:[String:String] = [
                    "title":json["Data"][0]["JanAidMessageHeading"].stringValue,
                    "description":json["Data"][0]["DoctorAssignedMessage"].stringValue
                ]
                
                
                for val in json["Data2"]["HistoryDetail"].arrayValue {
                    self.history.append(val["HistoryName"].stringValue)
                }
                
                for val in json["Data2"]["InvestigationDetail"].arrayValue {
                    self.investigation.append(val["ServiceName"].stringValue)
                }
                
                for val in json["Data2"]["SymptomsDetail"].arrayValue {
                    self.symptom.append(val["SymptomName"].stringValue)
                }
                
                for val in json["Data2"]["MedicineDetail"].arrayValue {
                    self.medicineList.append(MediDetail.init(
                        medicine: val["MedicinaName"].stringValue,
                        dosage: val["Name"].stringValue,
                        days: val["Days"].stringValue,
                        comments: val["Comment"].stringValue
                    ))
                }
                
                let data5:[String:String] = [
                    "experience": json["Data2"]["PrescriptionDetail"][0]["DoctorExperience"].stringValue,
                    "qualification": json["Data2"]["PrescriptionDetail"][0]["DoctorQualification"].stringValue,
                    "speciality":json["Data2"]["PrescriptionDetail"][0]["SpecialityName"].stringValue,
                    "doctorName":json["Data2"]["PrescriptionDetail"][0]["DoctorName"].stringValue,
                    "patientName":json["Data2"]["PrescriptionDetail"][0]["PatientName"].stringValue,
                    "PatientAge":json["Data2"]["PrescriptionDetail"][0]["PatientAge"].stringValue,
                    "advice":json["Data2"]["PrescriptionDetail"][0]["Advice"].stringValue,
                    "Disclaimer":json["Data2"]["PrescriptionDetail"][0]["Disclaimer"].stringValue,
                    "registration": json["Data2"]["PrescriptionDetail"][0]["DoctorRegistrationNo"].stringValue,
                    "date": json["Data2"]["PrescriptionDetail"][0]["PrescriptionDate"].stringValue,
                    "gender": json["Data2"]["PrescriptionDetail"][0]["PatientGender"].stringValue,
                    "title": json["Data2"]["ConsultationDetail"][0]["PrecsriptionHeading"].stringValue
                ]
                
                let data6:[String:String] = [
                    "heading": json["Data"][0]["FeedbackHeading"].stringValue,
                    "orderId": json["Data2"]["Feedback"][0]["CallOrderID"].stringValue,
                    "comment": json["Data2"]["Feedback"][0]["Comment"].stringValue,
                    "feedbackId": json["Data2"]["Feedback"][0]["FeedbackID"].stringValue,
                    "date": json["Data2"]["Feedback"][0]["SubmittedAt"].stringValue,
                    "rating": json["Data2"]["Feedback"][0]["Rating"].stringValue,
                ]
                
                
                if json["Data"][0]["IsDoctorAssigned"].stringValue == "False" {
                    self.dataArr = [data1,data2,data3,["":""]]
                }else  if json["Data"][0]["IsPrescriptionUploaded"].stringValue == "False"{
                    self.dataArr = [data1,data2,data3,data4,["":""]]
                }else if self.isFeedBack == "true" {
                    self.dataArr = [data1,data2,data3,data4,["":""],data5,["":""],data6]
                } else{
                    self.dataArr = [data1,data2,data3,data4,["":""],data5,["":""]]
                }
                
                if self.dataArr.count == 7 {
                    self.ratingView.isHidden = false
                }
                
                self.doctorId = json["Data"][0]["DoctorID"].stringValue
                
                if json["Data"][0]["CallButton"].stringValue == "True" {
                    self.callBtn.backgroundColor = UIColor(red: 172.0/255.0, green: 45.0/255.0, blue:
                        53.0/255.0, alpha: 1.0)
                }
                
                if json["Data"][0]["IsPrescriptionUploaded"].stringValue == "True" {
                    self.callBtn.isHidden = true
                }
                
                self.tableView.reloadData()
                
            }
            
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
        
    }

   
    @objc func showDoctor() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let nextview = storyboard.instantiateViewController(withIdentifier: "DoctorProfile2ViewController") as! DoctorProfile2ViewController
        nextview.doctorId = doctorId
        self.navigationController?.pushViewController(nextview, animated: true)
    }
    
    
    func deleteAttachment(Id: String) {
        
        let title = "Are you sure you want to delete this document?"
        let refreshAlert = UIAlertController(title: "Alert", message: title, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
        
        let parameter:[String:Int] = [
            "OrderID":Int(self.callID)!,
            "DocumentID":Int(Id)!
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.deleteAttachment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.attachmentArr = []
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                for data in json["Data"].arrayValue {
                    self.attachmentArr.append(
                        ["documentUrl": data["DocumentURL"].stringValue,
                         "format": data["Format"].stringValue,
                         "documentId": data["DocumentID"].stringValue,
                         "message": data["NumberOfAttachment"].stringValue,
                         "fileName": data["FileName"].stringValue,
                         "uploadedAt": data["UploadedAt"].stringValue]
                    )
                    
                    self.attachmentCount = data["NumberOfAttachment"].stringValue
                }
                
                self.tableView.reloadData()
                
            }

            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    
    func showAttachment(url: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "ShowAttachmentViewController") as! ShowAttachmentViewController
        nextview.attachmentUrl = url
        self.navigationController?.pushViewController(nextview, animated: true)
    }
    
    
    
    @IBAction func uploadFileAction(_ sender: UIButton) {
        
        self.changePicture()
    }
    
    
    func uploadPicture() {
        
        let parameter:[String:String] = [
            "OrderID":callID,
            "FileType": "jpg"
        ]

        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        
         
        ShowLoader.startLoader(view: self.view)
        
      Alamofire.upload(multipartFormData: { multipartFormData in
            
        
            let imgData = UIImageJPEGRepresentation(self.chosenImage, 0.8)!
                multipartFormData.append(imgData, withName: "Files",fileName: "file.jpg", mimeType: "image/jpg")
        
            for (key, value) in parameter {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Webservice.uploadDocument, headers:Webservice.header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                    ShowLoader.stopLoader()
                    
                    if json["Status"].stringValue == "true" {
                        self.attachmentArr = []
                        self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                        for data in json["Data"].arrayValue {
                            self.attachmentArr.append(
                                ["documentUrl": data["DocumentURL"].stringValue,
                                 "format": data["Format"].stringValue,
                                 "documentId": data["DocumentID"].stringValue,
                                 "message": data["NumberOfAttachment"].stringValue,
                                 "fileName": data["FileName"].stringValue,
                                 "uploadedAt": data["UploadedAt"].stringValue]
                            )
                            
                            self.attachmentCount = data["NumberOfAttachment"].stringValue
                        }
                    }
                    self.tableView.reloadData()
                    
                }
                
            case .failure(let encodingError):
                ShowLoader.stopLoader()
                print(encodingError)
            }
        }
    }
    
    
    @objc func addfeedBack(){
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        if HCRatingView.value == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select rating.")
            return
        }
        
        if commentView.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert comment.")
            return
        }
        
        
        let parameter:[String:Any] = [
            "CallOrderID": callID!,
            "Rating": HCRatingView.value,
            "Comment": commentView.text!,
            "PatientID" : User.patientId!
        ]
        
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.insertFeedback, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.AnimateBackgroundHeight(height: -350) { (status) in
                    print(status)
                }
                self.ratingView.isHidden = true
                self.blackView.isHidden = true
                 self.getData()
              //  sender.setTitle("show", for: .normal)
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
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

extension ConsultDataViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientDescriptionCell", for: indexPath) as! PatientDescriptionCell
            cell.descriptionLabel.text = dataArr[indexPath.row]["title"]
            
           
            let Attributes : [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font : UIFont(name: "Helvetica Bold", size: 17),
                NSAttributedStringKey.foregroundColor : UIColor.black
            ]
            let boldString = NSMutableAttributedString(string: "Health Concern: ", attributes:Attributes)
            
            let Attributes1 : [NSAttributedStringKey: Any] = [
                NSAttributedStringKey.font : UIFont(name: "Helvetica Light", size: 17) ,
                NSAttributedStringKey.foregroundColor : UIColor(red: 86.0/255.0, green: 86.0/255.0, blue: 86.0/255.0, alpha: 1.0)
            ]
            
            let normalText = NSMutableAttributedString(string: dataArr[indexPath.row]["description"]!, attributes:Attributes1)
            
            boldString.append(normalText)
            
            cell.patientDescriptionLabel.attributedText = boldString
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 1  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentReciptCell", for: indexPath) as! PaymentReciptCell
            cell.receiptNameLabel.text = dataArr[indexPath.row]["title"]
            paymentView = PaymentReceipt(frame: CGRect(x: 0, y: 0, width: cell.recieptView.frame.size.width, height: cell.recieptView.frame.size.height - 20))
            paymentView.setData(data: dataArr[indexPath.row])
            cell.recieptView.addSubview(paymentView)
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientDescriptionCell", for: indexPath) as! PatientDescriptionCell
            cell.descriptionLabel.text = dataArr[indexPath.row]["title"]
            cell.patientDescriptionLabel.text = dataArr[indexPath.row]["description"]
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentReciptCell", for: indexPath) as! PaymentReciptCell
            cell.receiptNameLabel.text = dataArr[indexPath.row]["title"]
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PrescriptionViewController") as! PrescriptionViewController
            
            controller.doctorData = dataArr[indexPath.row]
            controller.history = history
            controller.investigation = investigation
            controller.symptom = symptom
            controller.medicineList = medicineList
            
            addChildViewController(controller)
            controller.view.frame = CGRect(x: 0, y: 0, width: cell.recieptView.frame.size.width, height: cell.recieptView.frame.size.height)
            //self.view.addSubview(controller.view)
             cell.recieptView.addSubview(controller.view)
            controller.didMove(toParentViewController: self)
            
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 6 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell
            cell.delegate = self
            
            if self.prescriptionArr.count == 0 {
                cell.attachmentLabel.text = "Prescription Attachment"
                cell.tableView.isHidden = true
                cell.messageLabel.text = self.attachmentMsg
            }else{
                cell.attachmentLabel.text = "Prescription Attachment"
                cell.tableView.isHidden = false
                cell.renderData(data: self.prescriptionArr, isCompleted: self.status)
            }
            cell.addAttachmentBtn.addTarget(self, action: #selector(self.uploadFileAction(_:)), for: UIControlEvents.touchUpInside)
                cell.addAttachmentBtn.isHidden = true
            
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == 7 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientRatingCell", for: indexPath) as! PatientRatingCell
           
            cell.commentLabel.text = dataArr[indexPath.row]["comment"]
            cell.dateLabel.text = dataArr[indexPath.row]["date"]
            cell.ratingLabel.text = dataArr[indexPath.row]["rating"]!  + " ★"           
            cell.headingLabel.text = dataArr[indexPath.row]["heading"]
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            return cell
        }else if self.dataArr.count >= 4{
            if self.dataArr.count == 4 {
                if indexPath.row == 4 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientDescriptionCell", for: indexPath) as! PatientDescriptionCell
                    cell.descriptionLabel.text = dataArr[indexPath.row]["title"]
                    cell.patientDescriptionLabel.text = dataArr[indexPath.row]["description"]
                    cell.showProfileBtn.setTitle("Show Doctor Profile", for: .normal)
                    cell.showProfileBtn.addTarget(self, action: #selector(self.showDoctor), for: .touchUpInside)
                    cell.labelBottomConstraint.constant = 45.0
                    cell.backgroundColor = UIColor.clear
                    cell.selectionStyle = .none
                    return cell
                }else if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell
                    cell.delegate = self
                    
                    if attachmentCount == "0" {
                        cell.attachmentLabel.text = self.attachmentHeading
                        cell.tableView.isHidden = true
                        cell.messageLabel.text = self.attachmentMsg
                    }else{
                        cell.attachmentLabel.text = self.attachmentHeading + " (" + self.attachmentCount + ")"
                        cell.tableView.isHidden = false
                        cell.renderData(data: attachmentArr, isCompleted: self.status)
                    }
                    cell.addAttachmentBtn.addTarget(self, action: #selector(self.uploadFileAction(_:)), for: UIControlEvents.touchUpInside)
                    if dataArr.count == 6 || dataArr.count == 7 {
                        cell.addAttachmentBtn.isHidden = true
                    }
                    
                    cell.backgroundColor = UIColor.clear
                    cell.selectionStyle = .none
                    return cell
                }
            }else if self.dataArr.count > 4 {
                if indexPath.row == 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "PatientDescriptionCell", for: indexPath) as! PatientDescriptionCell
                    cell.descriptionLabel.text = dataArr[indexPath.row]["title"]
                    cell.patientDescriptionLabel.text = dataArr[indexPath.row]["description"]
                    cell.showProfileBtn.setTitle("Show Doctor Profile", for: .normal)
                    cell.showProfileBtn.addTarget(self, action: #selector(self.showDoctor), for: .touchUpInside)
                    cell.labelBottomConstraint.constant = 45.0
                    cell.backgroundColor = UIColor.clear
                    cell.selectionStyle = .none
                    return cell
                }else if indexPath.row == 4 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentCell", for: indexPath) as! AttachmentCell
                     cell.delegate = self
                    
                    if attachmentCount == "0" {
                        cell.attachmentLabel.text = self.attachmentHeading
                        cell.tableView.isHidden = true
                        cell.messageLabel.text = self.attachmentMsg
                    }else{
                        cell.attachmentLabel.text = self.attachmentHeading + " (" + self.attachmentCount + ")"
                        cell.tableView.isHidden = false
                        cell.renderData(data: attachmentArr, isCompleted: self.status)
                    }
                    cell.addAttachmentBtn.addTarget(self, action: #selector(self.uploadFileAction(_:)), for: UIControlEvents.touchUpInside)
                    if dataArr.count == 6 || dataArr.count == 7 {
                        cell.addAttachmentBtn.isHidden = true
                    }
                    
                    cell.backgroundColor = UIColor.clear
                    cell.selectionStyle = .none
                    return cell
                }
            }
        }
        
            let cell = UITableViewCell()
            return cell
    }
    
   
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row  == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "RecieptViewController") as! RecieptViewController
            nextView.receiptData = dataArr[indexPath.row]
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 5 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "PrescriptionViewController") as! PrescriptionViewController
            nextView.doctorData = dataArr[indexPath.row]
            nextView.history = history
            nextView.investigation = investigation
            nextView.symptom = symptom
            nextView.medicineList = medicineList
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
}

extension ConsultDataViewController: UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @IBAction func changePicture() {
        let refreshAlert = UIAlertController(title: "Upload:", message: title, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction!) in
            self.openLibrary(type: "image")
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.openCamera(type: "image")
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Document", style: .default, handler: { (action: UIAlertAction!) in
            let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypePDF as String], in: .import)
            documentPicker.navigationController?.navigationBar.barTintColor = Webservice.themeColor
            documentPicker.tabBarController?.tabBar.barTintColor = Webservice.themeColor
            
            documentPicker.delegate = self
            self.present(documentPicker, animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.uploadPicture()
            }
            
            
            
            
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // take phota using camera
    func openCamera(type:String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // take photo from library
    func openLibrary(type:String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension ConsultDataViewController: UIDocumentPickerDelegate {
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        
        let cico = url as URL
        print(cico)
        print(url)
        print(url.lastPathComponent)
        print(url.pathExtension)
        
        self.uploadPDF(url: url)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.view.makeToast("Operation Cancelled.", duration: 3.0, position: .bottom)
    }
    
    
    func uploadPDF(url:URL) {
        
        let parameter:[String:String] = [
            "OrderID":callID,
            "FileType": "pdf"
        ]
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            
           // let imgData = UIImageJPEGRepresentation(self.chosenImage, 0.8)!
            //multipartFormData.append(imgData, withName: "Files",fileName: "file.jpg", mimeType: "image/jpg")
            
            //let pdfData = try Data(contentsOf: url)
            //multipartFormData.append(pdfData, withName: "Files",fileName: "file.pdf", mimeType: "application/pdf")
            
            multipartFormData.append(url, withName: "Files", fileName: url.lastPathComponent, mimeType: "application/pdf")
            
            for (key, value) in parameter {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Webservice.uploadDocument, headers:Webservice.header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                    ShowLoader.stopLoader()
                    
                    if json["Status"].stringValue == "true" {
                        self.attachmentArr = []
                        self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                        for data in json["Data"].arrayValue {
                            self.attachmentArr.append(
                                ["documentUrl": data["DocumentURL"].stringValue,
                                 "format": data["Format"].stringValue,
                                 "documentId": data["DocumentID"].stringValue,
                                 "message": data["NumberOfAttachment"].stringValue,
                                 "fileName": data["FileName"].stringValue,
                                 "uploadedAt": data["UploadedAt"].stringValue]
                            )
                            
                            self.attachmentCount = data["NumberOfAttachment"].stringValue
                        }
                    }
                    self.tableView.reloadData()
                    
                }
                
            case .failure(let encodingError):
                ShowLoader.stopLoader()
                print(encodingError)
            }
        }
    }
    
    
    
}

