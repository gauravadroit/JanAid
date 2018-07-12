//
//  PIAppointmentViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 08/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class PIAppointmentViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var dateLabel: UILabel!
    
    let blueInstagramColor = UIColor.black
    override func viewDidLoad() {
        PIUser.appointmentDate = getDate1()
        settings.style.buttonBarBackgroundColor = .clear
        settings.style.buttonBarItemBackgroundColor = .clear
        // settings.style.selectedBarBackgroundColor = UIColor(red: 0.0/255.0, green: 182.0/255.0, blue: 223.0/255.0, alpha: 1.0)
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
            // oldCell?.label.textColor = UIColor(red: 146/255.0, green: 147/255.0, blue: 156/255.0, alpha: 0.8)
            oldCell?.label.textColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            newCell?.label.textColor = self?.blueInstagramColor
        }
        
        super.viewDidLoad()
        self.dateLabel.text = getDate()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIAppointmentdate"), object: nil, userInfo: nil)
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        PIUser.appointmentDate = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIAppointmentdate"), object: nil, userInfo: nil)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        PIUser.appointmentDate = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIAppointmentdate"), object: nil, userInfo: nil)
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    func getDate1() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from: date)
    }
    
    override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        
        let childOneVC = storyboard?.instantiateViewController(withIdentifier: "PIAppointmentAllViewController")
        let childTwoVC = storyboard?.instantiateViewController(withIdentifier: "PIAppointmentBookedViewController")
        let childThreeVC = storyboard?.instantiateViewController(withIdentifier: "PIAppointmentConfirmViewController")
        let childFourVC = storyboard?.instantiateViewController(withIdentifier: "PIAppointmentCompleteViewController")
        
        return [childOneVC!, childTwoVC! , childThreeVC!, childFourVC!]
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
