

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
import SDWebImage
import Crashlytics
import Firebase
import FMDB

class DashboardViewController: UIViewController {

   
    @IBOutlet weak var ambulanceBtn: UIButton!
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var helloView: UIView!
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var sectionInsets2 =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    let itemsPerRow:CGFloat = 2
    var isNewReport:String!
    var reportCount:String!
    var blackView:UIView!
    var promoId:String!
    
   
    @IBOutlet weak var locationBtn: UIButton!
    
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    var menuArr = ["","Online Consultation","Hospitals","Labs & Diagnostics","Dental Services","Reports","Other Services"]
    var menuImageArr:[String] = ["","onlineconsult","Hospital","Lab","Dentist","labReport","OtherService"]
    
    
    @IBOutlet weak var otpText: UITextField!
     @IBOutlet weak var cancelAction: UIButton!
    
    var isBanner:Bool = false
    var bannerPathDic:[[String:String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        
       User.valiedEmail = User.emailId
       
       // let imageView = UIImageView(image:#imageLiteral(resourceName: "navigationLogo"))
       // self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.isHidden = true
        
        otpView.dropShawdow()
        
        
        otpView.layer.cornerRadius = 5
        otpView.isHidden = true
        
        
        callBtn.layer.cornerRadius = callBtn.frame.size.height/2
        let icon = #imageLiteral(resourceName: "phonecall").withRenderingMode(.alwaysTemplate)
        callBtn.setImage(icon, for: .normal)
        callBtn.tintColor = UIColor.white
        
        
        if User.firstName != nil {
        userNameLabel.text = User.firstName.capitalizingFirstLetter() + " " + User.lastName.capitalizingFirstLetter()
    
        callBtn.addTarget(self, action: #selector(self.callAdoctorAction(sender:)), for: .touchUpInside)
        self.collectionView.register(BannerSliderCell.self, forCellWithReuseIdentifier: "BannerSliderCell")
        self.setBadges()
        self.wishAction()
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.tabBadgeAction(notification:)), name: NSNotification.Name(rawValue: "tabBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callTabBadgeAction(notification:)), name: NSNotification.Name(rawValue: "callTabBadge"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appointmentTabBadgeAction(notification:)), name: NSNotification.Name(rawValue: "appointmentTabBadge"), object: nil)
       
        self.getOffLineData()
        
    }
    
    
    
    func getOffLineData(){
        let databasePath = UserDefaults.standard.url(forKey: "DataBasePath")!
        let contactDB = FMDatabase(path: String(describing: databasePath))
        
        if (contactDB.open()) {
            let querySQL = "SELECT * FROM Pharmacy "
            let results:FMResultSet? = contactDB.executeQuery(querySQL, withArgumentsIn: [""])
            
            while((results?.next()) == true){
                let parameter:[String:String] = [
                    "PatientID":results!.string(forColumn: "PatientID")!,
                    "OrderID":results!.string(forColumn: "OrderID")!,
                    "OrderDate":results!.string(forColumn: "OrderDate")!,
                    "OrderStatus_1mg":results!.string(forColumn: "OrderStatus_1mg")!,
                    "TotalAmount":results!.string(forColumn: "TotalAmount")!,
                    "DiscountAmount":results!.string(forColumn: "DiscountAmount")!,
                    "ActualAmount":results!.string(forColumn: "ActualAmount")!,
                    "ShippingAmount":results!.string(forColumn: "ShippingAmount")!
                ]
                print(parameter)
                
              self.saveMedicineOrderId(parameter: parameter)
            }
                
            contactDB.close()
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    func deleteDataFromSqlite(orderID:String) {
        let databasePath = UserDefaults.standard.url(forKey: "DataBasePath")!
        let contactDB = FMDatabase(path: String(describing: databasePath))
        
        if (contactDB.open()) {
            let insertSQL = "DELETE FROM Pharmacy where OrderID = '\(orderID)'"
            let result = contactDB.executeStatements(insertSQL)
            if !result {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    func saveMedicineOrderId(parameter:[String:String]) {
    
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MgOrder, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Message"].stringValue == "Success" {
                self.deleteDataFromSqlite(orderID: parameter["OrderID"]!)
            }
            
        }) { (error) in
            print(error)
        }
        
    }
    
    @objc func tabBadgeAction(notification:NSNotification) {
    
        var count = 0
        if let temp = UserDefaults.standard.string(forKey: "tabBadge") {
            count = Int(temp)!
        }
        count = count + 1
        UserDefaults.standard.setValue(count, forKey: "tabBadge")
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[2] as! UITabBarItem
            tabItem.badgeValue = String(count)
        }
    }
    
    @objc func callTabBadgeAction(notification:NSNotification) {
        
        var count = 0
        if let temp = UserDefaults.standard.string(forKey: "callTabBadge") {
            count = Int(temp)!
        }
        count = count + 1
        UserDefaults.standard.setValue(count, forKey: "callTabBadge")
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[3] as! UITabBarItem
            tabItem.badgeValue = String(count)
        }
    }
    
    @objc func appointmentTabBadgeAction(notification:NSNotification) {
        
        var count = 0
        if let temp = UserDefaults.standard.string(forKey: "appointmentTabBadge") {
            count = Int(temp)!
        }
        count = count + 1
        UserDefaults.standard.setValue(count, forKey: "appointmentTabBadge")
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray?
        {
            let tabItem = tabItems[1] as! UITabBarItem
            tabItem.badgeValue = String(count)
        }
    }
    
    func setBadges(){
        var count1 = 0
        if let temp = UserDefaults.standard.string(forKey: "tabBadge") {
            count1 = Int(temp)!
        }
        if count1 != 0 {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = tabItems[2] as! UITabBarItem
                tabItem.badgeValue = String(count1)
            }
            
        }
        
        var count2 = 0
        if let temp = UserDefaults.standard.string(forKey: "callTabBadge") {
            count2 = Int(temp)!
        }
        
        if count2 != 0 {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = tabItems[3] as! UITabBarItem
                tabItem.badgeValue = String(count2)
            }
        }
        
        var count3 = 0
        if let temp = UserDefaults.standard.string(forKey: "appointmentTabBadge") {
            count3 = Int(temp)!
        }
        
        if count3 != 0 {
            if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = tabItems[1] as! UITabBarItem
                tabItem.badgeValue = String(count3)
            }
        }
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if User.patientId != nil {
            self.getOffer()
        }
        self.navigationController?.navigationBar.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
        if let temp = UserDefaults.standard.string(forKey: "location") {
            print(temp)
            User.location = temp
            
            locationBtn.setTitle(temp, for: .normal)
        }else{
            User.location = "Gurgaon"
        }
    }
    
   
    
