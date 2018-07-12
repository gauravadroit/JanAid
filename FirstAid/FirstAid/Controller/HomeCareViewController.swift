//
//  HomeCareViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class HomeCareViewController: UIViewController {
    
    var fromSideMenu = "false"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home Care Services"
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
       
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
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
