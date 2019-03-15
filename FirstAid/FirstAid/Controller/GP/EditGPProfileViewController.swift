//
//  EditGPProfileViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 25/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView

class EditGPProfileViewController: UIViewController {
    
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var ProfessionalSaveBtn: UIButton!
    @IBOutlet weak var professionalCancelBtn: UIButton!
    @IBOutlet weak var collegeText: UITextField!
    @IBOutlet weak var degreeText: UITextField!
    @IBOutlet weak var professionalView: UIView!
    @IBOutlet weak var expertiseView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var expertiseText: UITextField!
    @IBOutlet weak var expertiseHeadingLabel: UILabel!
    
    var jsonData:JSON!
    @IBOutlet weak var tableView: UITableView!
    var dataType:String!
    var updateId:String!
    
    struct Expertise {
        var name:String!
        var Id:String!
    }
    
    struct Education {
        var Id:String!
        var educationName:String!
        var college:String!
    }
    
    var EducationArr:[Education] = []
    var expertiseArr:[Expertise] = []
    var professionalArr:[Expertise] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Edit Profile"
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        expertiseView.layer.cornerRadius = 5
        expertiseView.isHidden = true
        blackView.isHidden = true
        professionalView.layer.cornerRadius = 5
        professionalView.isHidden = true
        
        self.degreeText.delegate = self
        self.collegeText.delegate = self
        
