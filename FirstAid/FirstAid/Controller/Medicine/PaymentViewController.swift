//
//  PaymentViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 30/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

class PaymentViewController: UIViewController {

    @IBOutlet weak var placeOrderBtn: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var totalprice:String!
    var paymentMethodArr:[String] = ["Online","PAYTM","COD"]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        priceLabel.text = "Price: ₹" + totalprice
    }

    
    @IBAction func placeOrderBtn(_ sender: UIButton) {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        let parameter:[String:String] = [
            "rx_queued":"false",
            "payment_mode":"COD",
            "cashback_availed":"0.0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.placeOrder, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "0" {
                MedicineData.OrderStatus_1mg = json["result"]["status"].stringValue
                MedicineData.OrderID = json["result"]["orderId"].stringValue
                MedicineData.OrderDate = json["result"]["formatOrderDate"].stringValue
                MedicineData.ShippingAmount = json["result"]["shippingAmt"].stringValue
                MedicineData.ActualAmount = json["result"]["actualAmnt"].stringValue
                MedicineData.DiscountAmount = json["result"]["discount"].stringValue
                MedicineData.TotalAmount = json["result"]["totalAmt"].stringValue
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "OrderPlacedViewController") as! OrderPlacedViewController
                nextView.fromMedicine = "true"
                nextView.orderId = json["result"]["orderId"].stringValue
                self.navigationController?.pushViewController(nextView, animated: true)
            }else if json["status"].stringValue == "1" {
                let errorMsg = json["errors"]["errs"][0]["msg"].stringValue
                self.view.makeToast(errorMsg, duration: 4.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
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

extension PaymentViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentCell
        cell.titleLabel.text = paymentMethodArr[indexPath.row]
        if indexPath.row == 2 {
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: .normal)
        }else{
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
        }
        cell.selectionStyle = .none
        return cell
    }
}

