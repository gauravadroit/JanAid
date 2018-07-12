//
//  LabMyOrderViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView

class LabMyOrderViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    struct LabTest {
        var orderId:String!
        var name:String!
        var gender:String!
        var date:String!
        var time:String!
        var labName:String!
        var labRating:String!
        var labLogo:String!
        var labId:String!
        var testArr:[LabBooking] = []
        var accreditation:String!
    }
    
    var cancelOrderView:CancelOrder!
    var selectedOrderId:String!
    var labTestArr:[LabTest] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.title = "Lab Test"
        let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
        self.navigationItem.leftBarButtonItem  = sidebutton
        self.getMyOrder()
        menuContainerViewController.panMode = MFSideMenuPanModeNone
        
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }

    
    func getMyOrder() {
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.labOrder, headers: headers, { (json) in
            print(json)
            
             self.labTestArr = []
            
            for data in json["orders"].arrayValue {
                
                var temp:[LabBooking] = []
                for val in data["bookings"].arrayValue {
                    temp.append(LabBooking.init(
                        bookingId: val["test"]["id"].stringValue,
                        testId: val["id"].stringValue,
                        testName: val["test"]["name"].stringValue,
                        status: val["status"].stringValue
                    ))
                }
                
                self.labTestArr.append(LabTest.init(
                    orderId: data["order_id"].stringValue,
                    name:  data["patient"]["name"].stringValue,
                    gender:  data["patient"]["gender"].stringValue,
                    date:  data["bookings"][0]["collection_time_slot"]["date"].stringValue,
                    time:  data["bookings"][0]["collection_time_slot"]["slot"].stringValue,
                    labName:  data["lab"]["name"].stringValue,
                    labRating:  data["lab"]["rating"].stringValue,
                    labLogo:  data["lab"]["logo"].stringValue,
                    labId:  data["lab"]["id"].stringValue,
                    testArr: temp,
                    accreditation: data["lab"]["accreditation"][0]["name"].stringValue
                ))
            }
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
              NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
        
    }
    
    
    func cancelOrderAction() {
        /* let StoryBoard = UIStoryboard(name: "Main", bundle: nil)
         let nextView = StoryBoard.instantiateViewController(withIdentifier: "CancelOrderViewController") as! CancelOrderViewController
         nextView.orderId = orderArr[sender.tag].orderId
         self.navigationController?.pushViewController(nextView, animated: true)*/
        
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
            "Authorization": User.oneMGLabToken
        ]
        
        let parameter:[String:String] = [
            "cancel_reason":"testing",
        ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPutWithJson(path: Webservice.cancelLaborder + selectedOrderId, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            //self.removeFromSuperView()
            self.saveCancelOrder(orderId: self.selectedOrderId, orderStatus: "Cancelled")
            self.getMyOrder()
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    func saveCancelOrder(orderId:String,orderStatus:String){
        
        let parameter:[String:String] = [
            "BookingID": orderId,
            "OrderStatus_1mg": orderStatus
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.cancelLab, dataDict: parameter, headers: Webservice.header, { (json) in
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

extension LabMyOrderViewController:UITableViewDelegate, UITableViewDataSource {
   /* func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labTestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabMyOrderCell", for: indexPath) as! LabMyOrderCell
        
        cell.dateLabel.text = labTestArr[indexPath.row].date
        cell.labNameLabel.text = labTestArr[indexPath.row].labName
        cell.nameLabel.text = labTestArr[indexPath.row].name
        cell.orderIdLabel.text = labTestArr[indexPath.row].orderId
        cell.ratingLabel.text = "  " + labTestArr[indexPath.row].labRating + "  "
        cell.timeLabel.text = labTestArr[indexPath.row].time
        cell.labImage.sd_setImage(with: URL(string: labTestArr[indexPath.row].labLogo), placeholderImage: #imageLiteral(resourceName: "pencil"))
        
        cell.selectionStyle = .none
        return cell
    }*/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return labTestArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labTestArr[section].testArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabMyOrderCell2", for: indexPath) as! LabMyOrderCell2
        cell.testNameLabel.text = labTestArr[indexPath.section].testArr[indexPath.row].testName
        cell.testStatusLabel.text = labTestArr[indexPath.section].testArr[indexPath.row].status
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabMyOrderCell") as! LabMyOrderCell
        
        cell.dateLabel.text = labTestArr[section].date
        cell.labNameLabel.text = labTestArr[section].labName
        cell.nameLabel.text = labTestArr[section].name
        cell.orderIdLabel.text = labTestArr[section].orderId
        cell.ratingLabel.text = "  " + labTestArr[section].labRating + " ★"
        cell.timeLabel.text = labTestArr[section].time
        cell.labImage.sd_setImage(with: URL(string: labTestArr[section].labLogo), placeholderImage: #imageLiteral(resourceName: "Lab"))
        cell.accreditationLabel.text = labTestArr[section].accreditation
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 175
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if labTestArr[indexPath.section].testArr[indexPath.row].status == "Cancelled" {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
             selectedOrderId = labTestArr[indexPath.section].testArr[indexPath.row].testId
            //selectedOrderId = orderArr[sender.tag].orderId
            self.confirmCancelOrderAction()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Cancel"
    }
    
    
}
