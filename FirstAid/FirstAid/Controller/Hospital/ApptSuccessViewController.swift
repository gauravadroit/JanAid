//
//  ApptSuccessViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class ApptSuccessViewController: UIViewController {
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var apptBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homeBtn.layer.cornerRadius = 5
        self.apptBtn.layer.cornerRadius = 5
        self.navigationItem.setHidesBackButton(true, animated:false)
        self.title = "Appointment booked"
    }

    @IBAction func homeAction(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func apptAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MyApptViewController") as! MyApptViewController
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
