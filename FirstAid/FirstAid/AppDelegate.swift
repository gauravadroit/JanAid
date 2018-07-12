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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = true
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 0.0/255.0, green: 91.0/255.0, blue: 151.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
       
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
       
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 12)!],for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Helvetica", size: 12)!],for: .selected)
        UITabBar.appearance().tintColor = UIColor.white
        
        
        
        GMSServices.provideAPIKey("AIzaSyBFKezYkorOgrOTRrOL-7Y0N4np6BqZvxw")
        self.checkAlreadyLogin()
        
        registerForPushNotifications(application)
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? NSDictionary {
            UIApplication.shared.applicationIconBadgeNumber = 0
            let aps = notification["aps"] as! [String: AnyObject]
        }
        return true
    }
    
    func checkAlreadyLogin() {
        
        var Login:String = ""
        if let temp  = UserDefaults.standard.string(forKey: "login") {
            Login = temp
        }
        
        if Login == "yes" {
            if let temp  = UserDefaults.standard.string(forKey: "UserType") {
                if temp == "GP" {
                    self.GPLogin()
                }else if temp == "Patient" {
                    self.patientLogin()
                }else if temp == "PI" {
                    self.PILogin()
                }
            }
        }else{
            let firstController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = firstController
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
    
    func GPLogin() {
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
        
        DispatchQueue.main.async() {
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "GP", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
            UIApplication.shared.keyWindow?.rootViewController = viewController
        }
        
    }
    
    
    func patientLogin() {
        
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
        print(notification.request.content.userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(response.notification.request.content.userInfo)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
        UIApplication.shared.applicationIconBadgeNumber = 0
        let state: UIApplicationState = UIApplication.shared.applicationState
        
        if state == .inactive {
            print(userInfo)
        }
    }
    


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


}

