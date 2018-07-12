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
import NotificationBannerSwift

class PatientAdviceViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    var tmpTextField:UITextField!
    var medicineText:UITextField!
    var labText:UITextField!
    var adviceText:UITextView!
    
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
    
    
    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Advice")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Medicine(medicineName: "", flag: "0")
        self.lab(lab: "", flag: "0", pvInvestigationID: "")
        self.navigationController?.navigationItem.backBarButtonItem?.title = ""
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
            //"VisitDate":"",
            "Advice":adviceText.text!,
            "Description":"IOS",
            "UserID":GPUser.UserId
            //"EMRID":""
        ]
        
       print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAddAdvice, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
                let banner = NotificationBanner(title: "Confirmation", subtitle: "Advice added successfully." , style: .success)
                banner.show(queuePosition: .front)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
           // "Authorization": User.oneMGAuthenticationToken
        ]
        
        let replaced = String(name.map {
            $0 == " " ? "+" : $0
        })
        
       // let activityData = ActivityData()
       // NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        request =  Alamofire.request(Webservice.searchProduct + "\(replaced)&pageSize=15&city=Gurgaon&pageNumber=0&type=product", method: .get, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    //self.notificationLabel.isHidden = false
                    // self.notificationLabel.text = json["totalRecordCount"].stringValue
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
                   // NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                   // self.tableView.reloadData()
                   
                    
                    
                }
            case .failure(let error):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
           // "Authorization": User.oneMGAuthenticationToken
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
                    // NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    // self.tableView.reloadData()
            
                }
            case .failure(let error):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
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
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
        
        self.Medicine(medicineName: medicineText.text!)
    }
    
    func Medicine(medicineName:String, flag:String = "1", pvMedicineID:String = "") {
        let parameter:[String:String] = [
            "FlagNo":flag,
            "pvMedicineID":pvMedicineID,
            "MedicineID":"",
            "MedicinaName":medicineName,
            "CallID": GPAdvice.callId,
            "EMRID": "",
            "Description": "IOS",
            "UserID":GPUser.UserId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAddMedicine, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
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
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(section)
        if section == 0 {
             return self.labArr.count
        }else if section == 1 {
            return self.medicArr.count
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
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GPAdviceCell", for: indexPath) as! GPAdviceCell
           self.adviceText =  cell.adviceTextView
           
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            return nil
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
        if section == 2 {
            return 0
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
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
           // self.addSymptomAction(name: textField.text!, id: "")
        }else{
            //self.addHistory(historyName: textField.text!)
        }
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


