//
//  PatientAdviceViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
//import NotificationBannerSwift
import ActionSheetPicker_3_0

class PatientAdviceViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    var tmpTextField:UITextField!
    var medicineText:UITextField!
    var labText:UITextField!
    var adviceText:UITextView!
    var pickerView:PickerTool!
    var orderId:String!
    @IBOutlet weak var descriptionTex: UITextView!
    
    @IBOutlet weak var daysText: UITextField!
    @IBOutlet weak var dosageText: UITextField!
    @IBOutlet weak var medicineImage: UIImageView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var decriptionText: UITextView!
    @IBOutlet weak var medicineLabel: UILabel!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var blackView: UIView!
    
    var imagePicker = UIImagePickerController()
    var chosenImage:UIImage!
    
    var patientDes:String!
    var request:DataRequest!
    var request1:DataRequest!
    struct medicine {
        var pname:String!
        var discountedPrice:String!
        var MRP:Double!
        var manufacturer:String!
        var meta:String!
        var discountPercentageStr:String!
        var id:String!
        var imgUrl:String!
        var avaliablity:String!
        var prescriptionRequired:String!
        var oprice:String!
        var sellingUnit:String!
    }
   
    var medicineArr:[medicine] = []
    var mediArr:[String] = []
    var popController:PopViewController!
    
    struct testSuggestion {
        var name:String!
        var subName:String!
        var id:String!
        var category:String!
        var type:String!
    }
    
    var testSuggestionArr:[testSuggestion] = []
    var testArr:[String] = []
    
    struct medi {
        var name:String!
        var pvMedicineId:String!
        var callId:String!
        var medicineId:String!
    }
    var medicArr:[medi] = []
    
    struct labs {
        var name:String!
        var pvInvestigationID:String!
        var callId:String!
        var ServiceID:String!
    }
    var labArr:[labs] = []
    
    struct dosage {
        var id:String!
        var value:String!
    }
    
    var dosageArr:[dosage] = []
    var dosageNameArr:[String] = []
    
    struct Attachment {
        var documentUrl:String!
        var format:String!
        var documentId:String!
        var message:String!
        var fileName:String!
        var uploadedAt:String!
    }
    
    var attachmentArr:[[String:String]] = []
    
    
    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Advice")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Medicine(medicineName: "", flag: "0")
        self.lab(lab: "", flag: "0", pvInvestigationID: "")
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
        
        pickerView = PickerTool.loadClass() as? PickerTool
        dosageText.inputView = pickerView
        dosageText.delegate = self
        daysText.delegate = self
        daysText.tag = 10
        
        self.descriptionTex.text = self.patientDes
        descriptionTex.layer.borderColor = Webservice.themeColor.cgColor
        descriptionTex.layer.borderWidth = 1
        descriptionTex.layer.cornerRadius = 5
        descriptionTex.isEditable = false
       
        
        self.setupPopUp()
        self.getDosage()
        self.getAttachment()
    }
    
    func setupPopUp() {
        addBtn.layer.cornerRadius = 5
        popUpView.layer.cornerRadius = 5
        popUpView.isHidden = true
        blackView.isHidden = true
        decriptionText.layer.borderColor = Webservice.themeColor.cgColor
        decriptionText.layer.borderWidth = 1
        decriptionText.layer.cornerRadius = 5
        
        
        
        
        medicineImage.layer.borderColor = Webservice.themeColor.cgColor
        medicineImage.layer.borderWidth = 1
        medicineImage.layer.cornerRadius = medicineImage.frame.size.height/2
        addBtn.addTarget(self, action: #selector(self.saveMedicineOnServer(sender:)), for: UIControlEvents.touchUpInside)
    }
    
    
    func getDosage() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPDosage, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.dosageArr.append(dosage.init(
                        id: data["VALUE"].stringValue,
                        value: data["Text"].stringValue
                    ))
                    
                    self.dosageNameArr.append(data["Text"].stringValue)
                }
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    @IBAction func submitbtnAction(_ sender: UIButton) {
        self.submitAction()
    }
    
    func submitAction() {
        let parameter:[String:String] = [
            "FlagNo":"0",
            "CallID":GPAdvice.callId,
            "PatientName":GPAdvice.patientName,
            "Gender":GPAdvice.patientGender,
            "Age":GPAdvice.patientAge,
            "Advice":adviceText.text!,
            "Description":"IOS",
            "UserID":GPUser.UserId
            
        ]
        
       print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAddAdvice, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
             ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
               
                self.setConversation()
            }
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    func setConversation() {
        let parameter:[String:String] = [
            "FlagNo":"3",
            "Value1":GPAdvice.callId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPConversation, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                
                UIApplication.shared.keyWindow?.makeToast("Advice added successfully." , duration: 3.0, position: .bottom)
                
                 self.navigationController?.popToRootViewController(animated: true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    

    func getSearchData(name:String) {
        if request != nil {
            request.cancel()
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
           
        ]
        
        let replaced = String(name.map {
            $0 == " " ? "+" : $0
        })
        
        
        request =  Alamofire.request(Webservice.searchProduct + "\(replaced)&pageSize=15&city=Gurgaon&pageNumber=0&type=product", method: .get, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    
                    self.medicineArr = []
                    self.mediArr = []
                    for data in json["result"].arrayValue {
                        print(data)
                        self.medicineArr.append(medicine.init(
                            pname: data["name"].stringValue,
                            discountedPrice: data["discounted_price"].stringValue,
                            MRP: data["mrp"].doubleValue,
                            manufacturer: data["manufacturer"].stringValue,
                            meta: data["packSizeLabel"].stringValue,
                            discountPercentageStr: data["discount_percent_str"].stringValue,
                            id: data["id"].stringValue,
                            imgUrl: data["imgUrl"].stringValue,
                            avaliablity: data["available"].stringValue,
                            prescriptionRequired: data["prescriptionRequired"].stringValue,
                            oprice: data["oPrice"].stringValue,
                            sellingUnit: data["su"].stringValue
                        ))
                        
                        self.mediArr.append(data["name"].stringValue)
                    }
                    
                    if self.popController != nil {
                        self.popController.dismiss(animated: false, completion: nil)
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }else{
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }
                    
                    self.dropDown(self.medicineText, selector: self.mediArr)
                   
                }
            case .failure(let error):
                ShowLoader.stopLoader()
                print(error)
            }
        }
        
    }
    
    
    func getSearchedLabs(searchText:String) {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
           
        ]
        
        let replaced = String(searchText.map {
            $0 == " " ? "+" : $0
        })
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        request1 =  Alamofire.request(Webservice.getSearchTest + "Gurgaon&search_text=" + replaced, method: .get, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    self.testSuggestionArr = []
                    self.testArr = []
                    
                    for data in json.arrayValue {
                        self.testSuggestionArr.append(testSuggestion.init(
                            name: data["name"].stringValue,
                            subName:data["sub_name"].stringValue,
                            id: data["id"].stringValue,
                            category: data["category"].stringValue,
                            type: data["type"].stringValue
                        ))
                        self.testArr.append(data["name"].stringValue)
                    }
                    
                    if self.popController != nil {
                        self.popController.dismiss(animated: false, completion: nil)
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }else{
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }
                    
                    self.dropDown(self.labText, selector: self.testArr)
                    
            
                }
            case .failure(let error):
                ShowLoader.stopLoader()
                print(error)
            }
        }
    }
    
    @objc func deleteLabAction(sender:UIButton) {
        self.lab(lab: "", flag: "0", pvInvestigationID: self.labArr[sender.tag].pvInvestigationID)
    }
    
    @objc func addLabAction(sender:UIButton) {
        if labText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill investigation.")
            return
        }
        
        self.lab(lab: labText.text!)
    }
    
    func lab(lab:String, flag:String = "1", pvInvestigationID:String = "") {
        let parameter:[String:String] = [
            "FlagNo":flag,
            "pvInvestigationID":pvInvestigationID,
            "ServiceID":"",
            "ServiceName":lab,
            "CallID": GPAdvice.callId,
            "EMRID": "",
            "Description":"IOS",
            "UserID":GPUser.UserId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.GPAddLab, dataDict: parameter, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                self.labArr = []
                for data in json["Data"].arrayValue {
                    self.labArr.append(labs.init(
                        name: data["ServiceName"].stringValue,
                        pvInvestigationID: data["pvInvestigationID"].stringValue,
                        callId: data["CallID"].stringValue,
                        ServiceID: data["ServiceID"].stringValue
                    ))
                }
                self.tableView.reloadData()
            }
             ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
        }
        
    }
    
    
    @objc func deleteMedicineAction(sender:UIButton) {
        self.Medicine(medicineName: "", flag: "0", pvMedicineID: medicArr[sender.tag].pvMedicineId)
    }
    
    @objc func addMedicineAction(sender:UIButton) {
        
        if medicineText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill medicine.")
            return
        }
        
        //self.Medicine(medicineName: medicineText.text!)
        self.addDosage(medicine: medicineText.text!)
    }
    
    func addDosage(medicine:String)  {
        popUpView.isHidden = false
        blackView.isHidden = false
        medicineLabel.text = medicine
        daysText.text = ""
        dosageText.text = ""
        decriptionText.text = ""
        decriptionText.textColor = UIColor.gray
        decriptionText.text = "Description..."
        decriptionText.delegate = self
    }
    
    @IBAction func closePopUpAction(_ sender: UIButton) {
        popUpView.isHidden = true
        blackView.isHidden = true
        medicineLabel.text = ""
        daysText.text = ""
        dosageText.text = ""
        decriptionText.text = ""
    }
    
    @objc func saveMedicineOnServer(sender:UIButton) {
        if dosageText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select dosages.")
            return
        }
        
        if daysText.text! == "0" || daysText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter days.")
            return
        }
        
        if self.decriptionText.text! == "" ||  self.decriptionText.text! == "Description..."  {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill description.")
            return
        }
        
        let index:Int = dosageNameArr.index(of: dosageText.text!)!
        let dosage = dosageArr[index].id
        
        self.Medicine(medicineName: medicineLabel.text!, Dosage: dosage!, days: daysText.text!, comments: decriptionText.text!)
        
    }
    
    
    func Medicine(medicineName:String, flag:String = "1", pvMedicineID:String = "",Dosage:String = "", days:String = "", comments:String  = "") {
        let parameter:[String:String] = [
            "FlagNo":flag,
            "pvMedicineID":pvMedicineID,
            "MedicineID":"",
            "MedicinaName":medicineName,
            "CallID": GPAdvice.callId,
            "EMRID": "",
            "Description": "IOS",
            "UserID":GPUser.UserId,
            "Dosage":Dosage,
            "Days":days,
            "Comment":comments
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAddMedicine, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            self.popUpView.isHidden = true
            self.blackView.isHidden = true
            
            if json["Message"].stringValue == "Success" {
                self.medicArr = []
                for data in json["Data"].arrayValue {
                    self.medicArr.append(medi.init(
                        name: data["MedicinaName"].stringValue,
                        pvMedicineId: data["pvMedicineID"].stringValue,
                        callId: data["CallID"].stringValue,
                        medicineId: data["MedicineID"].stringValue
                    ))
                }
                self.tableView.reloadData()
            }
            ShowLoader.stopLoader()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    @objc func investigationAutocompleteAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "GP", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "GPInvestigationAutoComplete") as! GPInvestigationAutoComplete
        nextView.delegate = self
        self.present(nextView, animated: true, completion: nil)
    }
    
    @objc func medicineAutocompleteAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "GP", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "GPMedicineAutoComplete") as! GPMedicineAutoComplete
        nextView.delegate = self
        self.present(nextView, animated: true, completion: nil)
    }
    
    @objc func addAttachment(sender:UIButton) {
        self.changePicture()
    }
    
    func uploadPicture() {
        
        let parameter:[String:String] = [
            "OrderID": self.orderId,
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
        }, to: Webservice.UploadPrescriptionImage, headers:Webservice.header)
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
                    
                        self.attachmentArr = []
                    if json["Status"].stringValue == "true" {
                        
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
                            
                           // self.attachmentCount = data["NumberOfAttachment"].stringValue
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
    
    
    func getAttachment() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getPrescriptionAttachment + self.orderId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.attachmentArr = []
            if json["Status"].stringValue == "true" {
                
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
                    
                    // self.attachmentCount = data["NumberOfAttachment"].stringValue
                }
            }
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    @objc func deleteAttachment(sender:UIButton) {
        
        let title = "Are you sure you want to delete this document?"
        let refreshAlert = UIAlertController(title: "Alert", message: title, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            
          
            let parameter:[String:Int] = [
                "OrderID":Int(self.orderId)!,
                "DocumentID": Int(self.attachmentArr[sender.tag]["documentId"]!)!
            ]
            
            print(parameter)
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                    
                })
                
                return
            }
            
            
            ShowLoader.startLoader(view: self.view)
            
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.deletePrescription, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                
                    self.attachmentArr = []
                if json["Status"].stringValue == "true" {
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

    @objc func showAttachment(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "ShowAttachmentViewController") as! ShowAttachmentViewController
        nextview.attachmentUrl = self.attachmentArr[sender.tag]["documentUrl"]!
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

extension PatientAdviceViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
             return self.labArr.count
        }else if section == 1 {
            return self.medicArr.count
        }else if section == 2 {
            return self.attachmentArr.count
        }
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell", for: indexPath) as! SymptomCell
            cell.symptomLabel.text = self.labArr[indexPath.row].name
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteLabAction(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell1", for: indexPath) as! SymptomCell
            cell.symptomLabel.text = self.medicArr[indexPath.row].name
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteMedicineAction(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentInfoCell", for: indexPath) as! AttachmentInfoCell
            cell.attachmentNameLabel.text =  self.attachmentArr[indexPath.row]["fileName"]! +  self.attachmentArr[indexPath.row]["uploadedAt"]!
           
            cell.deleteBtn.tag = indexPath.row
            cell.deleteBtn.addTarget(self, action: #selector(self.deleteAttachment(sender:)), for: UIControlEvents.touchUpInside)
            cell.viewBtn.tag  = indexPath.row
            cell.viewBtn.addTarget(self, action: #selector(self.showAttachment(sender:)), for: UIControlEvents.touchUpInside)
            
            cell.selectionStyle = .none
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GPAdviceCell", for: indexPath) as! GPAdviceCell
            self.adviceText =  cell.adviceTextView
           
           
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 {
            return nil
        }else if section == 2 {
             let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentHeaderCell") as! AttachmentHeaderCell
            cell.addAttachmentBtn.addTarget(self, action: #selector(self.addAttachment(sender:)), for: .touchUpInside)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSymptomsCell") as! AddSymptomsCell
        cell.backgroundColor = UIColor.white
        cell.symptomText.tag = section
        cell.symptomText.delegate = self
        
        if section == 0 {
            self.labText = cell.symptomText
            cell.symptomText.placeholder = "Investigation"
            cell.completeBtn.addTarget(self, action: #selector(self.investigationAutocompleteAction(sender:)), for: .touchUpInside)
            cell.addBtn.addTarget(self, action: #selector(self.addLabAction(sender:)), for: .touchUpInside)
        }else if section == 1 {
            self.medicineText = cell.symptomText
            cell.symptomText.placeholder = "Medicine"
            cell.completeBtn.addTarget(self, action: #selector(self.medicineAutocompleteAction(sender:)), for: .touchUpInside)
            cell.addBtn.addTarget(self, action: #selector(self.addMedicineAction(sender:)), for: .touchUpInside)
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 3 {
            return 0
        }else if section == 2 {
            return 50
        }
        return 62
    }
    
    
    
}

extension PatientAdviceViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            self.getSearchedLabs(searchText: textField.text! + string)
        } else if textField.tag == 1 {
            self.getSearchData(name: textField.text! + string)
        }
        
        if daysText == textField {
            let allowedCharacter = "1234567890"
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        
        return true
    }
    
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
       if textField == dosageText  {
            if dosageText.text == "" {
                dosageText.text = dosageNameArr[0]
            }
            
            self.setPickerInfo(dosageText, withArray: dosageNameArr)
        }
        
    }
    
    func setPickerInfo(_ textfield: UITextField, withArray array: [Any])
    {
        pickerView?.pickerViewMethod(textfield, arr: array as! [AnyHashable])
    }
    
}

extension PatientAdviceViewController:InvestigationDelegate {
    func investigationValue(_ history: String) {
        labText.text = history
    }
    
    
}

extension PatientAdviceViewController:MedicineDelegate {
    func medicineValue(_ medicine: String) {
        medicineText.text = medicine
    }
}


extension PatientAdviceViewController : UIPopoverPresentationControllerDelegate,PopViewControllerDelegate {
    
    func dropDown(_ textField:UITextField , selector:[String]) {
        popController.delegate = self
        popController.arr = selector
        popController.modalPresentationStyle = UIModalPresentationStyle.popover
        popController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
        popController.popoverPresentationController?.delegate = self
        popController.popoverPresentationController?.sourceView = textField
        popController.popoverPresentationController?.sourceRect = textField.bounds
        popController.preferredContentSize = CGSize(width: 320, height: 250)
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

extension PatientAdviceViewController: UITextViewDelegate {
    
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
        if textView.text.count < 200 {
            return text == numberFiltered
        }else{
            return false
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.gray {
            textView.textColor = UIColor.black
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.gray
            textView.text = "Description..."
        }
    }
}

extension PatientAdviceViewController: UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @IBAction func changePicture() {
        let refreshAlert = UIAlertController(title: "Upload:", message: title, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction!) in
            self.openLibrary(type: "image")
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.openCamera(type: "image")
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



