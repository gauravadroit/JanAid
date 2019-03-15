//
//  DentalHospitalViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DentalHospitalViewController: UIViewController {
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var locationBtn: UIButton!
    
    var zoneId:String!
    @IBOutlet weak var tableView: UITableView!
    var appointmentDateText:UITextField!
    
    struct hospital {
        var address:String!
        var long:String!
        var lat:String!
        var zoneName:String!
        var cityName:String!
        var imageUrl:String!
        var clinicName:String!
        var clinicId:String!
    }
    
    var hospitalArr:[hospital] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Dental Clinic"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        customView.dropShawdow()
        customView.layer.cornerRadius = 5
        locationBtn.addTarget(self, action: #selector(self.locationAction(_:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if User.location != nil {
            locationLabel.text = User.location
        }
        self.getHospital()
    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    
    func getHospital() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
       
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getDentalHospital + "\(zoneId!)&CityName=\(User.location!)&Latitude=0&Longitude=0" , headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            self.hospitalArr = []
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.hospitalArr.append(DentalHospitalViewController.hospital.init(
                        address: data["Address"].stringValue,
                        long: data["Longitude"].stringValue,
                        lat: data["Latitude"].stringValue,
                        zoneName: data["ZoneName"].stringValue,
                        cityName: data["CityName"].stringValue,
                        imageUrl: data["Image"].stringValue,
                        clinicName: data["ClinicName"].stringValue,
                        clinicId: data["ClinicID"].stringValue
                    ))
                }
            }
            
            self.tableView.reloadData()
            
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    @objc func bookAppointmentAction(sender:UIButton){
        let alert = UIAlertController(title: "", message: "Please select date", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            self.appointmentDateText = textField
            self.appointmentDateText.addTarget(self, action: #selector(self.dp(_:)), for: .editingDidBegin)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print("Text field: \(String(describing: textField?.text))")
            
            if (textField?.text)! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select date.")
            }else{
                self.bookAppointment(selectedIndex: sender.tag)
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dp(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.maximumDate = Date().addingTimeInterval(2678400)
        datePickerView.minimumDate = Date()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        appointmentDateText.text = dateFormatter.string(from: sender.date)
    }
    
    
    func bookAppointment(selectedIndex:Int) {
        let parameter:[String:String] = [
            "PatientID":User.patientId,
            "HospitalID": self.hospitalArr[selectedIndex].clinicId,
            "AppointmentDate": appointmentDateText.text!
        ]
        
        let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "DentalConfirmationViewController") as! DentalConfirmationViewController
        nextview.parameter = parameter
        nextview.hospitalName = self.hospitalArr[selectedIndex].clinicName
        nextview.address = self.hospitalArr[selectedIndex].address
        nextview.date = appointmentDateText.text!
        nextview.clinicImageUrl = self.hospitalArr[selectedIndex].imageUrl
        
        self.navigationController?.pushViewController(nextview, animated: true)
        
       /* if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.bookDentalAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }*/
        
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

extension DentalHospitalViewController :UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.hospitalArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DentalHospitalCell", for: indexPath) as! DentalHospitalCell
        cell.addressLabel.text = self.hospitalArr[indexPath.row].address
        cell.hospitalNameLbl.text = self.hospitalArr[indexPath.row].clinicName
        cell.discountLabel.text = self.hospitalArr[indexPath.row].cityName
        cell.hospitalImage.sd_setImage(with: URL(string: self.hospitalArr[indexPath.row].imageUrl), placeholderImage: UIImage(named: "Hospital"))
        cell.bookAppointmentBtn.tag = indexPath.row
        cell.bookAppointmentBtn.addTarget(self, action: #selector(self.bookAppointmentAction(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        nextView.lat = hospitalArr[indexPath.row].lat
        nextView.long = hospitalArr[indexPath.row].long
        nextView.hosiptalName = hospitalArr[indexPath.row].zoneName
        self.navigationController?.pushViewController(nextView, animated: true)
        
    }
    
}
