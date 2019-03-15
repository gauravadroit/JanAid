//
//  LabMyOrderViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class LabMyOrderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    struct LabTest {
        var orderId:String!
        var name:String!
        var gender:String!
        var date:String!
        var time:String!
        var labName:String!
        var labRating:String!
        var labLogo:String!
        var labId:String!
        var testArr:[LabBooking] = []
        var accreditation:String!
        var reportURL:String!
        var labType:String!
    }
    
    var cancelOrderView:CancelOrder!
    var selectedOrderId:String!
    var labTestArr:[LabTest] = []
    var fromSideMenu = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.tableView.separatorStyle = .none
        self.title = "Reports"
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        self.getNiramyaLabTest()
        self.getMyOrder()
       // self.getNew1MGToken()
        
        menuContainerViewController.panMode = MFSideMenuPanModeNone
        
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedSectionHeaderHeight = 125;
        
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }

    
    func getMyOrder() {
        
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.labOrder, headers: headers, { (json) in
            print(json)
            
             //self.labTestArr = []
            
            for data in json["orders"].arrayValue {
                
                var temp:[LabBooking] = []
                for val in data["bookings"].arrayValue {
                    temp.append(LabBooking.init(
                        bookingId: val["test"]["id"].stringValue,
                        testId: val["id"].stringValue,
                        testName: val["test"]["name"].stringValue,
                        status: val["status"].stringValue
                    ))
                }
                
                self.labTestArr.append(LabTest.init(
                    orderId: data["order_id"].stringValue,
                    name:  data["patient"]["name"].stringValue,
                    gender:  data["patient"]["gender"].stringValue,
                    date:  data["bookings"][0]["collection_time_slot"]["date"].stringValue,
                    time:  data["bookings"][0]["collection_time_slot"]["slot"].stringValue,
                    labName:  data["lab"]["name"].stringValue,
                    labRating:  data["lab"]["rating"].stringValue,
                    labLogo:  data["lab"]["logo"].stringValue,
                    labId:  data["lab"]["id"].stringValue,
                    testArr: temp,
                    accreditation: data["lab"]["accreditation"][0]["name"].stringValue,
                    reportURL:"",
                    labType: "1MG"
                ))
            }
            
            if json["error"]["message"].stringValue.contains("Unauthorized") {
                self.getNew1MGToken()
            }
            
            
             ShowLoader.stopLoader()
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
              ShowLoader.stopLoader()
        }
    }
    
    func getNiramyaLabTest() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getNiramayaLabTest + User.mobileNumber, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            
            if json["Status"].stringValue == "true" {
                
                for data in json["Data"].arrayValue {
                    var temp:[LabBooking] = []
                    
                        temp.append(LabBooking.init(
                            bookingId: data["OrderReference"].stringValue,
                            testId: data["TestID"].stringValue,
                            testName: data["TestName"].stringValue,
                            status: data["ReportStatus"].stringValue
                        ))
                     
                     self.labTestArr.append(LabTest.init(
                        orderId: data["OrderReference"].stringValue,
                        name:  data["Name"].stringValue,
                        gender:   data["Gender"].stringValue,
                        date:  data["date"].stringValue,
                        time:  data["Time"].stringValue,
                        labName:   data["LabName"].stringValue,
                        labRating:   data["LabRating"].stringValue,
                        labLogo:   data["LabImage"].stringValue,
                        labId:   data["LabID"].stringValue,
                        testArr: temp,
                        accreditation:  data["Accredition"].stringValue,
                        reportURL:data["ReportUrl"].stringValue,
                        labType: "NIRAMAYA"
                    
                     ))
                    
                    
                }
                self.tableView.reloadData()
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    
    func getNew1MGToken(){
        let parameter:[String:String] = [
            "api_key":"98cf1ce6-a4b1-4fe4-94ab-a4d1a9dc0cb3", //live
            "user_id":User.emailId
        ]
    
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.renewToken1MG, dataDict: parameter, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["authentication_token"].stringValue != "" {
                if json["authentication_token"].stringValue != "" {
                    self.register1MGLabToken(token: json["authentication_token"].stringValue)
                }
                
            } else if json["errors"][0]["message"].stringValue == "User already exists" {
                self.getMyOrder()
            }else if json["errors"][0]["message"].stringValue == "User Not Found" {
                self.signUpwith1MG()
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    func signUpwith1MG() {
        let header:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "THIRD-PARTY":"panasonic"
        ]
        
        let parameter:[String:String] = [
            "api_key":"98cf1ce6-a4b1-4fe4-94ab-a4d1a9dc0cb3", //live
            //"api_key":"12345678-1234-5678-1234-567812345678", // staging
            "user_id":User.emailId
        ]
        
        print(parameter)
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpwithLab, dataDict: parameter, headers: header, { (json) in
            print(json)
            
            if json["authentication_token"].stringValue != "" {
                self.register1MGLabToken(token: json["authentication_token"].stringValue)
            }
            
            ShowLoader.stopLoader()
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
        
    }
    
    func register1MGLabToken(token:String) {
        let parameter:[String:String] = [
            "Value1":User.patientId,
            "Value2":token
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGLabToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMGLab = "true"
                User.oneMGLabToken = token
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgLAB")
                UserDefaults.standard.setValue(User.oneMGLabToken, forKey: "oneMGLabToken")
                self.getMyOrder()
            }
            
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    func cancelOrderAction() {
        
        cancelOrderView = CancelOrder(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        cancelOrderView.cancelBtn.addTarget(self,action: #selector(self.removeFromSuperView), for: .touchUpInside)
        cancelOrderView.confirmBtn.addTarget(self,action: #selector(self.confirmCancelOrderAction), for: .touchUpInside)
        UIApplication.shared.keyWindow?.addSubview(cancelOrderView)
    }
    
    @objc func removeFromSuperView(){
        self.cancelOrderView.removeFromSuperview()
    }
    
    @objc func confirmCancelOrderAction(){
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGLabToken
        ]
        
        let parameter:[String:String] = [
            "cancel_reason":"testing",
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPutWithJson(path: Webservice.cancelLaborder + selectedOrderId, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            //self.removeFromSuperView()
            self.saveCancelOrder(orderId: self.selectedOrderId, orderStatus: "Cancelled")
            self.labTestArr = []
            self.getNiramyaLabTest()
            self.getMyOrder()
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    func saveCancelOrder(orderId:String,orderStatus:String){
        
        let parameter:[String:String] = [
            "BookingID": orderId,
            "OrderStatus_1mg": orderStatus
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.cancelLab, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
            }
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    
    
    func getReport(orderId:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.get1MgLabReport + orderId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "LabReportViewController") as! LabReportViewController
                nextView.reportLink = json["Data"][0]["LabReportURL"].stringValue
                self.navigationController?.pushViewController(nextView, animated: true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
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

extension LabMyOrderViewController:UITableViewDelegate, UITableViewDataSource {
  
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return labTestArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labTestArr[section].testArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabMyOrderCell2", for: indexPath) as! LabMyOrderCell2
        cell.dateLabel.text = labTestArr[indexPath.row].date
        cell.timeLabel.text = labTestArr[indexPath.row].time
        cell.testNameLabel.text = labTestArr[indexPath.section].testArr[indexPath.row].testName
        cell.testStatusLabel.text = labTestArr[indexPath.section].testArr[indexPath.row].status
        if labTestArr[indexPath.section].testArr[indexPath.row].status != "Cancelled" && labTestArr[indexPath.section].testArr[indexPath.row].status != "Booked" {
            cell.viewReportLabel.isHidden = false
        }else{
            cell.viewReportLabel.isHidden = true
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabMyOrderCell") as! LabMyOrderCell
        
        cell.labNameLabel.text = labTestArr[section].labName
        cell.nameLabel.text = labTestArr[section].name
        cell.orderIdLabel.text = labTestArr[section].orderId
        cell.ratingLabel.text = "  " + labTestArr[section].labRating + " ★"
        cell.labImage.sd_setImage(with: URL(string: labTestArr[section].labLogo), placeholderImage: #imageLiteral(resourceName: "Lab"))
        cell.accreditationLabel.text = labTestArr[section].accreditation
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if labTestArr[indexPath.section].testArr[indexPath.row].status == "Booked" && labTestArr[indexPath.section].labType != "NIRAMAYA" {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
             selectedOrderId = labTestArr[indexPath.section].testArr[indexPath.row].testId
            
            self.confirmCancelOrderAction()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancel"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if labTestArr[indexPath.section].testArr[indexPath.row].status == "Delivered" {
             self.getReport(orderId: labTestArr[indexPath.section].testArr[indexPath.row].testId)
        }else if labTestArr[indexPath.section].testArr[indexPath.row].status == "Partial" || labTestArr[indexPath.section].testArr[indexPath.row].status == "full" {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "LabReportViewController") as! LabReportViewController
            nextView.reportLink = labTestArr[indexPath.section].reportURL
            self.navigationController?.pushViewController(nextView, animated: true)
        }
       
    }
    
    
}
