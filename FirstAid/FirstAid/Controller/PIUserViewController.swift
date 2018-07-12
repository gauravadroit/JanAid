//
//  PIUserViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 15/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PIUserViewController: UIViewController {

    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        logoutBtn.layer.cornerRadius = logoutBtn.frame.size.width/2
        self.getUserProfile()
        self.title = "Profile"
    }

    func getUserProfile() {
        let parameter:[String:String] = [
            "Description":"IOS",
            "Value1":PIUser.UserId
        ]
    
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIProfile, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
                self.nameLabel.text = json["Data"][0]["FirstName"].stringValue + " " + json["Data"][0]["LastName"].stringValue
                self.emailLabel.text = json["Data"][0]["EmailID"].stringValue
                self.hospitalNameLabel.text = json["Data"][0]["HospitalName"].stringValue
                self.mobileLabel.text = json["Data"][0]["MobileNo"].stringValue
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }

    
    @IBAction func logoutBtnAction(_ sender: UIButton) {
        PIUser.name = ""
        PIUser.merchantKey = ""
        PIUser.UserId = ""
        PIUser.descr = ""
        
        UserDefaults.standard.setValue(PIUser.name, forKey: "PIName")
        UserDefaults.standard.setValue(PIUser.merchantKey, forKey: "PIKey")
        UserDefaults.standard.setValue(PIUser.UserId, forKey: "PIUserId")
        UserDefaults.standard.setValue(PIUser.descr, forKey: "PIDescription")
        UserDefaults.standard.setValue("", forKey: "UserType")
        UserDefaults.standard.setValue("No", forKey: "login")
        
        let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = firstController
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
