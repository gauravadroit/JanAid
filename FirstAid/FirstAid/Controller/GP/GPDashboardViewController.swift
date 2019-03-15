//
//  GPDashboardViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 16/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView

class GPDashboardViewController: ButtonBarPagerTabStripViewController {

    
    @IBOutlet weak var activeSwitch: UISwitch!
    let blueInstagramColor = UIColor.black
    
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    var conditionView:TermsCondition!
    var acceptFlag:Int = 0
    override func viewDidLoad() {
        
        GPAdvice.date = getDate1()
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        settings.style.selectedBarBackgroundColor = UIColor(red: 127.0/255.0, green: 205.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        
        settings.style.buttonBarItemFont = UIFont(name: "Helvetica", size: 16)!
        
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor(red: 146/255.0, green: 147/255.0, blue: 156/255.0, alpha: 0.8)
        
        settings.style.buttonBarItemTitleColor =  UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            newCell?.label.textColor = self?.blueInstagramColor
            
        }
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.dateLabel.text = getDate()
        var accept = "no"
        
        if let temp = UserDefaults.standard.string(forKey: "accept") {
            accept = temp
        }
        
        if accept == "no" {
            self.privacyPolicyAction()
        }
        
        if GPUser.active == "true" {
            self.activeSwitch.isOn = true
            activeLabel.text = "Active"
            self.activeLabel.textColor = UIColor.green
        } else {
            self.activeSwitch.isOn = false
            activeLabel.text = "Inactive"
            self.activeLabel.textColor = UIColor.red
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
         self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "date"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let childOneVC = storyboard?.instantiateViewController(withIdentifier: "AllViewController")
        let childTwoVC = storyboard?.instantiateViewController(withIdentifier: "NewViewController")
        let childThreeVC = storyboard?.instantiateViewController(withIdentifier: "GPAdviceViewController")
        let childFourVC = storyboard?.instantiateViewController(withIdentifier: "GPHospitalViewController")
        
        return [childOneVC!, childTwoVC! , childThreeVC!, childFourVC!]
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func getDate1() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }


    @IBAction func backDateAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        GPAdvice.date = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "date"), object: nil, userInfo: nil)
    }
    
    @IBAction func nextDateAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        GPAdvice.date = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "date"), object: nil, userInfo: nil)
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
                UserDefaults.standard.setValue("", forKey: "accept")
                
                let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = firstController
            }
 
        }) { (error) in
            print(error)
        }
        
        
    }
    
    
    
    
     func privacyPolicyAction() {
        conditionView = TermsCondition(frame: CGRect(x: 30, y: 40, width: UIScreen.main.bounds.size.width - 60, height: UIScreen.main.bounds.size.height - 80))
        conditionView.headerLabel.text = "Terms for Pracitioners"
        conditionView.acceptBtn.isHidden = false
        conditionView.acceptBtn.addTarget(self, action: #selector(self.acceptBtn(sender:)), for: .touchUpInside)
        conditionView.dropShawdow()
        conditionView.closeBtn.isHidden = true
        conditionView.okBtn.addTarget(self, action: #selector(self.removeAgreement(sender:)), for: UIControlEvents.touchUpInside)
        if let path = Bundle.main.url(forResource:"GP_Terms&Condition", withExtension: "txt"){
            do {
                conditionView.contentTextView.text = try String(contentsOf: path, encoding: .utf8)
                
            }
            catch {
                print("No data")
            }
        }
        self.view.addSubview(conditionView)
        UIApplication.shared.keyWindow?.addSubview(conditionView)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
