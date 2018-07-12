//
//  SideMenuViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 02/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SideMenuViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var titleArr:[String] = ["Dashboard","Hospitals","Labs & Diagnostics","Medicines","Ambulance","Home Care Services","Other Services"]
    var imageArr:[String] = ["dashboard","hospital-1","labsanddiagnostics","medicine-1","ambulance-1","homecareservices","otherservice-1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        //tableView.separatorStyle = .singleLine
        //tableView.tableFooterView = UIView(frame: CGRect.zero)
        
    }
    
    @IBAction func pramacyAction(_ sender: UIButton) {
        
        if User.oneMgPharmacy == "true" {
          
            let center = storyboard?.instantiateViewController(withIdentifier: "AllOrderViewController") as! AllOrderViewController
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }
        self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
    
    
    @IBAction func labTestAction(_ sender: UIButton) {
         if User.oneMgPharmacy == "true" {
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
        
        
            DataProvider.sharedInstance.sendDataUsingHeaderAndPutWithJson(path: Webservice.patientLogout, dataDict: parameter, headers: Webservice.header, { (json) in
                print(json)
        
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
        
                    let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDelegate.window?.rootViewController = firstController
            }
            
        }) { (error) in
            print(error)
        }
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
            let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
            let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
            mfSideMenuContainer.leftMenuViewController = leftSideMenuController
            mfSideMenuContainer.centerViewController = dashboard
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mfSideMenuContainer
            
        }else if indexPath.row == 0 {
            let center = storyboard?.instantiateViewController(withIdentifier: "AllOrderViewController") as! AllOrderViewController
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 1 {
            let center = storyboard?.instantiateViewController(withIdentifier: "HospitalsViewController") as! HospitalsViewController
             center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 2 {
            if User.oneMgPharmacy == "true" {
                let center = storyboard?.instantiateViewController(withIdentifier: "LabsViewController") as! LabsViewController
                center.fromSideMenu = "true"
                let nav = UINavigationController(rootViewController: center)
                self.menuContainerViewController.centerViewController = nav
            }
        }else if indexPath.row == 3 {
            let center = storyboard?.instantiateViewController(withIdentifier: "SearchMedicineViewController") as! SearchMedicineViewController
             center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 4 {
            let center = storyboard?.instantiateViewController(withIdentifier: "AmbulanceViewController") as! AmbulanceViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 5 {
            let center = storyboard?.instantiateViewController(withIdentifier: "HomeCareViewController") as! HomeCareViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }else if indexPath.row == 6 {
            let center = storyboard?.instantiateViewController(withIdentifier: "OtherServicesViewController") as! OtherServicesViewController
            center.fromSideMenu = "true"
            let nav = UINavigationController(rootViewController: center)
            self.menuContainerViewController.centerViewController = nav
        }
        
         self.menuContainerViewController.toggleLeftSideMenuCompletion(nil)
    }
}
