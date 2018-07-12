//
//  AllOrderViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
class AllOrderViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var cancelOrderView:CancelOrder!
    var selectedOrderId:String!
    var jsonArr:[JSON] = []
    
    struct order {
        var orderId:String!
        var orderDate:String!
        var orderStatus:String!
        var orderStatusMsg:String!
        var orderItem:String!
        var orderItemCount:String!
    }
    
    var orderArr:[order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pharmacy Orders"
        self.tableView.separatorStyle = .none
        
        let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
        self.navigationItem.leftBarButtonItem  = sidebutton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getAllOrderFrom1MG()
    }

    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    func getAllOrderFrom1MG() {
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
            
            self.orderArr = []
            self.jsonArr = []
            
            self.jsonArr = json["result"]["grouped_orders"].arrayValue
            for data in json["result"]["grouped_orders"].arrayValue {
                print(data)
                self.orderArr.append(order.init(
                    orderId: data["group_id"].stringValue,
                    orderDate: data["formatted_order_date"].stringValue,
                    orderStatus: data["orders"][0]["status"].stringValue,
                    orderStatusMsg: data["orders"][0]["order_status_messages"]["processed"].stringValue,
                    orderItem: data["orders"][0]["orderItems"][0]["productGroupBrandName"].stringValue,
                    orderItemCount: String(data["orders"][0]["orderItems"].arrayValue.count)
                ))
            }
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    @objc func trackOrderAction(sender:UIButton) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = StoryBoard.instantiateViewController(withIdentifier: "TrackOrderViewController") as! TrackOrderViewController
        nextView.orderId = orderArr[sender.tag].orderId
        nextView.orderDate = orderArr[sender.tag].orderDate
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func cancelOrderAction(sender:UIButton) {
       /* let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = StoryBoard.instantiateViewController(withIdentifier: "CancelOrderViewController") as! CancelOrderViewController
        nextView.orderId = orderArr[sender.tag].orderId
        self.navigationController?.pushViewController(nextView, animated: true)*/
        selectedOrderId = orderArr[sender.tag].orderId
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

extension AllOrderViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        cell.orderIdLabel.text = orderArr[indexPath.row].orderId
        cell.orderDate.text = orderArr[indexPath.row].orderDate
        //cell.trackOrderBtn.tag = indexPath.row
        //cell.cancelOrderBtn.tag = indexPath.row
        
        //cell.trackOrderBtn.addTarget(self, action: #selector(self.trackOrderAction(sender:)), for: .touchUpInside)
        //cell.cancelOrderBtn.addTarget(self, action: #selector(self.cancelOrderAction(sender:)), for: .touchUpInside)
        cell.orderStatusLabel.text = orderArr[indexPath.row].orderStatusMsg
        //cell.medicineLabelName.text = orderArr[indexPath.row].orderItem
        cell.medicineLabelName.text = "Items"
        cell.qtylabel.text = orderArr[indexPath.row].orderItemCount
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = StoryBoard.instantiateViewController(withIdentifier: "OrderDetailViewController") as! OrderDetailViewController
        nextView.jsonData = jsonArr[indexPath.row]
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}
