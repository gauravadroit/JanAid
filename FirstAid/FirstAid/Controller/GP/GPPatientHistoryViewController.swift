//
//  GPPatientHistoryViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 01/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class GPPatientHistoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    var patientId:String!
    var name:String!
    var gender:String!
    var age:String!
    var pdfView:PDFView!
    
    struct viewHistory {
        var patientName:String!
        var status:String!
        var imageUrl:String!
        var doctorName:String
        var patientCode:String!
        var callOrderId:String!
        var CallID:String!
        var date:String!
        var reason:String!
        var patientId:String!
    }
    
    var visitHistoryArr:[viewHistory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = name + "," + gender + "," + age
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Patient Details"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.visitHistory()
    }

    
    func visitHistory() {
        let parameter:[String:String] = [
            "Value1":patientId,
            "Value2":GPUser.memberId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.previousConsultation, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.visitHistoryArr.append(viewHistory.init(
                        patientName: data["PatientName"].stringValue,
                        status: data["DisplayStatus"].stringValue,
                        imageUrl: data["DisplayIconUrl"].stringValue,
                        doctorName: data["DisplayName"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        callOrderId: data["CallOrderID"].stringValue,
                        CallID: data["CallID"].stringValue,
                        date: data["DisplayDate"].stringValue,
                        reason: data["DisplayReason"].stringValue,
                        patientId: data["PatientID"].stringValue
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
    
    
    @objc func showPrescription(sender:UIButton) {
         self.getData(callId: self.visitHistoryArr[sender.tag].callOrderId)
       // self.genratePrescription(callId: self.visitHistoryArr[sender.tag].CallID)
    }
    
    func genratePrescription(callId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
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
                ShowLoader.stopLoader()
                
                
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    @objc func removeFromSuperView() {
        self.pdfView.removeFromSuperview()
        
    }
    
    
    func getData(callId:String)  {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getConsultationDetails + callId, headers: Webservice.header, { (json) in
            print(json)
             ShowLoader.stopLoader()
            if json["Message"].stringValue == "Success" {
                
                
                
                var history:[String] = []
                var investigation:[String] = []
                var symptom:[String] = []
                var medicineList:[MediDetail] = []
                
                for val in json["Data2"]["HistoryDetail"].arrayValue {
                    history.append(val["HistoryName"].stringValue)
                }
                
                for val in json["Data2"]["InvestigationDetail"].arrayValue {
                    investigation.append(val["ServiceName"].stringValue)
                }
                
                for val in json["Data2"]["SymptomsDetail"].arrayValue {
                    symptom.append(val["SymptomName"].stringValue)
                }
                
                for val in json["Data2"]["MedicineDetail"].arrayValue {
                    medicineList.append(MediDetail.init(
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
                
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "PrescriptionViewController") as! PrescriptionViewController
                nextView.doctorData = data5
                nextView.history = history
                nextView.investigation = investigation
                nextView.symptom = symptom
                nextView.medicineList = medicineList
                self.navigationController?.pushViewController(nextView, animated: true)
                
                
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

extension GPPatientHistoryViewController:UITableViewDelegate, UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        print(self.visitHistoryArr.count)
        return self.visitHistoryArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "SymptomCell2", for: indexPath) as! SymptomCell2
           cell.symptomLabel.text = self.visitHistoryArr[indexPath.row].date
            cell.cancelBtn.setImage(#imageLiteral(resourceName: "action"), for: UIControlState.normal)
            cell.cancelBtn.tag = indexPath.row
            cell.cancelBtn.addTarget(self, action: #selector(self.showPrescription(sender:)), for: .touchUpInside)
            cell.reasonLabel.text = self.visitHistoryArr[indexPath.row].reason
        cell.nameLabel.text = self.visitHistoryArr[indexPath.row].patientName
        
            cell.selectionStyle = .none
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.getData(callId: self.visitHistoryArr[indexPath.row].callOrderId)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let cell = UITableViewCell()
            cell.textLabel?.text = "Previous consultation"
            cell.textLabel?.textColor = UIColor(red: 0.0/255.0, green: 97.0/255.0, blue: 176.0/255.0, alpha: 1.0)
            cell.selectionStyle = .none
            return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return ""
    }
    
}
