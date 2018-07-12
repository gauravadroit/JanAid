//
//  GPNotificationViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class GPNotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notification"
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as!
        NotificationViewController
        
        controller.parameter = ["FlagNo": 1,"UserID": GPUser.UserId!,"UserType": "GP"]
        
        
        addChildViewController(controller)
        controller.view.frame = self.view.bounds
        self.view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        
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
