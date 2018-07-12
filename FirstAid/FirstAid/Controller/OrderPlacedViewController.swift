//
//  OrderPlacedViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

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
            self.saveMedicineOrderId()
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
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MgOrder, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
