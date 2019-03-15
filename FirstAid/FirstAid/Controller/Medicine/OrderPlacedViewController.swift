//
//  OrderPlacedViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import FMDB

class OrderPlacedViewController: UIViewController {
    @IBOutlet weak var orderIdLabel: UILabel!
    var orderId:String!
    
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var trackorderBtn: UIButton!
    @IBOutlet weak var homeBtn: UIButton!
    var fromLab:String = "false"
    var fromMedicine:String = "false"
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Order Placed"
        self.orderIdLabel.text = "order #\(orderId.uppercased()) has been successfully placed"
        self.homeBtn.layer.cornerRadius = 5
        self.navigationItem.setHidesBackButton(true, animated: true)
        if fromLab == "true" {
            trackorderBtn.isHidden = true
            msgLabel.isHidden = true
        }
        
        if fromMedicine == "true" {
            self.saveDataOffLine()
            self.saveMedicineOrderId()
        }
    }
    
    func saveDataOffLine(){
        let databasePath = UserDefaults.standard.url(forKey: "DataBasePath")!
        let contactDB = FMDatabase(path: String(describing: databasePath))
        
        if (contactDB.open()) {
                let insertSQL = "INSERT INTO Pharmacy (PatientID, OrderID, OrderDate, OrderStatus_1mg, TotalAmount, DiscountAmount, ActualAmount, ShippingAmount, result) VALUES ('\(User.patientId!)', '\(MedicineData.OrderID!)','\(MedicineData.OrderDate!)', '\(MedicineData.OrderStatus_1mg!)', '\(MedicineData.TotalAmount!)','\(MedicineData.DiscountAmount!)', '\(MedicineData.ActualAmount!)','\(MedicineData.ShippingAmount!)', '\("failed")')"
            let result = contactDB.executeStatements(insertSQL)
           // let result = contactDB.executeUpdate(insertSQL , withArgumentsIn: nil)
                
            if !result {
                    print("Error: \(contactDB.lastErrorMessage())")
                }
            
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    func deleteDataFromSqlite() {
        let databasePath = UserDefaults.standard.url(forKey: "DataBasePath")!
        let contactDB = FMDatabase(path: String(describing: databasePath))
        
        if (contactDB.open()) {
            let insertSQL = "DELETE FROM Pharmacy where OrderID = '\(MedicineData.OrderID!)'"
            let result = contactDB.executeStatements(insertSQL)
            if !result {
                print("Error: \(contactDB.lastErrorMessage())")
            }
            
        } else {
            print("Error: \(contactDB.lastErrorMessage())")
        }
    }
    
    func saveMedicineOrderId() {
        let parameter:[String:String] = [
            "PatientID":User.patientId,
            "OrderID":MedicineData.OrderID,
            "OrderDate":MedicineData.OrderDate,
            "OrderStatus_1mg":MedicineData.OrderStatus_1mg,
            "TotalAmount":MedicineData.TotalAmount,
            "DiscountAmount":MedicineData.DiscountAmount,
            "ActualAmount":MedicineData.ActualAmount,
            "ShippingAmount":MedicineData.ShippingAmount
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MgOrder, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.deleteDataFromSqlite()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
        
    }

    @IBAction func homeAction(_ sender: UIButton) {
       // self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func trackOrderAction(_ sender: UIButton) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = StoryBoard.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
        nextView.selectedOrderId = orderId
        self.navigationController?.pushViewController(nextView, animated: true)
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
