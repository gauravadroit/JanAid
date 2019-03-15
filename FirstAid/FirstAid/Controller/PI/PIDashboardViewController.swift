//
//  PIDashboardViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 08/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import NVActivityIndicatorView
import Toast_Swift

class PIDashboardViewController: ButtonBarPagerTabStripViewController {

    @IBOutlet weak var schedulePopUpView: UIView!
    @IBOutlet weak var registrationText: UITextField!
    @IBOutlet weak var uhidText: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    let blueInstagramColor = UIColor.black
    var value:[String:String]!
    override func viewDidLoad() {
        
        GPAdvice.date = getDate1()
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
            // oldCell?.label.textColor = UIColor(red: 146/255.0, green: 147/255.0, blue: 156/255.0, alpha: 0.8)
            oldCell?.label.textColor = UIColor(red: 163.0/255.0, green: 163.0/255.0, blue: 163.0/255.0, alpha: 1.0)
            newCell?.label.textColor = self?.blueInstagramColor
        }
        
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.popUpView.isHidden = true
        self.backView.isHidden = true
        self.schedulePopUpView.isHidden = true
        self.dateLabel.text = getDate()
        
        dateText.addTarget(self, action: #selector(self.datepicker(_:)), for: .editingDidBegin)
        timeText.addTarget(self, action: #selector(self.datepicker(_:)), for: .editingDidBegin)
        popUpView.layer.cornerRadius = 5
        schedulePopUpView.layer.cornerRadius = 5
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.PIStatusAction(notification:)), name: NSNotification.Name(rawValue: "PINewStatus"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil, userInfo: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }
    
    
    @objc func PIStatusAction(notification:NSNotification) {
        value = notification.userInfo as! [String:String]
        
        if value["callStatus"] == "Scheduled" {
            self.backView.isHidden = false
            self.schedulePopUpView.isHidden = false
        }else if value["callStatus"] == "New" {
            self.backView.isHidden = false
            self.popUpView.isHidden = false
        }
        
        print(value)
    }
    
    @IBAction func backAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: -1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        GPAdvice.date = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil, userInfo: nil)
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MM/dd/yyyy"
        let today = formatter.date(from:  self.dateLabel.text!)
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today!)
        self.dateLabel.text! = formatter.string(from: tomorrow!)
        GPAdvice.date = formatter1.string(from: tomorrow!)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil, userInfo: nil)
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
        
        let childOneVC = storyboard?.instantiateViewController(withIdentifier: "PIPatientAllViewController")
        let childTwoVC = storyboard?.instantiateViewController(withIdentifier: "PIPatientNewViewController")
        let childThreeVC = storyboard?.instantiateViewController(withIdentifier: "PIPatientAcknowledgeViewController")
        let childFourVC = storyboard?.instantiateViewController(withIdentifier: "PIPatientCompleteViewController")
        
        return [childOneVC!, childTwoVC! , childThreeVC!, childFourVC!]
    }
   
    
    
    @IBAction func datepicker(_ sender: UITextField) {
        let datePickerView = UIDatePicker()
        sender.inputView = datePickerView
        if sender == dateText {
            datePickerView.datePickerMode = .date
            datePickerView.minimumDate = Date()
            datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        }else{
            datePickerView.datePickerMode = .time
            datePickerView.addTarget(self, action: #selector(handleTimePicker(sender:)), for: .valueChanged)
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateText.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func handleTimePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        timeText.text = dateFormatter.string(from: sender.date)
    }

    @IBAction func cancelBtn(_ sender: UIButton) {
        self.popUpView.isHidden = true
        self.backView.isHidden = true
        self.schedulePopUpView.isHidden = true
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if dateText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill date.")
            return
        }
        
        if timeText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill time.")
            return
        }
        
        let parameter:[String:String] = [
            "FlagNo":"1",
            "CallID":value["callId"]!,
            "CallStatus":"AK",
            "UserID":PIUser.UserId,
            "DoctorAssignedDate":dateText.text!,
            "Age":timeText.text!,
            "Description":"Scheduled"
        ]
        print(parameter)
        
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIpatientStatus, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.popUpView.isHidden = true
                self.backView.isHidden = true
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil, userInfo: nil)
            }
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    
    @IBAction func scheduleSubmitAction(_ sender: UIButton) {
        self.view.endEditing(true)
        
        if registrationText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill registration number.")
            return
        }
        
        if uhidText.text! == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill UHID.")
            return
        }
        
        let parameter:[String:String] = [
            "FlagNo":"2",
            "CallID":value["callId"]!,
            "CallStatus":"VC",
            "UserID":PIUser.UserId,
            "hstStatus":registrationText.text!,
            "HospitalName":uhidText.text!,
            "Description":"Completed"
        ]
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.PIpatientStatus, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Message"].stringValue == "Success" {
                self.schedulePopUpView.isHidden = true
                self.backView.isHidden = true
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PIPatientdate"), object: nil, userInfo: nil)
            }
            
        }) { (error) in
            ShowLoader.stopLoader()
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
