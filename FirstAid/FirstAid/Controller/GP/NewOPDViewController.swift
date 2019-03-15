//
//  NewOPDViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NewOPDViewController: UIViewController {

    
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var patientImage: UIImageView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var popUPView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activeSwitch: UISwitch!
    @IBOutlet weak var activeLabel: UILabel!
    
    var conditionView:TermsCondition!
    var acceptFlag:Int = 0
    
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
    }
    
    var opdArr:[opd] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "New Job"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        popUPView.layer.cornerRadius = 5
        patientImage.layer.cornerRadius = patientImage.frame.size.height/2
        patientImage.layer.masksToBounds = true
        patientImage.layer.borderWidth = 1
        patientImage.layer.borderColor = Webservice.themeColor.cgColor
        rejectBtn.layer.cornerRadius = 5
        acceptBtn.layer.cornerRadius = 5
        blackView.isHidden = true
        
        if GPUser.active == "true" {
            self.activeSwitch.isOn = true
            activeLabel.text = "Active"
            self.activeLabel.textColor = UIColor.green
        } else {
            self.activeSwitch.isOn = false
            activeLabel.text = "Inactive"
            self.activeLabel.textColor = UIColor.red
        }
        
        var accept = "no"
        
        if let temp = UserDefaults.standard.string(forKey: "accept") {
            accept = temp
        }
        
        if accept == "no" {
            self.privacyPolicyAction()
        }
        
        var count1 = 0
        if let temp = UserDefaults.standard.string(forKey: "NewJob") {
            count1 = Int(temp)!
        }
        if count1 != 0 {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = tabItems[0] as! UITabBarItem
                tabItem.badgeValue = String(count1)
            }
            
        }
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.newJobBadgeAction(notification:)), name: NSNotification.Name(rawValue: "NewJob"), object: nil)
        
    }
    
   
    @objc func newJobBadgeAction(notification:NSNotification) {
        
        var count = 0
        if let temp = UserDefaults.standard.string(forKey: "NewJob") {
            count = Int(temp)!
        }
        count = count + 1
        UserDefaults.standard.setValue(count, forKey: "NewJob")
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[0] as! UITabBarItem
            tabItem.badgeValue = String(count)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[0] as! UITabBarItem
            tabItem.badgeValue = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getDataNewOPD()
    }

    
    func privacyPolicyAction() {
        self.conditionView = TermsCondition(frame: CGRect(x: 30, y: 40, width: UIScreen.main.bounds.size.width - 60, height: UIScreen.main.bounds.size.height - 80))
        self.conditionView.headerLabel.text = "Terms for Pracitioners"
        self.conditionView.acceptBtn.isHidden = false
        self.conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptBtn(sender:)), for: .touchUpInside)
        self.conditionView.dropShawdow()
        self.conditionView.closeBtn.isHidden = true
        self.conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreement(sender:)), for: UIControlEvents.touchUpInside)
     
        
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/TermsAndConditionsForGP.htm")
        let requestObj = URLRequest(url: url!)
        self.conditionView.webView.loadRequest(requestObj)
        self.view.addSubview(self.conditionView)
        
        self.view.addSubview(self.conditionView)
        UIApplication.shared.keyWindow?.addSubview(self.conditionView)
        
      
        
    }
    
    @objc func acceptBtn(sender:UIButton) {
        if acceptFlag == 0 {
            acceptFlag = 1
            sender.setImage(#imageLiteral(resourceName: "checksquare"), for: .normal)
        }else{
            acceptFlag = 0
            sender.setImage(#imageLiteral(resourceName: "square"), for: .normal)
        }
    }
    
    @objc func removeAgreement(sender:UIButton) {
        if acceptFlag == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please Accept terms and condition.")
            return
        }
        UserDefaults.standard.setValue("yes", forKey: "accept")
        self.conditionView.removeFromSuperview()
    }
    
    
    @IBAction func logoutAction(_ sender: UIButton) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let parameter:[String:String] = [
            "SessionID":"0",
            "UserID":GPUser.UserId,
            "UserType":"GP",
            "Description":"LoggedOut",
            "Source":"IOS",
            "DeviceType": "iOS",
            "DeviceID": UIDevice.current.identifierForVendor?.uuidString ?? "null"
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.logout, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                GPUser.name = ""
                GPUser.merchantKey = ""
                GPUser.UserId = ""
                GPUser.descr = ""
                GPUser.active = ""
                GPUser.memberId = ""
                UserDefaults.standard.setValue(GPUser.memberId, forKey: "MemberID")
                UserDefaults.standard.setValue(GPUser.active, forKey: "GPActive")
                UserDefaults.standard.setValue(GPUser.name, forKey: "GPName")
                UserDefaults.standard.setValue(GPUser.merchantKey, forKey: "GPKey")
                UserDefaults.standard.setValue(GPUser.UserId, forKey: "GPUserId")
                UserDefaults.standard.setValue(GPUser.descr, forKey: "GPDescription")
                
                UserDefaults.standard.setValue("", forKey: "UserType")
                UserDefaults.standard.setValue("no", forKey: "login")
                UserDefaults.standard.setValue("no", forKey: "accept")
                
               // let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                
               /* let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientLoginViewController") as! PatientLoginViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = firstController*/
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PatientLoginViewController") as! PatientLoginViewController
                let navigationController = UINavigationController(rootViewController: nextViewController)
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                appdelegate.window!.rootViewController = navigationController
                
            }
            
        }) { (error) in
            print(error)
        }
        
    }
    
    
    @IBAction func switchAction(_ sender: UISwitch) {
        if sender.isOn {
            self.activeAndInactive(status: "true")
        }else{
            self.activeAndInactive(status: "false")
        }
    }
    
    func activeAndInactive(status:String) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        var description:String!
        
        if status == "true" {
            description = "active"
        }else{
            description = "Inactive"
        }
        
        let parameter:[String:String] = [
            "IsActive":status,
            "UserID":GPUser.UserId,
            "Description":description,
            "Source":"IOS"
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.activeGP, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                if status == "true" {
                    self.activeSwitch.isOn = true
                    GPUser.active = "true"
                    self.activeLabel.text = "Active"
                    self.activeLabel.textColor = UIColor.green
                    UserDefaults.standard.setValue(GPUser.active, forKey: "GPActive")
                } else {
                    self.activeSwitch.isOn = false
                    GPUser.active = "false"
                    self.activeLabel.text = "Inactive"
                    self.activeLabel.textColor = UIColor.red
                    UserDefaults.standard.setValue(GPUser.active, forKey: "GPActive")
                }
            }else {
                if status == "true" {
                    self.activeSwitch.isOn = false
                    self.activeLabel.text = "Inactive"
                    self.activeLabel.textColor = UIColor.red
                } else {
                    self.activeSwitch.isOn = true
                    self.activeLabel.text = "Active"
                    self.activeLabel.textColor = UIColor.green
                }
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    func getDataNewOPD() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.GPGetOPD +  GPUser.memberId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.opdArr = []
            if json["Message"].stringValue == "Success" {
                
                for data in json["Data"].arrayValue {
                    self.opdArr.append(opd.init(
                        status: data["DisplayStatus"].stringValue,
                        date: data["DisplayDate"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        imageUrl: data["DisplayIconUrl"].stringValue,
                        name: data["DisplayName"].stringValue,
                        reason: data["DisplayReason"].stringValue,
                        callID: data["CallID"].stringValue,
                        PatientId: data["PatientID"].stringValue,
                        orderId:data["OrderID"].stringValue
                    ))
                }
                
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    func showAcceptPOPUp(index:Int) {
        self.nameLabel.text = self.opdArr[index].name
        if self.opdArr[index].reason != "" {
            self.descriptionLabel.text = self.opdArr[index].reason
        }else{
            self.descriptionLabel.text =  " "
        }
        self.blackView.isHidden = false
        self.acceptBtn.tag = index
        self.acceptBtn.addTarget(self, action: #selector(self.acceptAction(sender:)), for: .touchUpInside)
        self.rejectBtn.addTarget(self, action: #selector(self.removePOPUp(sender:)), for: .touchUpInside)
    }
    
    @objc func removePOPUp(sender:UIButton) {
        self.blackView.isHidden = true
    }
    
    @objc func acceptAction(sender:UIButton) {
        
        let parameter:[String:String] = [
            "Value1":self.opdArr[sender.tag].orderId,
            "Value2":GPUser.memberId
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.GPTakeOPD, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.blackView.isHidden = true
            if json["Status"].stringValue == "true" {
                Utility.showMessageDialog(onController: self, withTitle: " ", withMessage: json["Message"].stringValue)
            }else{
                  Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: json["Message"].stringValue)
            }
            self.getDataNewOPD()
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

extension NewOPDViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.opdArr.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OPDCell", for: indexPath) as! OPDCell
        cell.dateLabel.text = self.opdArr[indexPath.row].date
        cell.descriptionLabel.text = self.opdArr[indexPath.row].reason
        cell.nameLabel.text = self.opdArr[indexPath.row].name
        cell.statusLabel.text = " " + self.opdArr[indexPath.row].status + " "
        cell.patientImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.opdArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showAcceptPOPUp(index: indexPath.row)
    }
    
}

