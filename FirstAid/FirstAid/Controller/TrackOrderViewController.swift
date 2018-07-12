//
//  TrackOrderViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TrackOrderViewController: UIViewController {

    @IBOutlet weak var totalAmtLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    var orderId:String!
    var orderDate:String!
    override func viewDidLoad() {
        super.viewDidLoad()
       self.trackOrder()
        backView.layer.cornerRadius = 5
        backView.dropShawdow()
        
        self.title = "Track Order"
        orderDateLabel.text = orderDate
        orderIdLabel.text = orderId
       
    }

    func trackOrder() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        print(headers)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.trackOrder + orderId + "/tracking_details?has_upload_rx=false", headers: headers, { (json) in
            print(json)
            
             self.totalAmtLabel.text = json["result"]["order_details"]["payment_details"]["info"][1]["Total Payable"]["value"].stringValue
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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
