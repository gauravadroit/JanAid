//
//  GPAdviceViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 16/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class GPAdviceViewController: UIViewController, IndicatorInfoProvider {

    struct GPAll {
        var doctorName:String!
        var patDob:String!
        var age:String!
        var gender:String!
        var callId:String!
        var HospitalName:String!
        var patientName:String!
        var patientId:String!
        var hospitalAssignedDate:String!
        var callStatus:String!
        var hospitalStatus:String!
        var doctorAssignedDate:String!
    }
    
     var pdfView:PDFView!
    var GPAllArr:[GPAll] = []
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        NotificationCenter.default.addObserver(self, selector: #selector(self.GpAction(notification:)), name: NSNotification.Name(rawValue: "date"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllGP()
    }
    
    @objc func GpAction(notification:NSNotification) {
        self.getAllGP()
    }

    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Adviced")
    }
    

    func getAllGP() {
        let parameter:[String:String] = [
            "PageSize": "100",
            "PageNumber": "1",
            "Value1": GPAdvice.date,
            "Value2": GPAdvice.date,
            "Value3":"AD",
            "Value4":"0",
            "Value5":GPUser.UserId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPAll, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                self.GPAllArr = []
                for data in json["Data"].arrayValue {
                    self.GPAllArr.append(GPAll.init(
                        doctorName: data["MainDoctorName"].stringValue,
                        patDob: data["PatDOB"].stringValue,
                        age: data["Age"].stringValue,
                        gender: data["Gender"].stringValue,
                        callId: data["CallID"].stringValue,
                        HospitalName: data["HospitalName"].stringValue,
                        patientName: data["PatientName"].stringValue,
                        patientId: data["PatientID"].stringValue,
                        hospitalAssignedDate: data["HospitalAssignedDate"].stringValue,
                        callStatus: data["CallStatus"].stringValue,
                        hospitalStatus: data["hstStatus"].stringValue,
                        doctorAssignedDate: data["DoctorAssignedDate"].stringValue
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


extension GPAdviceViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GPAllArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllGpCell", for: indexPath) as! AllGpCell
        cell.countLabel.text = String(indexPath.row + 1)
        cell.dateLabel.text = self.GPAllArr[indexPath.row].doctorAssignedDate
        cell.doctorNameLabel.text = self.GPAllArr[indexPath.row].doctorName
        cell.hospitalName.text = self.GPAllArr[indexPath.row].HospitalName
        cell.nameLabel.text = self.GPAllArr[indexPath.row].patientName
       
        cell.callStatus.text = self.GPAllArr[indexPath.row].callStatus
        cell.appointmentDate.text = self.GPAllArr[indexPath.row].hospitalAssignedDate
        cell.actionBtn.tag = indexPath.row
        if self.GPAllArr[indexPath.row].callStatus == "GP Adviced" {
            cell.actionBtn.setImage(#imageLiteral(resourceName: "action"), for: .normal)
        }else if self.GPAllArr[indexPath.row].callStatus == "GP Assigned" {
            cell.actionBtn.setImage(#imageLiteral(resourceName: "Edit-1"), for: .normal)
        }else if self.GPAllArr[indexPath.row].callStatus == "Hospital Assigned" {
            
            let tintedImage = #imageLiteral(resourceName: "Edit-1").withRenderingMode(.alwaysTemplate)
            cell.actionBtn.setImage(tintedImage, for: .normal)
            cell.actionBtn.tintColor = UIColor.lightGray
        }else{
            cell.actionBtn.setImage(#imageLiteral(resourceName: "action"), for: .normal)
        }
        cell.actionBtn.addTarget(self, action: #selector(self.actionBtnAction(sender:)), for: .touchUpInside)
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func actionBtnAction(sender:UIButton) {
        if self.GPAllArr[sender.tag].callStatus == "GP Adviced" {
            self.genratePrescription(callId: self.GPAllArr[sender.tag].callId)
        }else if self.GPAllArr[sender.tag].callStatus == "GP Assigned" {
            let stroyboard = UIStoryboard(name: "GP", bundle: nil)
            let nextview = stroyboard.instantiateViewController(withIdentifier: "GPPatientDetailsViewController") as! GPPatientDetailsViewController
            nextview.callId = self.GPAllArr[sender.tag].callId
            nextview.name = self.GPAllArr[sender.tag].patientName
            nextview.assignedAtstr = self.GPAllArr[sender.tag].doctorAssignedDate
            nextview.patientId = self.GPAllArr[sender.tag].patientId
            // nextview.mobileNo = self.GPAllArr[indexPath.row].
            //nextview.gender =
            GPAdvice.patientGender = self.GPAllArr[sender.tag].gender
            GPAdvice.patientName = self.GPAllArr[sender.tag].patientName
            GPAdvice.patientAge = self.GPAllArr[sender.tag].age
            
            self.navigationController?.pushViewController(nextview, animated: true)
            
        }else if self.GPAllArr[sender.tag].callStatus == "Hospital Assigned" {
            
        }
    }
    
}
