//
//  CallServiceViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 29/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class CallServiceViewController: UIViewController {

    @IBOutlet weak var specialityBtn: UIButton!
    @IBOutlet weak var gernalPhysicanBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.title = "Doctor Advisior"
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        gernalPhysicanBtn.layer.cornerRadius = 5
        specialityBtn.layer.cornerRadius = 5
    }

   
    @IBAction func gernalPhysicanAction(_ sender: UIButton) {
        
        if let url = URL(string: "tel://\(Webservice.callCenter)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
       
    }
    
    @IBAction func specialityBtnAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "ShowSpecialityViewController") as! ShowSpecialityViewController
        self.navigationController?.pushViewController(nextView, animated: true)
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
