//
//  BookedOPDViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class BookedOPDViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    struct opd {
        var status:String!
        var date:String!
        var patientCode:String!
        var imageUrl:String!
        var name:String!
        var reason:String!
        var callID:String!
        var PatientId:String!
        var orderId:String!
        var gender:String!
        var age:String!
        var CallStatus:String!
        var isConsultationAllowed:String!
        var displayMsg:String!
    }
    
    var BookopdArr:[opd] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Consultation"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getDataBookedOPD()
        self.tabBarController?.tabBar.isHidden = false
    }
    

    
    
    
    func getDataBookedOPD() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPBookedOPD +  GPUser.memberId, headers: Webservice.header, { (json) in
            print(json)
            
             ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.BookopdArr = []
                for data in json["Data"].arrayValue {
                    self.BookopdArr.append(opd.init(
                        status: data["DisplayStatus"].stringValue,
                        date: data["DisplayDate"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        imageUrl: data["DisplayIconUrl"].stringValue,
                        name: data["DisplayName"].stringValue,
                        reason: data["DisplayReason"].stringValue,
                        callID: data["CallID"].stringValue,
                        PatientId: data["PatientID"].stringValue,
                        orderId:data["OrderID"].stringValue,
                        gender:data["Gender"].stringValue,
                        age:data["Age"].stringValue,
                        CallStatus:data["CallStatus"].stringValue,
                        isConsultationAllowed: data["IsConsultationAllowed"].stringValue,
                        displayMsg: data["DisplayMessage"].stringValue
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension BookedOPDViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.BookopdArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OPDCell", for: indexPath) as! OPDCell
        cell.dateLabel.text = self.BookopdArr[indexPath.row].date
        cell.descriptionLabel.text = self.BookopdArr[indexPath.row].reason
        cell.nameLabel.text = self.BookopdArr[indexPath.row].name
        cell.statusLabel.text = "  " + self.BookopdArr[indexPath.row].status + "  "
        cell.patientImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.BookopdArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        
        if self.BookopdArr[indexPath.row].CallStatus == "PT" || self.BookopdArr[indexPath.row].CallStatus == "D" {
            cell.statusLabel.backgroundColor = Utility.red
        }else if self.BookopdArr[indexPath.row].CallStatus == "AD" {
            cell.statusLabel.backgroundColor = Utility.green
        }else{
            cell.statusLabel.backgroundColor = Utility.red
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.BookopdArr[indexPath.row].isConsultationAllowed == "True" {
            if self.BookopdArr[indexPath.row].status == "Pending" {
                let storyboard = UIStoryboard(name: "GP", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "GPPatientDetailsViewController") as! GPPatientDetailsViewController
                nextView.callId = self.BookopdArr[indexPath.row].callID!
                nextView.patientId = self.BookopdArr[indexPath.row].PatientId!
                nextView.name = self.BookopdArr[indexPath.row].name!
                nextView.gender = self.BookopdArr[indexPath.row].gender
                nextView.assignedAtstr = self.BookopdArr[indexPath.row].date
                nextView.patientDes = self.BookopdArr[indexPath.row].reason
                nextView.orderId = self.BookopdArr[indexPath.row].orderId
                GPAdvice.patientGender = self.BookopdArr[indexPath.row].gender
                GPAdvice.patientName = self.BookopdArr[indexPath.row].name!
                GPAdvice.patientAge = self.BookopdArr[indexPath.row].age
                self.navigationController?.pushViewController(nextView, animated: true)
                
            }else if self.BookopdArr[indexPath.row].status == "Completed" {
                let storyboard = UIStoryboard(name: "GP", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "GPPatientHistoryViewController") as! GPPatientHistoryViewController
                nextView.patientId = self.BookopdArr[indexPath.row].PatientId!
                nextView.name = self.BookopdArr[indexPath.row].name!
                nextView.gender = self.BookopdArr[indexPath.row].gender
                nextView.age = self.BookopdArr[indexPath.row].age
                self.navigationController?.pushViewController(nextView, animated: true)
            }
            
        }else{
            self.view.makeToast(self.BookopdArr[indexPath.row].displayMsg, duration: 2.0, position: .bottom)
        }
    }
    
}


