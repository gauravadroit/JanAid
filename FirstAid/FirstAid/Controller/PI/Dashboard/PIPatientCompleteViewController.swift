//
//  PIPatientCompleteViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 08/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class PIPatientCompleteViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    
    struct patient {
        var patientName:String!
        var mobileNumber:String!
        var doctorName:String!
        var hospitalName:String!
        var callId:String!
        var hospitalAssignedDate:String!
        var specialityName:String!
        var hstStatus:String!
        var puStatus:String!
        var callStatus:String!
        var status:String!
        var registration:String!
        var uhid:String!
        var ReAssignedStatus:String!
    }
    
    var patientArr:[patient] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.PIAction(notification:)), name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPatient()
    }

    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "COMPLETE")
    }
    
    @objc func PIAction(notification:NSNotification) {
        self.getPatient()
    }
    
    
    func getPatient() {
        let parameter:[String:String] = [
            "PageSize":"100",
            "PageNumber":"1",
            "Value1": GPAdvice.date,
            "Value2": GPAdvice.date,
            "Value3":"3",
            "Value4":PIUser.UserId,
            "Value5":"0"
        ]
        
        print(parameter)
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIpatient, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.patientArr = []
                for data in json["Data"].arrayValue {
                    self.patientArr.append(patient.init(
                        patientName: data["PatientName"].stringValue,
                        mobileNumber: data["PatientMobileNumber"].stringValue,
                        doctorName: data["DoctorName"].stringValue,
                        hospitalName: data["HospitalName"].stringValue,
                        callId: data["CallID"].stringValue,
                        hospitalAssignedDate: data["HospitalAssignedDate"].stringValue,
                        specialityName: data["SpecialityName"].stringValue,
                        hstStatus: data["hstStatus"].stringValue,
                        puStatus: data["PUStatus"].stringValue,
                        callStatus: data["CallStatus"].stringValue,
                        status: data["Status"].stringValue,
                        registration: data["Registration"].stringValue,
                        uhid: data["UHID"].stringValue,
                        ReAssignedStatus: data["ReAssignedStatus"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    @objc func actionBtn(Sender:UIButton) {
        let value:[String:String] = [
            "patientName":self.patientArr[Sender.tag].patientName,
            "mobileNumber":self.patientArr[Sender.tag].mobileNumber,
            "doctorName":self.patientArr[Sender.tag].doctorName,
            "hospitalName":self.patientArr[Sender.tag].hospitalName,
            "callId":self.patientArr[Sender.tag].callId,
            "hospitalAssignedDate":self.patientArr[Sender.tag].hospitalAssignedDate,
            "specialityName":self.patientArr[Sender.tag].specialityName,
            "hstStatus":self.patientArr[Sender.tag].hstStatus,
            "puStatus":self.patientArr[Sender.tag].puStatus,
            "callStatus":self.patientArr[Sender.tag].puStatus,
            ]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PINewStatus"), object: nil, userInfo: value)
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

extension PIPatientCompleteViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return patientArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Completed", for: indexPath) as! PIPatientCell
        cell.countLabel.text = String(indexPath.row + 1)
        cell.doctorNameLabel.text = "Dr. " + self.patientArr[indexPath.row].doctorName
        cell.mobileLabel.text = self.patientArr[indexPath.row].mobileNumber
        cell.patientNameLabel.text = self.patientArr[indexPath.row].patientName
        cell.dateLabel.text = self.patientArr[indexPath.row].hospitalAssignedDate
        cell.hospitalNameLabel.text = self.patientArr[indexPath.row].hospitalName
        cell.statusLabel.text = self.patientArr[indexPath.row].status
        cell.reassignLabel.text = self.patientArr[indexPath.row].ReAssignedStatus
        cell.registrationNoLabel.text = self.patientArr[indexPath.row].uhid + "/" + self.patientArr[indexPath.row].registration
        cell.PIStatusLabel.text = self.patientArr[indexPath.row].puStatus
        cell.specialityLabel.text = self.patientArr[indexPath.row].specialityName
        let tintedImage = #imageLiteral(resourceName: "Edit-1").withRenderingMode(.alwaysTemplate)
        cell.actionBtn.setImage(tintedImage, for: .normal)
        cell.actionBtn.tintColor = UIColor.lightGray
        cell.actionBtn.tag = indexPath.row
        cell.actionBtn.addTarget(self, action: #selector(self.actionBtn(Sender:)), for: .touchUpInside)
        cell.PIStatusLabel.textColor = UIColor.green
        cell.selectionStyle = .none
        return cell
    }
}
