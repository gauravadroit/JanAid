//
//  OrderDetailViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import Toast_Swift

class OrderDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var cancelOrderView:CancelOrder!
    
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var trackOrderBtn: UIButton!
    var jsonData:JSON!
    var selectedOrderId:String!
    
    
    @IBOutlet weak var tableViewConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(jsonData)
        
        self.title = "Order Details"
        self.tableView.separatorStyle = .none
        //cancelOrderBtn.layer.borderColor = UIColor(red: 22.0/255.0, green: 89.0/255.0, blue: 141.0/255.0, alpha: 1.0).cgColor
       // cancelOrderBtn.layer.borderWidth = 1
        cancelOrderBtn.addTarget(self, action: #selector(self.cancelOrderAction(sender:)), for: .touchUpInside)
        // "original_order_status" : "Cancelled"
        
        if jsonData != nil {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            if jsonData["orders"][0]["original_order_status"].stringValue == "Cancelled" {
                tableViewConstraint.constant = 0.0
            }
        }else{
            self.getOrder()
        }
        //self.tabBarController?.tabBar.isHidden = true
        //self.trackOrder()
    }
    
    func getOrder() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getAllOrders, headers: headers, { (json) in
            print(json)
            
           // self.orderArr = []
          //  self.jsonArr = []
            
         //   self.jsonArr = json["result"]["grouped_orders"].arrayValue
            for data in json["result"]["grouped_orders"].arrayValue {
                print(data)
                if data["group_id"].stringValue == self.selectedOrderId {
                    self.jsonData = data
                }
                /*self.orderArr.append(order.init(
                    orderId: data["group_id"].stringValue,
                    orderDate: data["formatted_order_date"].stringValue,
                    orderStatus: data["orders"][0]["status"].stringValue,
                    orderStatusMsg: data["orders"][0]["order_status_messages"]["processed"].stringValue,
                    orderItem: data["orders"][0]["orderItems"][0]["productGroupBrandName"].stringValue,
                    orderItemCount: String(data["orders"][0]["orderItems"].arrayValue.count)
                ))*/
            }
            self.tableView.delegate = self
            self.tableView.dataSource = self
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
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
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.trackOrder + jsonData["group_id"].stringValue + "/tracking_details?has_upload_rx=false", headers: headers, { (json) in
            print(json)
            
          //  self.totalAmtLabel.text = json["result"]["order_details"]["payment_details"]["info"][1]["Total Payable"]["value"].stringValue
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    
    @objc func cancelOrderAction(sender:UIButton) {
        /* let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
         let nextView = StoryBoard.instantiateViewController(withIdentifier: "CancelOrderViewController") as! CancelOrderViewController
         nextView.orderId = orderArr[sender.tag].orderId
         self.navigationController?.pushViewController(nextView, animated: true)*/
        selectedOrderId = jsonData["group_id"].stringValue
        cancelOrderView = CancelOrder(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        //self.view.addSubview(cancelOrderView)
        cancelOrderView.cancelBtn.addTarget(self,action: #selector(self.removeFromSuperView), for: .touchUpInside)
        cancelOrderView.confirmBtn.addTarget(self,action: #selector(self.confirmCancelOrderAction), for: .touchUpInside)
        UIApplication.shared.keyWindow?.addSubview(cancelOrderView)
    }
    
    @objc func removeFromSuperView(){
        self.cancelOrderView.removeFromSuperview()
    }
    
    @objc func confirmCancelOrderAction(){
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        let parameter:[String:String] = [
            "cancelReason":cancelOrderView.selectedId,
            "otherCancelReasonText":""
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.cancelOrder + selectedOrderId, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.removeFromSuperView()
            if json["status"].stringValue == "0" {
                self.getOrder()
                self.saveCancelOrder(orderId: self.selectedOrderId, orderStatus: "Order Cancelled")
                self.tableViewConstraint.constant = 0.0
                self.view.makeToast(json["result"].stringValue, duration: 3.0, position: .bottom)
            }
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
    
    func saveCancelOrder(orderId:String,orderStatus:String){
        
        let parameter:[String:String] = [
            "OrderID": orderId,
            "OrderStatus_1mg": orderStatus,
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.cancelPramacy, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
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

extension OrderDetailViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return jsonData["orders"][0]["orderItems"].arrayValue.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusCell", for: indexPath) as! OrderStatusCell
            cell.statusLabel.text = jsonData["orders"][0]["order_status_messages"]["processed"].stringValue
            cell.statusMsgLabel.text = jsonData["orders"][0]["order_status_messages"]["processing"].stringValue
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath) as! OrderItemCell
            cell.medicineNameLabel.text = jsonData["orders"][0]["orderItems"][indexPath.row]["productName"].stringValue
            cell.medicineDetailLabel.text = jsonData["orders"][0]["orderItems"][indexPath.row]["productQuantity"].stringValue + " " + jsonData["orders"][0]["orderItems"][indexPath.row]["packSizeLabel"].stringValue
            cell.priceLabel.text = "₹" + String(jsonData["orders"][0]["orderItems"][indexPath.row]["offeredPrice"].floatValue)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderDetailCell", for: indexPath) as! OrderDetailCell
            
            cell.orderIdLabel.text = jsonData["group_id"].stringValue
            cell.orderDateLabel.text = jsonData["formatted_order_date"].stringValue
            
            cell.totalPriceLabel.text = "₹" + String(jsonData["orders"][0]["payment_summary"]["orderAmount"].floatValue)
            cell.subTotalLabel.text = "₹" + String(jsonData["orders"][0]["payment_summary"]["discountedMrp"].floatValue)
            cell.shipingChargesLabel.text = "₹" + String(jsonData["orders"][0]["shippingAmt"].floatValue)
            
            cell.nameLabel.text = jsonData["orders"][0]["address"]["name"].stringValue
            cell.streetLabel.text = jsonData["orders"][0]["address"]["locality"].stringValue + ", " + jsonData["orders"][0]["address"]["street1"].stringValue
            cell.cityLabel.text = jsonData["orders"][0]["address"]["city"].stringValue + ", " + jsonData["orders"][0]["address"]["pincode"].stringValue + "-" + jsonData["orders"][0]["address"]["state"].stringValue
            cell.countryLabel.text = jsonData["orders"][0]["address"]["contactNo"].stringValue
            
            cell.selectionStyle = .none
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}
