//
//  PIDentalCompleteViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 19/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PIDentalCompleteViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var tableView: UITableView!
    
    struct appointment {
        var doctorName:String!
        var appointmentType:String!
        var mobile:String!
        var UHID:String!
        var appointmentID:String!
        var appointmentDate:String!
        var hospitalName:String!
        var address:String!
        var registrationNumber:String!
        var appointmentStatus:String!
        var patientName:String!
        var appointmentNo:String!
        var bookedAt:String!
    }
    var appointmentArr:[appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.PIAction(notification:)), name: NSNotification.Name(rawValue: "PIDentaldate"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllDentalAppointment()
    }
    
    @objc func PIAction(notification:NSNotification) {
        self.getAllDentalAppointment()
    }
    
    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "COMPLETE")
    }
    
    func getAllDentalAppointment() {
        let parameter:[String:String] = [
            "Value1":PIUser.UserId,
            "Value2":"0",
            "Value3":"0",
            "Value4":"0",
            "Value5":"0",
            "Value6":PIUser.dentalDate,
            "Value7":"CM",
            "PageSize":"100",
            "PageNumber":"1"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIDentalAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.appointmentArr = []
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.appointmentArr.append(appointment.init(
                        doctorName: data["DoctorName"].stringValue,
                        appointmentType: data["AppointmentType"].stringValue,
                        mobile: data["PatientMobileNumber"].stringValue,
                        UHID: data["UHIDNumber"].stringValue,
                        appointmentID: data["AppointmentID"].stringValue,
                        appointmentDate: data["AppointmentDate"].stringValue,
                        hospitalName: data["HospitalName"].stringValue,
                        address: data["Address"].stringValue,
                        registrationNumber: data["RegistrationNumber"].stringValue,
                        appointmentStatus: data["AppointmentStatus"].stringValue,
                        patientName: data["PatientName"].stringValue,
                        appointmentNo: data["AppointmentNo"].stringValue,
                        bookedAt: data["BookedAt"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PIDentalCompleteViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PIAppointmentCell", for: indexPath) as! PIAppointmentCell
        
        cell.doctorNameLabel.text = self.appointmentArr[indexPath.row].hospitalName
        cell.appointmentnoLabel.text = self.appointmentArr[indexPath.row].appointmentNo
        cell.mobileLabel.text = self.appointmentArr[indexPath.row].mobile
        cell.patientNameLabel.text = self.appointmentArr[indexPath.row].patientName
        cell.statusLabel.text = self.appointmentArr[indexPath.row].appointmentStatus
        cell.appointmentDateLabel.text = self.appointmentArr[indexPath.row].appointmentDate
        cell.registrationLabel.text = self.appointmentArr[indexPath.row].UHID + "/" + self.appointmentArr[indexPath.row].registrationNumber
        
        cell.selectionStyle = .none
        return cell
    }
    
}
