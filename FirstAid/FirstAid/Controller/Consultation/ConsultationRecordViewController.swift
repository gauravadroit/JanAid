//
//  ConsultationRecordViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 19/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage
import Toast_Swift

class ConsultationRecordViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    struct consult {
        var patientName:String!
        var status:String!
        var patientCode:String!
        var imageURL:String!
        var speciality:String!
        var date:String!
        var reason:String!
        var callId:String!
        var callOrderId:String!
    }
    
    var consultArr:[consult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Consultation"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        
      
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
         UserDefaults.standard.setValue("0", forKey: "tabBadge")
        if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = tabItems[2] as! UITabBarItem
            tabItem.badgeValue = nil
        }
         self.getAllRecord()
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    func getAllRecord() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getConsultationRecord + User.patientId, headers: Webservice.header, { (json) in
            print(json)
             ShowLoader.stopLoader()
            self.consultArr = []
            if json["Message"].stringValue == "Success" {
                for data in json["Data"].arrayValue {
                    self.consultArr.append(consult.init(
                        patientName: data["PatientName"].stringValue,
                        status: data["DisplayStatus"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        imageURL: data["DocumentURL"].stringValue,
                        speciality: data["DisplayName"].stringValue,
                        date: data["DisplayDate"].stringValue,
                        reason: data["DisplayReason"].stringValue,
                        callId: data["CallID"].stringValue,
                        callOrderId: data["CallOrderID"].stringValue
                    ))
                }
            }
            
            if self.consultArr.count == 0 {
                self.view.makeToast("No record found.", duration: 3.0, position: .bottom)
            }
            
            self.tableView.reloadData()
            
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

extension ConsultationRecordViewController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.consultArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConsultationCell", for: indexPath) as! ConsultationCell
        
        cell.specialityLabel.text = self.consultArr[indexPath.row].speciality
        cell.descriptionLabel.text = self.consultArr[indexPath.row].reason
        cell.statusLabel.text = " " + self.consultArr[indexPath.row].status + " "
        cell.doctorImage.sd_setImage(with: URL(string: self.consultArr[indexPath.row].imageURL), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        cell.dateLabel.text = self.consultArr[indexPath.row].date
        
        if self.consultArr[indexPath.row].status == "Completed" {
            cell.statusLabel.backgroundColor = Utility.green
        }else{
            cell.statusLabel.backgroundColor = Utility.red
        }
        
        
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stroyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = stroyboard.instantiateViewController(withIdentifier: "ConsultDataViewController") as! ConsultDataViewController
        nextView.patientDescription = self.consultArr[indexPath.row].reason
        nextView.callID = self.consultArr[indexPath.row].callOrderId
        nextView.status = self.consultArr[indexPath.row].status
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    
}
