

//
//  DashboardViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift
import SwiftyJSON

class DashboardViewController: UIViewController {

    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var helloView: UIView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let itemsPerRow:CGFloat = 2
    
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    var menuArr = ["Hospitals","Labs & Diagnostics","Medicines","Ambulance","Home Care Services","Other Services"]
    var menuImageArr:[String] = ["Hospital","Lab","Medicine","Ambulance","HomeCare","OtherService"]
    
    @IBOutlet weak var locationBtn: UIBarButtonItem!
    @IBOutlet weak var otpText: UITextField!
     @IBOutlet weak var cancelAction: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.title = "Home"
        let imageView = UIImageView(image:#imageLiteral(resourceName: "navigationLogo"))
        self.navigationItem.titleView = imageView
        
        otpView.dropShawdow()
        otpView.layer.cornerRadius = 5
        otpView.isHidden = true
        
        
        callBtn.layer.cornerRadius = callBtn.frame.size.height/2
        let icon = #imageLiteral(resourceName: "call").withRenderingMode(.alwaysTemplate)
        callBtn.setImage(icon, for: .normal)
        callBtn.tintColor = UIColor.white
        
        helloView.layer.cornerRadius = 5
        if User.firstName != nil {
        userNameLabel.text = User.firstName.capitalizingFirstLetter() + " " + User.lastName.capitalizingFirstLetter()
       // helloView.layer.borderWidth = 1
       // helloView.layer.borderColor = UIColor.lightGray.cgColor
        callBtn.addTarget(self, action: #selector(self.callAdoctorAction(sender:)), for: .touchUpInside)
        
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
        }
        self.wishAction()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if let temp = UserDefaults.standard.string(forKey: "location") {
            print(temp)
            User.location = temp
            locationBtn.title = temp
        }else{
            User.location = "Gurgaon"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = true
    }
    
    func wishAction() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 6..<12 : self.helloLabel.text = "Good Morning"
        case 12 : self.helloLabel.text = "Good Afternoon"
        case 13..<15 : self.helloLabel.text = "Good Afternoon"
        case 15..<22 : self.helloLabel.text = "Good Evening"
        default: self.helloLabel.text = "Good Evening"
        }
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if otpText.text!  == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter OTP.")
            return
        }
        
        if otpText.text!.count  != 6 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "OTP should be 6 digits.")
            return
        }
        
        let parameter:[String:String] = [
            "verification_token": otpText.text!,
            "password": "patient@" + User.patientId,
            "username": User.mobileNumber,
            "return_token":"true"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.verifyToken, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }else  if json["status"].stringValue == "0" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                self.otpView.isHidden = true
                User.oneMGAuthenticationToken = json["result"]["authToken"].stringValue
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
                self.register1MGPrarmacyToken(token: User.oneMGAuthenticationToken)
            }
            
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
    func register1MGPrarmacyToken(token:String) {
        let parameter:[String:String] = [
            "Value1":User.patientId,
            "Value2":token
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGpharmacyToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMgPharmacy = "true"
                User.oneMGAuthenticationToken = token
                
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgPharmacy")
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
   
    
    @IBAction func cancelAction(_ sender: UIButton) {
         otpView.isHidden = true
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func locationAction(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func callAdoctorAction(sender:UIButton) {
        
        if let url = URL(string: "tel://18002585677"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
      /* /* User.isMFI = "false"
        if User.isMFI == "true"{
            if let url = URL(string: "tel://18002585677"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else{*/
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "CallServiceViewController") as! CallServiceViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        //}*/
    }
    
    
    func signUpWith1MG(){
       // User.oneMGAuthenticationToken = "a7462030-5461-44c7-8ed6-d5b8f0a8d219"
        let parameter:[String:String] = [
            "email": User.emailId,
            "name": User.firstName + " " + User.lastName,
            "password": "patient@" + User.patientId,
            "phone_number": User.mobileNumber,
            "cart_oos":"true"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpWith1MG, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            /*if json["authentication_token"].stringValue != "" {
                User.oneMGAuthenticationToken = "a7462030-5461-44c7-8ed6-d5b8f0a8d219"
                //json["authentication_token"].stringValue
            } else if json["errors"][0]["message"].stringValue == "User already exists" {
                self.getNew1MGToken()
            }*/
            
            if json["status"].stringValue == "success" {
                 self.otpView.isHidden = false
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
                if json["errors"]["errs"][0]["msg"].stringValue.contains("already registered") {
                    self.loginWithOTP()
                }
            }
            
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
    func loginWithOTP()  {
        let parameter:[String:String] = [
            "username": User.mobileNumber
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.loginWithOTP, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["status"].stringValue == "success" {
                self.otpView.isHidden = false
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
    
    func getNew1MGToken(){
        let parameter = [
            "api_key":"pansonic123",
            "user_id":"gaurav.saini@mailinator.com"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.renewToken1MG, dataDict: parameter, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["authentication_token"].stringValue != "" {
                User.oneMGAuthenticationToken = "a7462030-5461-44c7-8ed6-d5b8f0a8d219"
                //json["authentication_token"].stringValue
            } else if json["errors"][0]["message"].stringValue == "User already exists" {
                print("hello")
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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

extension DashboardViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: indexPath) as! DashboardCell
        cell.menuLabel.text = menuArr[indexPath.row]
        cell.menuImage.image = UIImage(named: menuImageArr[indexPath.row]) 
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (10 ) * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        var heightPerItem:CGFloat!
        /*let heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)!)/4) - 5
        
        let heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4*/
        
        if UIDevice.current.modelName == "iPhone X" {
            heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4
        }else{
            heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 120)/4)
        }
        
        return CGSize(width: widthPerItem , height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == 0 {
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "HospitalsViewController") as! HospitalsViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 1 {
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "LabsViewController") as! LabsViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 2 {
            
            if User.oneMgPharmacy == "false" {
                self.signUpWith1MG()
                return
            }
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           // let nextView = storyboard.instantiateViewController(withIdentifier: "MedicineViewController") as! MedicineViewController
            let nextView = storyboard.instantiateViewController(withIdentifier: "SearchMedicineViewController") as! SearchMedicineViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 3 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.tabBarController?.tabBar.isHidden = true
            let nextView = storyboard.instantiateViewController(withIdentifier: "AmbulanceViewController") as! AmbulanceViewController
           // let nextView = storyboard.instantiateViewController(withIdentifier: "MyApptViewController") as! MyApptViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 4 {
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "HomeCareViewController") as! HomeCareViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 5 {
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "OtherServicesViewController") as! OtherServicesViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    
}
