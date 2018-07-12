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
        var appointmentId:String!
        var patientName:String!
        var mobileNumber:String!
        var doctorName:String!
        var status:String!
    }
    
    var appoinmentArr:[appointment] = []

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
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Status"].stringValue == "true" {
                self.appoinmentArr = []
                for data in json["Data"].arrayValue {
                    self.appoinmentArr.append(appointment.init(
                        appointmentId: data["AppointmentID"].stringValue,
                        patientName: data["PatientName"].stringValue,
                        mobileNumber: data["PatientMobileNumber"].stringValue,
                        doctorName: data["DoctorName"].stringValue,
                        status: data["AppointmentStatus"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
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

extension PIAppointmentAllViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appoinmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PIAppointmentCell", for: indexPath) as! PIAppointmentCell
        cell.doctorNameLabel.text = self.appoinmentArr[indexPath.row].doctorName
        cell.mobileLabel.text = self.appoinmentArr[indexPath.row].mobileNumber
        cell.patientNameLabel.text = self.appoinmentArr[indexPath.row].patientName
        cell.appointmentnoLabel.text = self.appoinmentArr[indexPath.row].appointmentId
        cell.statusLabel.text = self.appoinmentArr[indexPath.row].status
        return cell
    }
    
   
    
}