    func getOffer() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getOffer + User.patientId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.bannerPathDic = []
            if json["Status"].stringValue == "true" {
                if json["Data"]["DashboardData"][0]["IsMember"].stringValue == "True" {
                    self.isBanner = true
                    //self.bannerPath.append(json["Data"][0]["BannerImage375X100"].stringValue)
                    
                    for data in json["Data"]["Banner375"].arrayValue {
                        let bannerData:[String:String] = [
                            "bannerUrl":data["BannerURL"].stringValue,
                            "text":data["Text"].stringValue,
                            "code":data["Code"].stringValue
                        ]
                        self.bannerPathDic.append(bannerData)
                    }
                    
                }
            }
            
           // self.bannerPath.append(json["Data"][0]["FirstConsultationBanner375"].stringValue)
           // self.bannerPath.append(json["Data"][0]["HealthCheckUpOfferBenner375"].stringValue)
            
            User.isFreeConsultationApplicable = json["Data"][0]["IsFreeConsultationApplicable"].stringValue
            User.UsedPromoID =  json["Data"]["DashboardData"][0]["AppliedPromoID"].stringValue
            self.isNewReport = json["Data"]["DashboardData"][0]["IsNewReport"].stringValue
            self.reportCount = json["Data"]["DashboardData"][0]["NewReportCount"].stringValue
            User.valiedEmail = json["Data"]["DashboardData"][0]["EmailID"].stringValue
            
            if self.isNewReport == "true" {
                if let tabItems = self.tabBarController?.tabBar.items as NSArray?
                {
                    let tabItem = tabItems[3] as! UITabBarItem
                    tabItem.badgeValue = self.reportCount 
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reportCount"), object: nil, userInfo: ["count":self.reportCount])
            }
            
            
            self.collectionView.reloadData()
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
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
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.verifyToken, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
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
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
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
        
         
        ShowLoader.startLoader(view: self.view)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGpharmacyToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMgPharmacy = "true"
                User.oneMGAuthenticationToken = token
                
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgPharmacy")
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
   
    @IBAction func ambulanceAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        let nextView = storyboard.instantiateViewController(withIdentifier: "AmbulanceViewController") as! AmbulanceViewController
       
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
         otpView.isHidden = true
    }
    
