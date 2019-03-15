//
//  PINotificationViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PINotificationViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notification"
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as!
        NotificationViewController
        
        controller.parameter = ["FlagNo": 1,"UserID": PIUser.UserId!,"UserType": "PI"]
        
        
        addChildViewController(controller)
        controller.view.frame = self.view.bounds
        self.view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
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
