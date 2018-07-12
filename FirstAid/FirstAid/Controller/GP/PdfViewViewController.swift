//
//  PdfViewViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 25/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PdfViewViewController: UIViewController {

    @IBOutlet weak var patientCode: UILabel!
    @IBOutlet weak var doctorName: UILabel!
    @IBOutlet weak var appointmentLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
