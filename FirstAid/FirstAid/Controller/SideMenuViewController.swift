//
//  SideMenuViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 02/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FacebookLogin
import FacebookCore
import GoogleSignIn

class SideMenuViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var tableView: UITableView!
    var blackView:UIView!
    var otpView:OneMgOTP!
    var count:String!
    
    var titleArr:[String] = ["Online Consultation","Hospitals","Labs & Diagnostics","Dental Services","Reports","Other Services","Ambulance", "About Us","Help","Terms & Conditions"]
    var imageArr:[String] = ["onlineconsultmeu","hospital-1","labsanddiagnostics","Dentist_side","homecareservices","otherservice-1","ambulance-1","info","question","privacy"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        GIDSignIn.sharedInstance().uiDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.tabBadgeAction(notification:)), name: NSNotification.Name(rawValue: "reportCount"), object: nil)
        
    }
    
    @objc func tabBadgeAction(notification:NSNotification) {
        if let data = notification.userInfo as? [String:String] {
            count = data["count"]
            self.tableView.reloadData()
        }
    }
    @IBAction func dashboardAction(_ sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
        let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
        let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
        let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
        mfSideMenuContainer.leftMenuViewController = leftSideMenuController
        mfSideMenuContainer.centerViewController = dashboard
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mfSideMenuContainer
    }
    
    @IBAction func pramacyAction(_ sender: UIButton) {
        
        if User.oneMgPharmacy == "true" {
            let center = storyboard?.instantiateViewController(withIdentifier: "AllOrderViewController") as! AllOrderViewController
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else{
            self.signUpWith1MG()
            
        }
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    
    @IBAction func labTestAction(_ sender: UIButton) {
         if User.oneMGLab == "true" {
            let center = storyboard?.instantiateViewController(withIdentifier: "LabMyOrderViewController") as! LabMyOrderViewController
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    @IBAction func logoutAction(_ sender: UIButton) {
        
        let title = "Are you sure you want to logout?"
        let refreshAlert = UIAlertController(title: "Alert", message: title, preferredStyle: UIAlertControllerStyle.alert)
        refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
        
        
            let parameter:[String:String] = [
                "Value1": User.patientId,
                "Value2": "iOS",
                "Value3": UIDevice.current.identifierForVendor?.uuidString ?? "null",
                "Value4": "LoggedOut"
            ]
        
            print(parameter)
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                })
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
        
            DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.patientLogout, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
                
                ShowLoader.stopLoader()
        
                if json["Status"].stringValue == "true" {
                    User.firstName = ""
                    User.lastName = ""
                    User.motherName = ""
                    User.mobileNumber = ""
                    User.patientId = ""
                    User.genderId = ""
                    User.emailId = ""
                    User.statusId = ""
                    User.flagNumber = ""
                    User.location = ""
                    User.speciality = ""
                    User.specialityId = ""
                    User.oneMGAuthenticationToken = ""
                    User.oneMGLab = ""
                    User.oneMgPharmacy = ""
                    User.oneMGLabToken = ""
                    User.isMFI = ""
        
                    UserDefaults.standard.setValue("", forKey: "ISRegisteredOn1mgLAB")
                    UserDefaults.standard.setValue("", forKey: "ISRegisteredOn1mgPharmacy")
                    UserDefaults.standard.setValue("", forKey: "firstName")
                    UserDefaults.standard.setValue("", forKey: "lastName")
                    UserDefaults.standard.setValue("", forKey: "motherName")
                    UserDefaults.standard.setValue("", forKey: "MobileNumber")
                    UserDefaults.standard.setValue("" , forKey: "patientId")
                    UserDefaults.standard.setValue("", forKey: "genderId")
                    UserDefaults.standard.setValue("no", forKey: "login")
                    UserDefaults.standard.setValue("", forKey: "oneMGAuthenticationToken")
                    UserDefaults.standard.setValue("", forKey: "oneMGLabToken")
                    UserDefaults.standard.setValue("", forKey: "isMFI")
                    
                    let manager = LoginManager()
                    manager.logOut()
                    GIDSignIn.sharedInstance()?.signOut()
                    
        
                   // let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                    
                   /* let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientLogin_ViewController") as! PatientLoginViewController
                    
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
             ShowLoader.stopLoader()
        }
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    func signUpWith1MG(){
        let parameter:[String:String] = [
            "email": User.emailId,
            "name": User.firstName + " " + User.lastName,
            "password": "patient@" + User.patientId,
            "phone_number": User.mobileNumber,
            "cart_oos":"true"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpWith1MG, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "success" {
              
                self.blackView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                self.blackView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                self.otpView = OneMgOTP(frame: CGRect(x: 20.0, y: UIScreen.main.bounds.height/2 - 75.0, width: UIScreen.main.bounds.width - 40.0 , height: 150.0))
                self.otpView.layer.cornerRadius = 5
                self.otpView.layer.masksToBounds = true
                
                self.otpView.cancelBtn.addTarget(self, action: #selector(self.cancelAction(_:)), for: UIControlEvents.touchUpInside)
                self.otpView.okBtn.addTarget(self, action: #selector(self.okAction(_:)), for: UIControlEvents.touchUpInside)
                
                self.blackView.addSubview(self.otpView)
                UIApplication.shared.keyWindow?.addSubview(self.blackView)
                
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
                if json["errors"]["errs"][0]["msg"].stringValue.contains("already registered") {
                    self.loginWithOTP()
                }
            }
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    func loginWithOTP()  {
        let parameter:[String:String] = [
            "username": User.mobileNumber
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.loginWithOTP, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "success" {
                self.blackView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                self.blackView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
                self.otpView = OneMgOTP(frame: CGRect(x: 20.0, y: UIScreen.main.bounds.height/2 - 75.0, width: UIScreen.main.bounds.width - 40.0 , height: 150.0))
                self.otpView.layer.cornerRadius = 5
                self.otpView.layer.masksToBounds = true
                self.blackView.addSubview(self.otpView)
                self.otpView.cancelBtn.addTarget(self, action: #selector(self.cancelAction(_:)), for: UIControlEvents.touchUpInside)
                self.otpView.okBtn.addTarget(self, action: #selector(self.okAction(_:)), for: UIControlEvents.touchUpInside)
                UIApplication.shared.keyWindow?.addSubview(self.blackView)
                
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.blackView.removeFromSuperview()
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if self.otpView.OTPText.text!  == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter OTP.")
            return
        }
        
        if self.otpView.OTPText.text!.count  != 6 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "OTP should be 6 digits.")
            return
        }
        
        let parameter:[String:String] = [
            "verification_token": self.otpView.OTPText.text!,
            "password": "patient@" + User.patientId,
            "username": User.mobileNumber,
            "return_token":"true"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.verifyToken, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }else  if json["status"].stringValue == "0" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                self.blackView.removeFromSuperview()
                User.oneMGAuthenticationToken = json["result"]["authToken"].stringValue
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
                self.register1MGPrarmacyToken(token: User.oneMGAuthenticationToken)
            }
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    func register1MGPrarmacyToken(token:String) {
        let parameter:[String:String] = [
            "Value1":User.patientId,
            "Value2":token
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGpharmacyToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMgPharmacy = "true"
                User.oneMGAuthenticationToken = token
                
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgPharmacy")
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
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

extension SideMenuViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
       
        
        cell.titleLabel.text = titleArr[indexPath.row]
        cell.iconView.image = UIImage(named: imageArr[indexPath.row])
        
        if indexPath.row == 4 {
            if self.count != nil {
                cell.newLabel.text = count
                cell.newLabel.backgroundColor = UIColor.red
                cell.newLabel.textColor = UIColor.white
                cell.newLabel.layer.cornerRadius = cell.newLabel.frame.size.height/2
                cell.newLabel.layer.masksToBounds = true
            }else{
                cell.newLabel.text = ""
                cell.newLabel.backgroundColor = UIColor.white
                cell.newLabel.textColor = UIColor.white
            }
        }else{
            cell.newLabel.text = ""
            cell.newLabel.backgroundColor = UIColor.white
            cell.newLabel.textColor = UIColor.white
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
       if indexPath.row == 0 {
            let center = storyboard?.instantiateViewController(withIdentifier: "SpecialityListViewController") as! SpecialityListViewController
             center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 1 {
            let center = storyboard?.instantiateViewController(withIdentifier: "HospitalsViewController") as! HospitalsViewController
             center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 2 {
        
            if User.oneMGLab == "true" {
                let center = storyboard?.instantiateViewController(withIdentifier: "LabsViewController") as! LabsViewController
                center.fromSideMenu = "true"
                let nav = UINavigationController(rootViewController: center)
                self.menuContainerViewController.centerViewController = nav
            }
        }else if indexPath.row == 3 {
            /*if User.oneMgPharmacy == "false" {
                self.signUpWith1MG()
                return
            }*/
        
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
           // let center = storyboard?.instantiateViewController(withIdentifier: "SearchMedicineViewController") as! SearchMedicineViewController
            let center = storyboard.instantiateViewController(withIdentifier: "DentalZoneViewController") as! DentalZoneViewController
             center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 4 {
            let center = storyboard?.instantiateViewController(withIdentifier: "LabMyOrderViewController") as! LabMyOrderViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 5 {
            let center = storyboard?.instantiateViewController(withIdentifier: "OtherServicesViewController") as! OtherServicesViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        
        }else if indexPath.row == 6 {
            let center = storyboard?.instantiateViewController(withIdentifier: "AmbulanceViewController") as! AmbulanceViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 7 {
            let center = storyboard?.instantiateViewController(withIdentifier: "AboutUsViewController") as! AboutUsViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 8 {
            let center = storyboard?.instantiateViewController(withIdentifier: "HelpViewController") as! HelpViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 9 {
            let center = storyboard?.instantiateViewController(withIdentifier: "TermsViewController") as! TermsViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }
        
         self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
}