        let sidebutton = UIBarButtonItem(image: #imageLiteral(resourceName: "plus-symbol") , style: .plain, target: self, action: #selector(self.menuAction(_:)))
        self.navigationItem.rightBarButtonItem  = sidebutton
        
        self.cancelBtn.addTarget(self, action: #selector(self.cancelAction(sender:)), for: .touchUpInside)
        self.professionalCancelBtn.addTarget(self, action: #selector(self.cancelAction(sender:)), for: .touchUpInside)
        self.ProfessionalSaveBtn.addTarget(self, action: #selector(self.addEducation(sender:)), for: UIControlEvents.touchUpInside)
        
        if dataType == "expertise" {
             self.saveBtn.addTarget(self, action: #selector(self.addExpertise(sender:)), for: .touchUpInside)
        }else if dataType == "professional" {
            self.saveBtn.addTarget(self, action: #selector(self.addProfession(sender:)), for: .touchUpInside)
        }
        
        self.parseData()
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        
        if dataType == "expertise" {
            self.expertiseHeadingLabel.text = "Enter Expertise"
            self.expertiseText.placeholder = "Expertise"
            self.expertiseText.text = ""
            self.saveBtn.setTitle("Save", for: .normal)
            self.expertiseView.isHidden = false
            self.blackView.isHidden = false
        }else if dataType == "professional" {
            self.expertiseHeadingLabel.text = "Enter Professional details"
            self.expertiseText.placeholder = "Professional details"
            self.expertiseText.text = ""
            self.saveBtn.setTitle("Save", for: .normal)
            self.expertiseView.isHidden = false
            self.blackView.isHidden = false
        }else if dataType == "education" {
            self.professionalView.isHidden = false
            self.blackView.isHidden = false
            self.ProfessionalSaveBtn.setTitle("Save", for: .normal)
            self.degreeText.text = ""
            self.collegeText.text = ""
           
        }
    }
    
    
    
    
    func parseData() {
        for data in jsonData["Data"]["DoctorExpertise"].arrayValue {
            self.expertiseArr.append(Expertise.init(
                name: data["ExpertiseName"].stringValue,
                Id: data["ExpertiseID"].stringValue
            ))
        }
        
        for data in jsonData["Data"]["ProfessionalDetails"].arrayValue {
            self.professionalArr.append(Expertise.init(
                name: data["ProfessionalDetail"].stringValue,
                Id: data["docProfessionalDetailID"].stringValue
            ))
        }
        
        
        for data in jsonData["Data"]["DoctorEducation"].arrayValue {
            self.EducationArr.append(Education.init(
                Id: data["EducationID"].stringValue,
                educationName: data["EducationName"].stringValue,
                college: data["College"].stringValue
            ))
        }
        
        self.tableView.reloadData()
    }
    
    @objc func cancelAction(sender:UIButton) {
        self.blackView.isHidden = true
        self.professionalView.isHidden = true
        self.expertiseView.isHidden = true
    }
    
    
    //MARK: Education
    
    @objc func updateEducationAction(sender:UIButton) {
        self.updateId = self.EducationArr[sender.tag].Id
        self.degreeText.text = self.EducationArr[sender.tag].educationName
        self.collegeText.text = self.EducationArr[sender.tag].college
        self.ProfessionalSaveBtn.setTitle("Update", for: .normal)
        self.professionalView.isHidden = false
        self.blackView.isHidden = false
      
    }
    
    @objc func addEducation(sender:UIButton) {
        
        if sender.titleLabel?.text == "Save" {
            
            if degreeText.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert Degree.")
                return
            }
            
            if collegeText.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert College.")
                return
            }
            
            
            let parameter:[String:String] = [
                "DoctorID":GPUser.memberId,
                "EducationName":degreeText.text!,
                "CollegeName":collegeText.text!
            ]
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
            
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.updateEducation, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                if json["Status"].stringValue == "true" {
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                }
                
            }) { (error) in
                print(error)
                ShowLoader.stopLoader()
            }
        }else{
            self.updateEducation()
        }
        
    }
    
    
    @objc func deleteEducation(sender:UIButton)  {
        let educationId:String = EducationArr[sender.tag].Id
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "EducationID":educationId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.deleteEducation, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    func updateEducation() {
        
        
        if degreeText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert Degree.")
            return
        }
        
        if collegeText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert College.")
            return
        }
        
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "EducationID":updateId,
            "EducationName":degreeText.text!,
            "CollegeName": collegeText.text!
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.updateEducation, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                 UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    //MARK: - Profession
    
    
    
    @objc func addProfession(sender:UIButton) {
        
        if sender.titleLabel?.text == "Save" {
            if expertiseText.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert profession.")
                return
            }
            
            let parameter:[String:String] = [
                "DoctorID": GPUser.memberId,
                "ProfessionalName": expertiseText.text!
            ]
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
            
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.updateProfession, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                
                if json["Status"].stringValue == "true" {
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                }
                
            }) { (error) in
                print(error)
                ShowLoader.stopLoader()
            }
        }else{
            self.updateProfession()
        }
        
    }
    
    @objc func deleteProfession(sender:UIButton)  {
        let professionId:String = professionalArr[sender.tag].Id
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "ProfessionID":professionId
        ]
        
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.deleteProfession, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    
    @objc func updateProfessionAction(sender:UIButton) {
        self.updateId =  professionalArr[sender.tag].Id
        self.expertiseText.text = self.professionalArr[sender.tag].name
        self.saveBtn.setTitle("Update", for: .normal)
        self.expertiseView.isHidden = false
        self.blackView.isHidden = false
    }
    
    
    func updateProfession()  {
        
        if expertiseText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert profession.")
            return
        }
        
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "ProfessionalName": expertiseText.text!,
            "ProfessionID":updateId
            ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.updateProfession, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    //MARK: - Expertise
    
    
    @objc func addExpertise(sender:UIButton) {
        if sender.titleLabel?.text == "Save" {
            if expertiseText.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert expertise.")
                return
            }
            
            let parameter:[String:String] = [
                "DoctorID": GPUser.memberId,
                "ExpertiseName": expertiseText.text!
            ]
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
            
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.updateExpertise, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                ShowLoader.stopLoader()
                
                if json["Status"].stringValue == "true" {
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                    self.navigationController?.popViewController(animated: true)
                }else{
                    UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                }
                
            }) { (error) in
                print(error)
                ShowLoader.stopLoader()
            }
        }else{
            self.updateExpertise()
        }
    }
    
    @objc func updateExpertiseAction(sender:UIButton) {
        self.updateId =  expertiseArr[sender.tag].Id
        self.expertiseText.text = self.expertiseArr[sender.tag].name
        self.saveBtn.setTitle("Update", for: .normal)
        self.expertiseView.isHidden = false
        self.blackView.isHidden = false
    }
    
    func updateExpertise()  {
        
        if expertiseText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please insert expertise.")
            return
        }
        
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "ExpertiseName": expertiseText.text!,
            "ExpertiseID":updateId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.updateExpertise, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    @objc func deleteExpertise(sender:UIButton)  {
        let expertiseId:String = expertiseArr[sender.tag].Id
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "ExpertiseID":expertiseId
        ]
        
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.deleteExpertise, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }else{
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
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

extension EditGPProfileViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataType == "expertise" {
            return self.expertiseArr.count
        }else if dataType == "education" {
            return self.EducationArr.count
        }else if dataType == "professional" {
            return self.professionalArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if dataType == "expertise" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditExpertiseCell", for: indexPath) as! EditExpertiseCell
            cell.expertiseLabel.text = self.expertiseArr[indexPath.row].name
            cell.editBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: #selector(self.updateExpertiseAction(sender:)), for: .touchUpInside)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteExpertise(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else if dataType == "education" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditEducationCell", for: indexPath) as! EditEducationCell
            cell.degreeLabel.text = self.EducationArr[indexPath.row].educationName
            cell.collegeLabel.text = self.EducationArr[indexPath.row].college
            cell.closeBtn.tag = indexPath.row
            cell.closeBtn.addTarget(self, action: #selector(self.deleteEducation(sender:)), for: .touchUpInside)
            
            cell.editBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: #selector(self.updateEducationAction(sender:)), for: .touchUpInside)
            
            cell.selectionStyle = .none
            return cell
        }else if dataType == "professional" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditExpertiseCell", for: indexPath) as! EditExpertiseCell
            cell.expertiseLabel.text = self.professionalArr[indexPath.row].name
            cell.editBtn.tag = indexPath.row
            cell.editBtn.addTarget(self, action: #selector(self.updateProfessionAction(sender:)), for: .touchUpInside)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.deleteProfession(sender:)), for: .touchUpInside)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = UITableViewCell()
            return cell
        }
        
      
    }
}

extension EditGPProfileViewController:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if collegeText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,-_:[]()& "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textField.text?.count)! < 200 {
                return string == numberFiltered
            }else{
                return false
            }
            
        }else if degreeText == textField {
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,-_:[]()& "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if (textField.text?.count)! < 200 {
                return string == numberFiltered
            }else{
                return false
            }
            
        }
        return true
    }
}

