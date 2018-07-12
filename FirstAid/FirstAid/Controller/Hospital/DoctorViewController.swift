//
//  DoctorViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

class DoctorViewController: UIViewController {

    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var appointmentDateText: UITextField!
    @IBOutlet weak var appointmentBookView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    struct doctor {
        var firstName:String!
        var lastName:String!
        var gender:String!
        var specialist:String!
        var doctorId:String!
        var fee:String!
        var qualification:String!
        var weekTime:String!
        var dailyTime:String!
    }
    
    struct shift {
        var weekTime:String!
        var doctorId:String!
        var rowId:String!
        var secondShift:String!
        var firstShift:String!
    }
    
    var shiftArr:[shift] = []
    
    
    var doctorArr:[doctor] = []
    var doctorId:String = "0"
    var hospitalId:String!
    var specId:String!
    var hospitalName:String!
    override func viewDidLoad() {
        super.viewDidLoad()

       self.title = hospitalName
        tableView.separatorStyle = .none
       // self.backView.layer.cornerRadius = 5
        //self.backView.dropShawdow()
       // self.getDoctor()
        shadowView.isHidden = true
        appointmentBookView.isHidden = true
        appointmentDateText.addTarget(self, action: #selector(self.dp(_:)), for: .editingDidBegin)
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getDoctor()
    }
    
    @IBAction func dp(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        appointmentDateText.text = dateFormatter.string(from: sender.date)
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        self.view.endEditing(true)
        shadowView.isHidden = true
        appointmentBookView.isHidden = true
        doctorId = "0"
        appointmentDateText.text = ""
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if appointmentDateText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill appointment date.")
            return
        }
        
        let parameter:[String:String] = [
            "FlagNo":"1",
            "AppointmentID":"0",
            "PatientID":User.patientId,
            "DoctorID" :doctorId,
            "AppointmentDate": appointmentDateText.text!, //mm/dd/yyyy
            "AppointmentStatus":"B",
            "UserId":"0",
            "HospitalID":hospitalId
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.bookAppt, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
                if json["Data"]["AppointmentID"].stringValue != "" {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let nextView = storyboard.instantiateViewController(withIdentifier: "ApptSuccessViewController") as! ApptSuccessViewController
                    self.navigationController?.pushViewController(nextView, animated: true)
                }
            }else if json["Status"].stringValue == "false" {
                //self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.view.makeToast("Doctor not available on selected date.", duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
        
    }
    
    @IBAction func filterAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SpecialistViewController") as! SpecialistViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
  
    
    func getDoctor() {
        
        let parameter:[String:String] = [
            "FlagNo":"1",
            //"Value1":"null",
//"Value2":"null",
            "Value3":"0",
            "Value4":"0",
            "Value5":"0",
            "Value6":"0",
            "Value7":hospitalId,
            "Value8":"0",
            "Value9":specId,
            "PageNumber":"1",
            "PageSize":"100"
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
       
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getDoctorForhospital, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            //if json[]
            
            self.doctorArr = []
            self.shiftArr = []
            if json["Status"].stringValue == "true" {
                for data in json["Data2"].arrayValue {
                    self.shiftArr.append(shift.init(
                        weekTime: data["DayArray"].stringValue,
                        doctorId: data["DoctorID"].stringValue,
                        rowId: data["RowID"].stringValue,
                        secondShift: data["SecondShift"].stringValue,
                        firstShift: data["FirstShift"].stringValue
                    ))
                }
                
              //  let count:Int = (json["Data"].array?.count)!
                //for i in 0..<count {
                for data in json["Data"].arrayValue {
                    
                    var weekTime:String = ""
                    var dailyTime:String = ""
                    if let location = self.shiftArr.index(where: { $0.doctorId == data["DoctorID"].stringValue }) {
                        
                        weekTime = self.shiftArr[location].weekTime
                        dailyTime = self.shiftArr[location].firstShift + " " +  self.shiftArr[location].secondShift
                    }
                    
                    self.doctorArr.append(doctor.init(
                        firstName: data["FirstName"].stringValue,
                        lastName: data["LastName"].stringValue,
                        gender: data["GenderName"].stringValue,
                        specialist: data["SpecialityName"].stringValue,
                        doctorId: data["DoctorID"].stringValue,
                        fee: data["Fee"].stringValue,
                        qualification: data["Qualification"].stringValue,
                        weekTime: weekTime,
                        dailyTime: dailyTime
                    ))
                    
                }
                self.tableView.reloadData()
            }
            
            
            /*for data in json["Data"].arrayValue {
                self.hospitalArr.append(Hospital.init(
                    name: data["HospitalName"].stringValue,
                    logoName: data["LogoName"].stringValue,
                    cityName: data["CityName"].stringValue,
                    address: data["Address"].stringValue,
                    emailId: data["EmailID"].stringValue,
                    hosiptalId: data["HospitalID"].stringValue,
                    stateName: data["StateName"].stringValue,
                    contactNumber: data["ContactNo"].stringValue,
                    lat: data["Latitude"].stringValue,
                    long: data["Longitude"].stringValue
                ))
            }
            
            self.tableView.reloadData()*/
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    @objc func bookApptAction(sender:UIButton) {
        shadowView.isHidden = false
        appointmentBookView.isHidden = false
        self.doctorId = self.doctorArr[sender.tag].doctorId
        
    }
    
    @objc func viewDoctorAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "DoctorViewController") as! DoctorViewController
        self.navigationController?.pushViewController(nextView, animated: true)
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

extension DoctorViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctorArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorCell", for: indexPath) as! DoctorCell
        cell.selectionStyle = .none
        cell.nameLabel.text = "Dr. " + self.doctorArr[indexPath.row].firstName + " " + self.doctorArr[indexPath.row].lastName + " (" + self.doctorArr[indexPath.row].gender + ")"
        cell.specialistLabel.text = self.doctorArr[indexPath.row].specialist
        cell.bookApptBtn.tag = indexPath.row
        cell.bookApptBtn.addTarget(self, action: #selector(self.bookApptAction(sender:)), for: .touchUpInside)
        cell.feeLabel.text = "Fees: ₹" + self.doctorArr[indexPath.row].fee
        cell.qualificationLabel.text = self.doctorArr[indexPath.row].qualification
        cell.weekLabel.text = self.doctorArr[indexPath.row].weekTime
        cell.timeLabel.text = self.doctorArr[indexPath.row].dailyTime
        cell.experienceLabel.text = ""
        
        return cell
    }
}

extension DoctorViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

