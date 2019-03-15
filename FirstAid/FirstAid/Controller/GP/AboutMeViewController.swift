//
//  AboutMeViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 29/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AboutMeViewController: UIViewController {

    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var aboutmeText: UITextView!
    var aboutme:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Edit Profile"
        self.tabBarController?.tabBar.isHidden = true
        
        updateBtn.layer.cornerRadius = 5
        aboutmeText.layer.cornerRadius = 5
        aboutmeText.layer.borderWidth = 1
        aboutmeText.text = aboutme
        updateBtn.addTarget(self, action: #selector(self.UpdateAboutMe(sender:)), for: .touchUpInside)
        aboutmeText.delegate = self
    }
    
    @objc func UpdateAboutMe(sender:UIButton) {
        
        if aboutmeText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter some details.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId,
            "AboutMe":aboutmeText.text!
        ]
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.GPUpdateAboutMe, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                
                 UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
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


extension AboutMeViewController:UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text?.count)! < 500 {
            return true
        }else{
            return false
        }
    }
}
