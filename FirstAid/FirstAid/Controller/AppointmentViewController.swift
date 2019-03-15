//
//  AppointmentViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class AppointmentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var pdfView:PDFView!
    var orderNowBtn:UIButton!
    
    @IBOutlet weak var locationBtn: UIBarButtonItem!
    struct Appointment {
        var callCode:String!
        var calledAt:String!
        var callStatus:String!
        var doctorName:String!
        var hospitalName:String!
        var callId:String!
        var gpName:String!
    }
    
    var appointmentArr:[Appointment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Calls"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
        self.getAppointment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
         UserDefaults.standard.setValue("0", forKey: "callTabBadge")
        if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = tabItems[3] as! UITabBarItem
            tabItem.badgeValue = nil
        }
        
        if let temp = UserDefaults.standard.string(forKey: "location") {
            print(temp)
            User.location = temp
            locationBtn.title = temp
        }else{
            User.location = "Gurgaon"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = true
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
            "Value1":User.patientId,
            "PageNumber":"1",
            "PageSize":"20"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.getAppointment, dataDict: parameter, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.appointmentArr.append(Appointment.init(
                        callCode: data["CallCode"].stringValue,
                        calledAt: data["CalledAt"].stringValue,
                        callStatus: data["CallStatus"].stringValue,
                        doctorName: data["DoctorName"].stringValue,
                        hospitalName: data["HospitalName"].stringValue,
                        callId: data["CallID"].stringValue,
                        gpName: data["GpName"].stringValue
                    ))
                }
                ShowLoader.stopLoader()
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    func genratePrescription(callId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.genratePrescription + callId, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                self.pdfView = PDFView(frame: CGRect(x: 30, y: 40, width: self.view.frame.size.width - 60, height: self.view.frame.size.height - 80))
                
                
                let hospitalData = json["Data"]["Table11"][0].dictionaryValue
                print(hospitalData)
                if hospitalData.count != 0 {
                    self.pdfView.addressLabel.text = hospitalData["Address"]?.stringValue
                    self.pdfView.hospitalNameLabel.text = hospitalData["HospitalName"]?.stringValue
                    self.pdfView.emailLabel.text = hospitalData["EmailID"]?.stringValue
                    self.pdfView.mobileLabel.text = hospitalData["ContactNo"]?.stringValue
                
                    self.pdfView.logoImage.sd_setImage(with: URL(string: Webservice.hospitalImageUrl + (hospitalData["HospitalID"]?.stringValue)! + "/" + (hospitalData["Logo"]?.stringValue)!), placeholderImage: UIImage(named: "Medicine"))
                }else{
                    self.pdfView.addressLabel.text = ""
                    self.pdfView.hospitalNameLabel.text = ""
                    self.pdfView.emailLabel.text = ""
                     self.pdfView.mobileLabel.text = ""
                }
                
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
                //self.view.addSubview(self.pdfView)
                
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
                
                self.orderNowBtn = UIButton(frame: CGRect(x: (self.view.frame.size.width - 100)/2, y: self.view.frame.size.height - 90, width: 100, height: 40))
                self.orderNowBtn.backgroundColor = UIColor.green
                self.orderNowBtn.setTitle("Order Now", for: UIControlState.normal)
                self.orderNowBtn.addTarget(self, action:#selector(self.uploadPrescription), for: .touchUpInside)
               // UIApplication.shared.keyWindow?.addSubview(self.orderNowBtn)
                 ShowLoader.stopLoader()
                
            }
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    func createPdfFromView(aView: UIView, saveToDocumentsWithFileName fileName: String)
    {
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, aView.bounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let pdfContext = UIGraphicsGetCurrentContext() else { return }
        
        aView.layer.render(in: pdfContext)
        UIGraphicsEndPDFContext()
        
        if let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let documentsFileName = documentDirectories + "/" + fileName
            debugPrint(documentsFileName)
            pdfData.write(toFile: documentsFileName, atomically: true)
        }
    }
    
    @objc func uploadPrescription(){
        self.uploadPrescriptionTo1Mg()
    }
    
   @objc func removeFromSuperView() {
   
        self.pdfView.removeFromSuperview()
        self.orderNowBtn.removeFromSuperview()
    
    }
    
    @objc func eyeAction(sender:UIButton) {
        self.genratePrescription(callId: self.appointmentArr[sender.tag].callId)
    }
    
    func uploadPrescriptionTo1Mg() {
        let parameter:[String:String] = [
            "email_id": "gaurav.saini@mailinator.com"
        ]
        
      
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let imgData = UIImageJPEGRepresentation(pdfView.takeScreenshot(), 0.7)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imgData, withName: "files",fileName: "file.jpg", mimeType: "image/jpg")
            for (key, value) in parameter {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Webservice.uploadPrescription, headers:["Authorization": User.oneMGAuthenticationToken
            
            ])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                     ShowLoader.stopLoader()
                    if json["error"].stringValue == "" {
                        self.pdfView.removeFromSuperview()
                        self.orderNowBtn.removeFromSuperview()
                        print(json["result"][0]["result"]["id"].stringValue)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextView = storyboard.instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
                        nextView.prescriptionId = json["result"][0]["result"]["id"].stringValue
                        Prescription.prescriptionId = json["result"][0]["result"]["id"].stringValue
                        Prescription.prescriptionUrl = json["result"][0]["result"]["alternate_size_image_urls"]["med"].stringValue
                        self.navigationController?.pushViewController(nextView, animated: true)
                    }
                    
                }
                
            case .failure(let encodingError):
                 ShowLoader.stopLoader()
                print(encodingError)
            }
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

extension AppointmentViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.appointmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppointmentCell", for: indexPath) as! AppointmentCell
        cell.titlelabel.text = self.appointmentArr[indexPath.row].callId
        cell.descriptionLabel.text = self.appointmentArr[indexPath.row].calledAt
        cell.statusLabel.text = "Status: " + self.appointmentArr[indexPath.row].callStatus
        
        if self.appointmentArr[indexPath.row].doctorName!.count != 0 {
            cell.hospitalNameLabel.text = self.appointmentArr[indexPath.row].gpName
        }else {
            cell.hospitalNameLabel.text = "-"
        }
        
        /*if self.appointmentArr[indexPath.row].doctorName == "" {
            cell.descriptionLabel.text = " "
        }else {
            cell.descriptionLabel.text = self.appointmentArr[indexPath.row].doctorName
        }*/
        
        
        cell.eyeActionBtn.tag = indexPath.row
        if self.appointmentArr[indexPath.row].callStatus == "Hospital Assigned" ||  self.appointmentArr[indexPath.row].callStatus == "GP Adviced" || self.appointmentArr[indexPath.row].callStatus == "Completed" {
            
            cell.eyeActionBtn.addTarget(self, action: #selector(self.eyeAction(sender:)), for: UIControlEvents.touchUpInside)
            cell.eyeActionBtn.isHidden = false
        }else{
            cell.eyeActionBtn.isHidden = true
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
