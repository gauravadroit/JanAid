//
//  FeatureLabsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class FeatureLabsViewController: UIViewController {

    var labId:String!
    override func viewDidLoad() {
        super.viewDidLoad()

       self.getLabInfo()
    }

    
    func getLabInfo() {
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getLabInfo + "\(labId!)/tests", headers: headers, { (json) in
            print(json)
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
