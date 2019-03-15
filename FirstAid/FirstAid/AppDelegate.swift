//
//  AppDelegate.swift
//  FirstAid
//
//  Created by Adroit MAC on 07/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import UserNotifications
import FBSDKCoreKit
import Firebase
import Crashlytics
import FMDB
import GoogleSignIn

//com.panasonic.janaid live
//com.pacific.JanAid test
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, GIDSignInDelegate {

    var window: UIWindow?
   
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        UINavigationBar.appearance().barTintColor = Webservice.themeColor
        UINavigationBar.appearance().tintColor = UIColor.white
       
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
       
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 12)!],for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 12)!],for: .selected)
        UITabBar.appearance().tintColor = UIColor.white
        
        self.createDatabase()
        
        //Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Google analytics
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        GIDSignIn.sharedInstance().clientID = "738065685123-p8vhjr8d9c58hpujbcl2k1gq10620tso.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GMSServices.provideAPIKey(Webservice.googleMap)
        
        
        registerForPushNotifications(application)
        
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self 
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in

            print(granted)
            print(error)
            // Enable or disable features based on authorization.
            if granted {
                // update application settings
            }
        }
        
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
            UIApplication.shared.applicationIconBadgeNumber = 0
            let aps = notification["aps"] as! [String: AnyObject]
            var userType:String = ""
            if let temp  = UserDefaults.standard.string(forKey: "UserType") {
                    userType = temp
            }
            
            if userType == "Patient" {
                if (aps["NotificationType"] as! String).uppercased() == "Consultation".uppercased() &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 2)
                }else if aps["NotificationType"] as! String == "Call" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 3)
                }else if aps["NotificationType"] as! String == "Appointment" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }else if aps["NotificationType"] as! String == "HealthPackage" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 0)
                }else if aps["NotificationType"] as! String == "DoctorAssigned" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 2)
                }
            }else if userType == "GP" {
                if aps["NotificationType"] as! String == "JOB" &&  aps["UserType"] as! String == "GP" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }else  if aps["NotificationType"] as! String == "JOBASSIGNED" &&  aps["UserType"] as! String == "GP" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }
            }
            
        }else{
            self.checkAlreadyLogin(selectedIndex: 0)
        }
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url as URL?,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            
            
            
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name!
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email!
        
            // ...
            print(fullName, givenName, familyName, email)
            
            let dataDict:[String:String] =  [
                "first_name": givenName!,
                "last_name": familyName!,
                "email": email,
                "username": givenName!,
                "socialid": userId!
            ]
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "googleSignIn"), object: nil, userInfo: dataDict)
            
            // ...
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }
    
   /* func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        var signedIn: Bool = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        
        signedIn = signedIn ? signedIn : FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return signedIn
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        var signedIn: Bool = GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        signedIn = signedIn ? signedIn : FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: nil)
        
        return signedIn
    }*/
    
    /*func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
        return handled
    }*/
    
    func checkAlreadyLogin(selectedIndex:Int) {
        
        var Login:String = ""
        if let temp  = UserDefaults.standard.string(forKey: "login") {
            Login = temp
        }
        
        if Login == "yes" {
            if let temp  = UserDefaults.standard.string(forKey: "UserType") {
                if temp == "GP" {
                    self.GPLogin(selectedIndex: selectedIndex)
                }else if temp == "Patient" {
                    self.patientLogin(selectedIndex: selectedIndex)
                }else if temp == "PI" {
                    self.PILogin()
                }
            }
        }else{
            //let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
           /* let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PatientLoginViewController") as! PatientLoginViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = firstController*/
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PatientLoginViewController") as! PatientLoginViewController
            let navigationController = UINavigationController(rootViewController: nextViewController)
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            appdelegate.window!.rootViewController = navigationController
            
        }
    }
    
    
    func PILogin() {
        
        if let temp = UserDefaults.standard.string(forKey: "PIName") {
            PIUser.name = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "PIKey") {
            PIUser.merchantKey = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "PIUserId") {
            PIUser.UserId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "PIDescription") {
            PIUser.descr = temp
        }
        
        DispatchQueue.main.async() {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "PI", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "PITabBarcontroller") as! UITabBarController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    
    func GPLogin(selectedIndex:Int = 0) {
        if let temp = UserDefaults.standard.string(forKey: "GPName") {
            GPUser.name = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "GPKey") {
            GPUser.merchantKey = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "GPUserId") {
            GPUser.UserId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "GPDescription") {
            GPUser.descr = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "GPActive") {
            GPUser.active = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "MemberID") {
            GPUser.memberId = temp
        }
        
        DispatchQueue.main.async() {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "GP", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
            viewController.selectedIndex = selectedIndex
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    
    
    func patientLogin(selectedIndex:Int) {
        
        if let temp = UserDefaults.standard.string(forKey: "firstName") {
            User.firstName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "lastName") {
            User.lastName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "motherName") {
            User.motherName = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "MobileNumber") {
            User.mobileNumber = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "patientId") {
            User.patientId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "genderId") {
            User.genderId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "speciality") {
            User.speciality = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "specialityId") {
            User.specialityId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "email") {
            User.emailId = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "ISRegisteredOn1mgLAB") {
            User.oneMGLab = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "oneMGLabToken") {
            User.oneMGLabToken = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "oneMGAuthenticationToken") {
            User.oneMGAuthenticationToken = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "ISRegisteredOn1mgPharmacy") {
            User.oneMgPharmacy = temp
        }
        
        if let temp = UserDefaults.standard.string(forKey: "isMFI") {
            User.isMFI = temp
        }
        
        
        DispatchQueue.main.async() {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil) as UIStoryboard
            let mfSideMenuContainer = storyBoard.instantiateViewController(withIdentifier: "MFSideMenuContainerViewController") as! MFSideMenuContainerViewController
            let dashboard = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            dashboard.selectedIndex = selectedIndex
            let leftSideMenuController = storyBoard.instantiateViewController(withIdentifier: "SideMenuViewController") as! SideMenuViewController
            mfSideMenuContainer.leftMenuViewController = leftSideMenuController
            mfSideMenuContainer.centerViewController = dashboard
            let appDelegate  = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mfSideMenuContainer
            
        }
        
    }
    
    
    
    
    func registerForPushNotifications(_ application: UIApplication) {
        
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){ (granted, error) in }
            application.registerForRemoteNotifications()
        }else  {
            // iOS 9 support
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
        
    }
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != UIUserNotificationType() {
            application.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        UserDefaults.standard.setValue(tokenString, forKey: "deviceToken")
        UserDefaults.standard.synchronize()
       
        print("deviceToken \(tokenString)")
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("he1")
        print(notification.request.content.userInfo)
        completionHandler([.badge, .sound, .alert])
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
    
        let aps = response.notification.request.content.userInfo["aps"] as! [String: AnyObject]
        var userType:String = ""
        if let temp  = UserDefaults.standard.string(forKey: "UserType") {
            userType = temp
        }
        
        if userType == "Patient" {
            if (aps["NotificationType"] as! String).uppercased() == "Consultation".uppercased() &&  aps["UserType"] as! String == "PT" {
                self.checkAlreadyLogin(selectedIndex: 2)
            }else  if aps["NotificationType"] as! String == "Call" &&  aps["UserType"] as! String == "PT" {
                self.checkAlreadyLogin(selectedIndex: 3)
            }else if aps["NotificationType"] as! String == "Appointment" &&  aps["UserType"] as! String == "PT" {
                self.checkAlreadyLogin(selectedIndex: 1)
            }else if aps["NotificationType"] as! String == "HealthPackage" &&  aps["UserType"] as! String == "PT" {
                self.checkAlreadyLogin(selectedIndex: 0)
            }else if aps["NotificationType"] as! String == "DoctorAssigned" &&  aps["UserType"] as! String == "PT" {
                self.checkAlreadyLogin(selectedIndex: 2)
            }
        }else if userType == "GP" {
            if aps["NotificationType"] as! String == "JOB" &&  aps["UserType"] as! String == "GP" {
                self.checkAlreadyLogin(selectedIndex: 1)
            }else  if aps["NotificationType"] as! String == "JOBASSIGNED" &&  aps["UserType"] as! String == "GP" {
                self.checkAlreadyLogin(selectedIndex: 1)
            }
        }
        completionHandler()
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        
        let state: UIApplicationState = UIApplication.shared.applicationState
         let aps = userInfo["aps"] as! [String: AnyObject]
        
        var userType:String = ""
        if let temp  = UserDefaults.standard.string(forKey: "UserType") {
            userType = temp
        }
        
        if userType == "Patient" {
    
            if state == .active {
                if (aps["NotificationType"] as! String).uppercased() == "Consultation".uppercased() &&  aps["UserType"] as! String == "PT" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabBadge"), object: nil, userInfo: nil)
                }else if aps["NotificationType"] as! String == "Call" &&  aps["UserType"] as! String == "PT" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "callTabBadge"), object: nil, userInfo: nil)
                }else if aps["NotificationType"] as! String == "Appointment" &&  aps["UserType"] as! String == "PT" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "appointmentTabBadge"), object: nil, userInfo: nil)
                }else if aps["NotificationType"] as! String == "HealthPackage" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 0)
                }else if aps["NotificationType"] as! String == "DoctorAssigned" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 2)
                }
            }else if state == .inactive {
                if (aps["NotificationType"] as! String).uppercased() == "Consultation".uppercased() &&  aps["UserType"] as! String == "PT" {
                     self.checkAlreadyLogin(selectedIndex: 2)
                }else  if aps["NotificationType"] as! String == "Call" &&  aps["UserType"] as! String == "PT" {
                     self.checkAlreadyLogin(selectedIndex: 3)
                }else if aps["NotificationType"] as! String == "Appointment" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }else if aps["NotificationType"] as! String == "DoctorAssigned" &&  aps["UserType"] as! String == "PT" {
                    self.checkAlreadyLogin(selectedIndex: 2)
                }
            }
        }else if userType == "GP" {
            if state == .active {
                if aps["NotificationType"] as! String == "JOB" &&  aps["UserType"] as! String == "GP" {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NewJob"), object: nil, userInfo: nil)
                }else  if aps["NotificationType"] as! String == "JOBASSIGNED" &&  aps["UserType"] as! String == "GP" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }
            }else if state == .inactive {
                if aps["NotificationType"] as! String == "JOB" &&  aps["UserType"] as! String == "GP" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }else  if aps["NotificationType"] as! String == "JOBASSIGNED" &&  aps["UserType"] as! String == "GP" {
                    self.checkAlreadyLogin(selectedIndex: 1)
                }
            }
        }
    }
    
    
   /* func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name!
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email!
            // ...
            print(fullName, givenName, familyName, email)
            
            
            let dataDict:[String:String] =  [
                "first_name": givenName!,
                "last_name": familyName!,
                "email": email,
                "username": givenName!,
                "socialkey":"3", // (1=>facebook,2=>twitter ,3=>gmail )
                "socialid": userId!
            ]
            //  LoginViewController().socialAction(data: dataDict)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "googleSignIn"), object: nil, userInfo: dataDict)
            //NotificationCenter.defaultCenter.postNotificationName("googleSignIn", object: nil, userInfo: dataDict)
            
        } else {
            print("\(error.localizedDescription)")
        }
    }*/
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func createDatabase(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let databasePath = documentsURL.appendingPathComponent("JanAid.sqlite")
        
        let filemgr = FileManager.default
        print(databasePath)
        
        UserDefaults.standard.set(databasePath, forKey:"DataBasePath")
        UserDefaults.standard.synchronize()
        
        
        if !filemgr.fileExists(atPath: String(describing: databasePath)) {
            let contactDB = FMDatabase(path: String(describing: databasePath))
        
            contactDB.userVersion = UInt32(1.0)
            
            if contactDB == nil {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
            if (contactDB.open()) {
                let sql_stmt = "CREATE TABLE IF NOT EXISTS Pharmacy (ID INTEGER PRIMARY KEY AUTOINCREMENT , PatientID TEXT , OrderID TEXT, OrderDate TEXT, OrderStatus_1mg TEXT, TotalAmount TEXT, DiscountAmount TEXT, ActualAmount TEXT, ShippingAmount TEXT, result TEXT)"
                if !(contactDB.executeStatements(sql_stmt)) {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
                
                contactDB.close()
            } else {
                print("Error: \(contactDB.lastErrorMessage())")
            }
        }
    }


}

