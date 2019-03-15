//
//  PIAppointmentAllViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 08/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class PIAppointmentAllViewController: UIViewController,IndicatorInfoProvider {
    
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
        var speciality:String!
    }
    
    var uhidView:UhidView!
    var blackView:UIView!
    var timeText:UITextField!
    
    var appointmentArr:[appointment] = []

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)

       NotificationCenter.default.addObserver(self, selector: #selector(self.PIAction(notification:)), name: NSNotification.Name(rawValue: "PIAppointmentdate"), object: nil)
        self.getAllAppointment()
    }

    public func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "ALL")
    }
    
    @objc func PIAction(notification:NSNotification) {
       self.getAllAppointment()
    }
    
    
    func getAllAppointment() {
        let parameter:[String:String] = [
            "FlagNo":"1",
            "Value1":PIUser.UserId,
            "Value2":"0",
            "Value3":"0",
            "Value4":"0",
            "Value5":"0",
            "Value6":PIUser.appointmentDate,
            "Value7":"0",
            "PageSize":"100",
            "PageNumber":"1"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
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
                        bookedAt: data["BookedAt"].stringValue,
                        speciality: data["SpecialityName"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    func inputTime(index:Int)  {
        let alert = UIAlertController(title: "", message: "Select Time", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            self.timeText = textField
            self.timeText.addTarget(self, action: #selector(self.dp(_:)), for: .editingDidBegin)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print("Text field: \(String(describing: textField?.text))")
            
            if (textField?.text)! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select time.")
            }else{
                self.confirmAppointment(by: index)
                
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dp(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .time
        
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        self.timeText.text = dateFormatter.string(from: sender.date)
    }
    
    
    func confirmAppointment(by index:Int) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:String] = [
            "FlagNo":"3",
            "AppointmentStatus":"CN",
            "AppointmentID": appointmentArr[index].appointmentID,
            "UserId": PIUser.UserId,
            "AppointmentTime": timeText.text!,
            "UHIDNumber":""
        ]
        
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.PIUpdateAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            if json["Status"].stringValue == "true" {
                self.getAllAppointment()
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
            "FlagNo":"4",
            "AppointmentStatus":"CM",
            "AppointmentID": appointmentArr[sender.tag].appointmentID,
            "UserId": PIUser.UserId,
            "UHIDNumber":self.uhidView.uhidText.text!,
            "RegistrationNumber": self.uhidView.registrationText.text!
        ]
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.PIUpdateAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.blackView.removeFromSuperview()
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            if json["Status"].stringValue == "true" {
                self.getAllAppointment()
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

extension PIAppointmentAllViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appointmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.appointmentArr[indexPath.row].appointmentStatus == "Completed"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "completed", for: indexPath) as! PIAppointmentCell
            cell.doctorNameLabel.text = self.appointmentArr[indexPath.row].doctorName
            cell.mobileLabel.text = self.appointmentArr[indexPath.row].mobile
            cell.patientNameLabel.text = self.appointmentArr[indexPath.row].patientName
            cell.appointmentnoLabel.text = self.appointmentArr[indexPath.row].appointmentNo
            cell.statusLabel.text = self.appointmentArr[indexPath.row].appointmentStatus
            cell.appointmentDateLabel.text = self.appointmentArr[indexPath.row].appointmentDate
            cell.specialityLabel.text = self.appointmentArr[indexPath.row].speciality
            cell.registrationLabel.text = self.appointmentArr[indexPath.row].UHID + "/" + self.appointmentArr[indexPath.row].registrationNumber
            
            cell.selectionStyle = .none
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PIAppointmentCell", for: indexPath) as! PIAppointmentCell
            cell.doctorNameLabel.text = self.appointmentArr[indexPath.row].doctorName
            cell.mobileLabel.text = self.appointmentArr[indexPath.row].mobile
            cell.patientNameLabel.text = self.appointmentArr[indexPath.row].patientName
            cell.appointmentnoLabel.text = self.appointmentArr[indexPath.row].appointmentNo
            cell.statusLabel.text = self.appointmentArr[indexPath.row].appointmentStatus
            cell.appointmentDateLabel.text = self.appointmentArr[indexPath.row].appointmentDate
            cell.specialityLabel.text = self.appointmentArr[indexPath.row].speciality
            
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.appointmentArr[indexPath.row].appointmentStatus == "Booked" {
            self.inputTime(index: indexPath.row)
        }else if self.appointmentArr[indexPath.row].appointmentStatus == "Confirmed" {
            self.addView(index: indexPath.row)
        }
    }
    
   
    
}
