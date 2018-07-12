//
//  MyApptViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyApptViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var locationBtn: UIBarButtonItem!
    
    struct Appt {
        var apptId:String!
        var status:String!
        var bookedAt:String!
        var doctorName:String!
        var apptDate:String!
        var hospitalName:String!
        var address:String!
    }
    
    var apptArr:[Appt] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = "Appointment"
         menuContainerViewController.panMode = MFSideMenuPanModeNone
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAppointment()
        self.tabBarController?.tabBar.isHidden = false
        if let temp = UserDefaults.standard.string(forKey: "location") {
            print(temp)
            User.location = temp
            locationBtn.title = temp
        }else{
            User.location = "Gurgaon"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      //  self.tabBarController?.tabBar.isHidden = true
    }
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func locationAction(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getAppointment() {
        let parameter:[String:String] = [
            "FlagNo":"1",
            "AppointmentID": "0",
            "AppointmentStatus":"0",
            "PatientID" : User.patientId,
            "DoctorID" : "0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.showAppt, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                self.apptArr = []
                for data in json["Data"].arrayValue {
                    self.apptArr.append(Appt.init(
                        apptId: data["AppointmentID"].stringValue,
                        status:  data["AppointmentStatus"].stringValue,
                        bookedAt:  data["BookedAt"].stringValue,
                        doctorName:  data["DoctorName"].stringValue,
                        apptDate:  data["AppointmentDate"].stringValue,
                        hospitalName:  data["HospitalName"].stringValue,
                        address: data["Address"].stringValue
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
   
    func cancelAppointment(appointmentId:String) {
        var parameter:[String:String] = [
            "FlagNo": "2",
            "AppointmentID": appointmentId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.cancelAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
                self.getAppointment()
            }else {
               Utility.showMessageDialog(onController: self, withTitle: " ", withMessage: "You can't be cancel this appointment")
            }
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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

extension MyApptViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.apptArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyApptCell", for: indexPath) as! MyApptCell
        
        cell.apptdateLabel.text = apptArr[indexPath.row].apptDate
        cell.bookedDateLabel.text =  apptArr[indexPath.row].address
        cell.doctorLabel.text = apptArr[indexPath.row].doctorName
        cell.hospitalLabel.text = apptArr[indexPath.row].hospitalName
        cell.statusLabel.text = apptArr[indexPath.row].status
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if apptArr[indexPath.row].status == "Cancelled" {
            return false
        }
        return true
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
           // selectedOrderId = labTestArr[indexPath.section].testArr[indexPath.row].testId
            //selectedOrderId = orderArr[sender.tag].orderId
           // self.confirmCancelOrderAction()
            self.cancelAppointment(appointmentId: apptArr[indexPath.row].apptId)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancel"
    }
    
}
