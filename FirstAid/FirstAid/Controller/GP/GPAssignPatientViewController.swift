//
//  GPAssignPatientViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GPAssignPatientViewController: ButtonBarPagerTabStripViewController {

    let blueInstagramColor = UIColor.black
    var callId:String!
    
    
    override func viewDidLoad() {
        
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        
        settings.style.selectedBarBackgroundColor = UIColor(red: 127.0/255.0, green: 205.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        
        settings.style.buttonBarItemFont = UIFont(name: "Helvetica", size: 16)!
        
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor(red: 146/255.0, green: 147/255.0, blue: 156/255.0, alpha: 0.8)
        
        settings.style.buttonBarItemTitleColor =  UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            newCell?.label.textColor = self?.blueInstagramColor
            
        }
        
        super.viewDidLoad()
        self.title = "Assign Hospital"

        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
    }
    
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let childOneVC = storyboard?.instantiateViewController(withIdentifier: "PatientAdviceViewController")
        let childTwoVC = storyboard?.instantiateViewController(withIdentifier: "GPReferViewController")
        
        
        return [childOneVC!, childTwoVC!]
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
