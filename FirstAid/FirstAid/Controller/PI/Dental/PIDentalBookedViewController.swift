//
//  PIDentalBookedViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 19/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PIDentalBookedViewController: UIViewController, IndicatorInfoProvider {

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
    var timeText:UITextField!
    
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
        return IndicatorInfo(title: "BOOKED")
    }
    
    
    func getAllDentalAppointment() {
        let parameter:[String:String] = [
            "Value1":PIUser.UserId,
            "Value2":"0",
            "Value3":"0",
            "Value4":"0",
            "Value5":"0",
            "Value6":PIUser.dentalDate,
            "Value7":"B",
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
            "AppointmentID": appointmentArr[index].appointmentID,
            "UserId": PIUser.UserId,
            "AppointmentTime": timeText.text!
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.PIConfirmDentalAppt, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
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

extension PIDentalBookedViewController:UITableViewDelegate, UITableViewDataSource {
    
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
        if self.appointmentArr[indexPath.row].appointmentStatus == "Booked" {
            self.inputTime(index: indexPath.row)
        }
    }
    
}
