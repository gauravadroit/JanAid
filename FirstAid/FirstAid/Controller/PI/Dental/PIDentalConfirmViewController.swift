//
//  PIDentalConfirmViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 19/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PIDentalConfirmViewController: UIViewController, IndicatorInfoProvider {
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
    
    var uhidView:UhidView!
    var blackView:UIView!
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
        return IndicatorInfo(title: "CONFIRM")
    }
    
    func getAllDentalAppointment() {
        let parameter:[String:String] = [
            "Value1":PIUser.UserId,
            "Value2":"0",
            "Value3":"0",
            "Value4":"0",
            "Value5":"0",
            "Value6":PIUser.dentalDate,
            "Value7":"CN",
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
    
    
    
    func addView(index:Int) {
        blackView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.view.addSubview(blackView)
        
        self.uhidView = UhidView(frame: CGRect(x: 15, y: (self.view.frame.size.height - 280)/2 , width: self.view.frame.size.width - 30, height: 280.0))
        self.uhidView.layer.cornerRadius = 5
        self.uhidView.layer.masksToBounds = true
        self.uhidView.cancelBtn.addTarget(self, action: #selector(self.cancelAction(sender:)), for: .touchUpInside)
        self.uhidView.submitBtn.tag = index
        self.uhidView.submitBtn.addTarget(self, action: #selector(self.completeAppointment(sender:)), for: .touchUpInside)
        
        
        blackView.addSubview(self.uhidView)
    }
    
    @objc func cancelAction(sender:UIButton) {
        self.blackView.removeFromSuperview()
    }
    
    
    @objc func completeAppointment(sender:UIButton) {
        
        
        if self.uhidView.registrationText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter Registration number.")
            return
        }
        
        if self.uhidView.uhidText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter UHID.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:String] = [
            "AppointmentID": appointmentArr[sender.tag].appointmentID,
            "UserId": PIUser.UserId,
            "RegistrationNumber": self.uhidView.registrationText.text!,
            "UHIDNumber": self.uhidView.uhidText.text!
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.PICompleteDentalAppt, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.blackView.removeFromSuperview()
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            if json["Status"].stringValue == "true" {
                self.getAllDentalAppointment()
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

extension PIDentalConfirmViewController:UITableViewDelegate, UITableViewDataSource {
    
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
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.appointmentArr[indexPath.row].appointmentStatus == "Confirmed" {
            self.addView(index: indexPath.row)
        }
    }
    
}
