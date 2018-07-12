//
//  GPPatientDetailsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView



class GPPatientDetailsViewController: UIViewController, SelectAddressDelegate {

    @IBOutlet weak var patientAddressLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var registerNumberLabel: UILabel!
    @IBOutlet weak var assignedAt: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var tmpTextField:UITextField!
    var symptomText:UITextField!
    var historyText:UITextField!
    var name:String!
    var gender:String!
    var callId:String!
    var mobileNo:String!
    var assignedAtstr:String!
    var patientId:String!
    
    var autoCompleteView:AutoComplete!
    var request:DataRequest!
    var medicineArr:[medicineSearch] = []
    var popController:PopViewController!
    
      var pdfView:PDFView!
    
    struct symptom {
        var name:String!
        var id:String!
        var pvSymptomId:String!
    }
    
    struct history {
        var name:String!
        var id:String!
        var pvHistoryId:String!
    }
    
    struct viewHistory {
        var CallID:String!
        var HospitalAssignedAt:String!
    }
    
    var visitHistoryArr:[viewHistory] = []
    
    
    var symArr:[String] = []
    var historyArr:[history] = []
    var symptomArr:[symptom] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignedAt.text = assignedAtstr
        nameLabel.text = name + " (\(GPAdvice.patientGender!))"
        registerNumberLabel.text = self.callId
        GPAdvice.callId = self.callId
        self.title = "Patient Details"
        self.addSymptomAction(name: "", id: "", flag: "0")
        self.addHistory(historyName: "", flag: "2")
        self.visitHistory()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.tableView.backgroundColor = UIColor.clear
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.getCalldetails()
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GP", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "GPAssignPatientViewController") as! GPAssignPatientViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getCalldetails() {
        let parameter:[String:String] = [
            "FlagNo":"0",
            "CallID":callId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getCallDetails, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
           
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
              self.patientAddressLabel.text = json["Data"]["Address"].stringValue
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    
    func visitHistory() {
        let parameter:[String:String] = [
            "Value1":patientId,
            "PageSize":"100",
            "PageNumber":"1"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.viewHistory, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.visitHistoryArr.append(viewHistory.init(
                        CallID: data["CallID"].stringValue,
                        HospitalAssignedAt: data["HospitalAssignedAt"].stringValue
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
    
    @objc func addSymptomAction(sender:UIButton) {
        if symptomText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill symptom.")
            return
        }
        self.addSymptomAction(name: symptomText.text!, id: "")
    }

    
    func addSymptomAction(name:String,id:String,flag:String = "1") {
        let parameter:[String:String] = [
            "CallID":callId,
            "Description":"IOS",
            "EMRID":"",
            "FlagNo":flag,
            "SymptomID":id,
            "SymptomName":name                              ,
            "UserID":GPUser.UserId,
            "pvSymptomID":""
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addSympton, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            self.symptomText.text = ""
            if json["Status"].stringValue == "true" {
                self.symptomArr = []
                for data in json["Data"].arrayValue {
                    self.symptomArr.append(symptom.init(
                        name: data["SymptomName"].stringValue,
                        id: data["SymptomID"].stringValue,
                        pvSymptomId: data["pvSymptomID"].stringValue
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
    
    func getSymptom(str:String) {
        
        let parameter:[String:String] = ["Text":str]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getSymptom, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
        }) { (error) in
            print(error)
        }
        
        /*DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getSymptom + "cough", headers: Webservice.header, { (json) in
            print(json)
        }) { (error) in
            print(error)
        }*/
    }
    
    func selectedIndex(index: Int) {
        autoCompleteView.removeFromSuperview()
        self.view.endEditing(true)
      //  self.nextViewWithStr(str: medicineArr[index].pname)
        //self.addSymptomAction(name: medicineArr[index].pname, id: medicineArr[index].id)
        self.symptomText.text = medicineArr[index].pname
       
    }
    
    func addAutoCompleteView() {
        autoCompleteView = AutoComplete(frame: CGRect(x: 15, y: 250, width: self.view.frame.size.width - 30, height: 280))
        autoCompleteView.delegate = self
        autoCompleteView.medicineArr = self.medicineArr
        autoCompleteView.layer.cornerRadius = 5
        autoCompleteView.dropShawdow()
        autoCompleteView.tableView.reloadData()
        self.view.addSubview(autoCompleteView)
    }
   
    
    func getSearchData(name:String) {
        
        if request != nil {
            request.cancel()
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let parameter:[String:String] = ["Text":name]
       

        request =  Alamofire.request(Webservice.getSymptom, method: .post, parameters:parameter, encoding: JSONEncoding.default, headers:Webservice.header).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    self.medicineArr = []
                    self.symArr = []
                    for data in json["Data"].arrayValue {
                        print(data)
                            self.medicineArr.append(medicineSearch.init(
                                pname: data["Text"].stringValue,
                                discountedPrice: "",
                                MRP: 0.0,
                                manufacturer: "",
                                meta: "",
                                discountPercentageStr: "",
                                id: data["Value"].stringValue,
                                imgUrl: ""
                            ))
                        
                        self.symArr.append(data["Text"].stringValue)
                    }
                    
                    
                    
                    if self.popController != nil {
                        self.popController.dismiss(animated: false, completion: nil)
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }else{
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        self.popController = storyBoard.instantiateViewController(withIdentifier: "PopViewController") as!  PopViewController
                    }
                    
                    self.dropDown(self.symptomText, selector: self.symArr)
                    //self.tableView.reloadData()
                    
                    
                    
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    
    @objc func deleteSymptomAction(sender:UIButton)  {
        let parameter:[String:String] = [
            "CallID":callId,
            "Description":"IOS",
            "EMRID":"",
            "FlagNo":"0",
            "SymptomID":"",
            "SymptomName":""                              ,
            "UserID":GPUser.UserId,
            "pvSymptomID":self.symptomArr[sender.tag].pvSymptomId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addSympton, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                self.symptomArr = []
                for data in json["Data"].arrayValue {
                    self.symptomArr.append(symptom.init(
                        name: data["SymptomName"].stringValue,
                        id: data["SymptomID"].stringValue,
                        pvSymptomId: data["pvSymptomID"].stringValue
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
    
   
    
    func addHistory(historyName:String, flag:String = "1") {
        let parameter:[String:String] = [
            "FlagNo":flag,
            "pvHistoryID":"0",
            "CallID":callId,
            "EMRID":"",
            "PatientID":patientId,
            "HistoryID":"",
            "HistoryName":historyName,
            "Description":"IOS",
            "UserID":GPUser.UserId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addHistory, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            self.historyText.text = ""
            if json["Status"].stringValue == "true" {
                self.historyArr = []
                for data in json["Data"].arrayValue {
                    self.historyArr.append(history.init(
                        name: data["HistoryName"].stringValue,
                        id: data["HistoryID"].stringValue,
                        pvHistoryId: data["pvHistoryID"].stringValue
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
    
    @objc func addHistoryAction(sender: UIButton) {
        
        if historyText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill history.")
            return
        }
        
        self.addHistory(historyName: historyText.text!)
    }
    
    @objc func deleteHistoryAction(sender:UIButton) {
        let parameter:[String:String] = [
            "FlagNo":"0",
            "pvHistoryID": self.historyArr[sender.tag].pvHistoryId,
            "CallID":callId,
            "EMRID":"",
            "PatientID":patientId,
            "HistoryID":"",
            "HistoryName":"",
            "Description":"IOS",
            "UserID":GPUser.UserId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addHistory, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                self.historyArr = []
                for data in json["Data"].arrayValue {
                    self.historyArr.append(history.init(
                        name: data["HistoryName"].stringValue,
                        id: data["HistoryID"].stringValue,
                        pvHistoryId: data["pvHistoryID"].stringValue
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
    
    @objc func symptomAutocompleteAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "GP", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "GPSymptomsAutoComplete") as! GPSymptomsAutoComplete
        nextView.delegate = self
        self.present(nextView, animated: true, completion: nil)
    }
    
    @objc func historyAutocompleteAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "GP", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "GPPatientHistoryAutoComplete") as! GPPatientHistoryAutoComplete
        nextView.delegate = self
        self.present(nextView, animated: true, completion: nil)
    }
    
    @objc func showPrescription(sender:UIButton) {
        self.genratePrescription(callId: self.visitHistoryArr[sender.tag].CallID)
    }
    
    func genratePrescription(callId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.genratePrescription + callId, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                let width = UIScreen.main.bounds.size.width - 60
                let height = UIScreen.main.bounds.size.height - 80
                print(width,height)
                self.pdfView = PDFView(frame: CGRect(x: 30, y: 40, width: width, height: height))
                self.pdfView.setNeedsLayout()
                self.pdfView.layoutIfNeeded()
                
                let hospitalData = json["Data"]["Table11"][0].dictionaryValue
                self.pdfView.addressLabel.text = hospitalData["Address"]?.stringValue
                self.pdfView.hospitalNameLabel.text = hospitalData["HospitalName"]?.stringValue
                self.pdfView.emailLabel.text = hospitalData["EmailID"]?.stringValue
                self.pdfView.mobileLabel.text = hospitalData["ContactNo"]?.stringValue
                
                
                let patientData = json["Data"]["Table"][0].dictionaryValue
                self.pdfView.patientLabelName.text = (patientData["FirstName"]?.stringValue)! + " " + (patientData["LastName"]?.stringValue)!
                self.pdfView.patientCodeLabel.text = patientData["PatientCode"]?.stringValue
                
                
                self.pdfView.ageLabel.text = (patientData["Age"]?.stringValue)! + " Y/\(String(describing: (patientData["GenderName"]?.stringValue)!.character(at: 0)!))"
                
                let AppointmentData = json["Data"]["Table1"][0].dictionaryValue
                self.pdfView.doctorNameLabel.text = "Dr." + (AppointmentData["DoctorName"]?.stringValue)! + " " + (AppointmentData["Qualification"]?.stringValue)!
                self.pdfView.registrationLabel.text = AppointmentData["RegistrationNo"]?.stringValue
                self.pdfView.dateLabel.text = AppointmentData["CalledAt"]?.stringValue
                
                self.pdfView.closeBtn.addTarget(self, action: #selector(self.removeFromSuperView), for: .touchUpInside)
                self.pdfView.dropShawdow()
                
                var test:[String] = []
                var medicine:[String] = []
                var advice:[String] = []
                
                for data in json["Data"]["Table4"].arrayValue {
                    test.append(data["ServiceName"].stringValue)
                }
                
                for data in json["Data"]["Table5"].arrayValue {
                    medicine.append(data["MedicinaName"].stringValue)
                }
                
                for data in json["Data"]["Table8"].arrayValue {
                    advice.append(data["Advice"].stringValue)
                }
                
                self.pdfView.renderData(data: [test,medicine,advice])
                
                UIApplication.shared.keyWindow?.addSubview(self.pdfView)
                UIApplication.shared.keyWindow?.layoutIfNeeded()
                UIApplication.shared.keyWindow?.setNeedsLayout()
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    @objc func removeFromSuperView() {
        self.pdfView.removeFromSuperview()
        
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

extension GPPatientDetailsViewController:UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(section)
        if section == 0 {
            return self.symptomArr.count
        }else if section == 1 {
            return self.historyArr.count
        }
        
        return self.visitHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell", for: indexPath) as! SymptomCell
            cell.symptomLabel.text = self.symptomArr[indexPath.row].name
            cell.cancelBtn.setImage(#imageLiteral(resourceName: "close"), for: UIControlState.normal)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteSymptomAction(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell0", for: indexPath) as! SymptomCell
            cell.symptomLabel.text = self.historyArr[indexPath.row].name
            cell.cancelBtn.setImage(#imageLiteral(resourceName: "close"), for: UIControlState.normal)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteHistoryAction(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 2 {
           /* let cell = UITableViewCell()
            cell.textLabel?.text = self.visitHistoryArr[indexPath.row].HospitalAssignedAt
            cell.selectionStyle = .none
            return cell*/
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell2", for: indexPath) as! SymptomCell2
            cell.symptomLabel.text = self.visitHistoryArr[indexPath.row].HospitalAssignedAt
            cell.cancelBtn.setImage(#imageLiteral(resourceName: "action"), for: UIControlState.normal)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.showPrescription(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            return cell
            
        }else{
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 2 {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Visit history"
            cell.textLabel?.textColor = UIColor(red: 0.0/255.0, green: 97.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddSymptomsCell") as! AddSymptomsCell
        cell.backgroundColor = UIColor.white
        cell.symptomText.tag = section
        
        if section == 0 {
            cell.symptomText.placeholder = "Symptoms"
            self.symptomText = cell.symptomText
            cell.completeBtn.addTarget(self, action: #selector(self.symptomAutocompleteAction(sender:)), for: .touchUpInside)
            cell.addBtn.addTarget(self, action: #selector(self.addSymptomAction(sender:)), for: .touchUpInside)
        }else if section == 1 {
            cell.symptomText.placeholder = "Patient History"
            self.historyText = cell.symptomText
            cell.completeBtn.addTarget(self, action: #selector(self.historyAutocompleteAction(sender:)), for: .touchUpInside)
            cell.addBtn.addTarget(self, action: #selector(self.addHistoryAction(sender:)), for: .touchUpInside)
        }
        
        cell.symptomText.delegate = self
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            return 40
        }
        return 62
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*if section == 2 {
            return "Visit history"
        }*/
        return ""
    }
    
}

extension GPPatientDetailsViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            self.getSearchData(name: textField.text! + string)
        }
        
        return true
    }
}

extension GPPatientDetailsViewController:symptomDelegate {
    func symptomValue(_ symtom: String) {
        self.symptomText.text! = symtom
    }
}

extension GPPatientDetailsViewController: HistoryDelegate {
    func historyValue(_ history: String) {
        self.historyText.text = history
    }
    
    
}


extension GPPatientDetailsViewController : UIPopoverPresentationControllerDelegate,PopViewControllerDelegate {
    
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