    @IBAction func menuAction(_ sender: UIButton) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func callAdoctorAction(sender:UIButton) {
        if let url = URL(string: "tel://\(Webservice.callCenter)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
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
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpWith1MG, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
             
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
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
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
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.loginWithOTP, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "success" {
                self.otpView.isHidden = false
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
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
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.renewToken1MG, dataDict: parameter, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["authentication_token"].stringValue != "" {
                User.oneMGAuthenticationToken = "a7462030-5461-44c7-8ed6-d5b8f0a8d219"
                //json["authentication_token"].stringValue
            } else if json["errors"][0]["message"].stringValue == "User already exists" {
                print("hello")
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
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

extension DashboardViewController:BannerDelegate {
    func BannerAction(type: String) {
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SpecialityListViewController") as! SpecialityListViewController
        self.navigationController?.pushViewController(nextView, animated: true)*/
        
        self.tabBarController?.tabBar.isHidden = true
        //self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        
        if type == "applyCoupon" {
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "ApplyCouponViewController") as! ApplyCouponViewController
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if type == "UOCN" {
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "UnlimitedConsultationViewController") as! UnlimitedConsultationViewController
            nextView.index = 0
            nextView.titleStr = "Unlimited online consultation"
            self.navigationController?.pushViewController(nextView, animated: true)
            
        }else if type == "FHCK" {
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "UnlimitedConsultationViewController") as! UnlimitedConsultationViewController
            nextView.index = 1
            nextView.titleStr = "Free health check up"
            self.navigationController?.pushViewController(nextView, animated: true)
            
        }
    }
}

extension DashboardViewController:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.menuArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            if indexPath.row == 0 {
               
                    
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerSliderCell2", for: indexPath) as! BannerSliderCell2
                    cell.delegate = self
                cell.loadCollectionView(height: 100.0
                    
                    
                    /*self.collectionView.bounds.size.height/4 - 36.0*/, pathDic: bannerPathDic)
                    
                    return cell
               
            
            }else{
            
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DashboardCell", for: indexPath) as! DashboardCell
                cell.menuLabel.text = menuArr[indexPath.row]
                cell.menuImage.image = UIImage(named: menuImageArr[indexPath.row])
                
                if indexPath.row == 5 {
                    if isNewReport == "true" {
                        cell.badgeLabel.text = reportCount
                        cell.badgeLabel.backgroundColor = UIColor.red
                        cell.badgeLabel.textColor = UIColor.white
                        cell.badgeLabel.layer.cornerRadius = cell.badgeLabel.frame.size.height/2
                        cell.badgeLabel.layer.masksToBounds = true
                    }
                }else{
                    cell.badgeLabel.text = ""
                    cell.badgeLabel.backgroundColor = UIColor.white
                }
                
                return cell
            }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        
        if indexPath.row == 0 {
            if isBanner == true {
                 
                return CGSize(width: UIScreen.main.bounds.width - 20.0 , height: 100 /*self.collectionView.bounds.size.height/4 - 36*/)
               
            }else{
                let availableWidth = view.frame.width - 20.0
                return CGSize(width: availableWidth , height: 40.0)
            }
        }else{
            let paddingSpace = (10 ) * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem , height: self.collectionView.bounds.size.height/4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
       
        
         return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
       
        otpView.layer.cornerRadius = 5
        
        if indexPath.row == 0 {
           /* self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "SpecialityListViewController") as! SpecialityListViewController
            self.navigationController?.pushViewController(nextView, animated: true)*/
            
            
        }else if indexPath.row == 1 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
            let nextView = storyboard.instantiateViewController(withIdentifier: "SpecialityListViewController") as! SpecialityListViewController
           
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 2 {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "HospitalsViewController") as! HospitalsViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 3 {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "LabsViewController") as! LabsViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 4 {
            
           /* if User.oneMgPharmacy == "false" {
                self.signUpWith1MG()
                return
            }
            self.tabBarController?.tabBar.isHidden = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
           
            let nextView = storyboard.instantiateViewController(withIdentifier: "SearchMedicineViewController") as! SearchMedicineViewController*/
            
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
            self.navigationController?.navigationBar.isHidden = false
            self.tabBarController?.tabBar.isHidden = true
            let nextView = storyboard.instantiateViewController(withIdentifier: "DentalZoneViewController") as! DentalZoneViewController
            
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 5 {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "LabMyOrderViewController") as! LabMyOrderViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }else if indexPath.row == 6 {
            self.tabBarController?.tabBar.isHidden = true
            self.navigationController?.navigationBar.isHidden = false
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "OtherServicesViewController") as! OtherServicesViewController
                self.navigationController?.pushViewController(nextView, animated: true)
            }
        
    }
    
    
    
}
