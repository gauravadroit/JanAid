//
//  GPProfileViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class GPProfileViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Profile"
         self.title = "Profile"
        self.getProfile()
    }

    func getProfile() {
        
        let parameter:[String:String] = ["Value1" : GPUser.UserId]
        print(parameter)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.GPProfile, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            if json["Message"].stringValue == "Success" {
                self.nameLabel.text = json["Data"][0]["FirstName"].stringValue + " " + json["Data"][0]["LastName"].stringValue
                self.specialityLabel.text = json["Data"][0]["SpecialityName"].stringValue
                self.mobileLabel.text = json["Data"][0]["MobileNo"].stringValue
                self.emailLabel.text = json["Data"][0]["EmailID"].stringValue
                self.addressLabel.text = json["Data"][0]["Address"].stringValue
            }
            
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func logoutAction(_ sender: UIBarButtonItem) {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        let parameter:[String:String] = [
            "SessionID":"0",
            "UserID":GPUser.UserId,
            "UserType":"GP",
            "Description":"LoggedOut",
            "Source":"IOS"
        ]
        
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.logout, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                GPUser.name = ""
                GPUser.merchantKey = ""
                GPUser.UserId = ""
                GPUser.descr = ""
                GPUser.active = ""
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
