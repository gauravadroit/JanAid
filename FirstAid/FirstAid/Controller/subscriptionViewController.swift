//
//  subscriptionViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class subscriptionViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var currentBalLabel: UILabel!
    
    struct plan {
        var planName:String!
        var price:String!
        var subscribedAt:String!
        var days:String!
        var call:String!
    }
    
    var planArr:[plan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.title = "Subscription"
        self.getSubcriptionData()
        let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
        self.navigationItem.leftBarButtonItem  = sidebutton
        
        
        let sidebutton2 = UIBarButtonItem(title: "Plans", style: .plain, target: self, action: #selector(self.nextViewAction(_:)))
        self.navigationItem.rightBarButtonItem  = sidebutton2
       
    }

    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func nextViewAction(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SubscriptionPlanViewController") as! SubscriptionPlanViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }

    func getSubcriptionData() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.subscriptionPlan + User.patientId, headers: Webservice.header, { (json) in
            print(json)
            
            self.currentBalLabel.text = json["Data"][0]["CallBalance"].stringValue
            self.validLabel.text = json["Data"][0]["ValidTill"].stringValue
            
            if json["Status"].stringValue == "true" {
                for val in json["Data2"].arrayValue {
                    self.planArr.append(plan.init(
                        planName: val["PlanName"].stringValue,
                        price: val["PRICE"].stringValue,
                        subscribedAt: val["SubscribedAt"].stringValue,
                        days: val["DurationInDays"].stringValue,
                        call: val["NoOfCallsAllowed"].stringValue
                    ))
                }
            }
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.tableView.reloadData()
            
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


extension subscriptionViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.planArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
        cell.callLabel.text = self.planArr[indexPath.row].call
        cell.dateLabel.text = self.planArr[indexPath.row].subscribedAt
        cell.dayLabel.text = self.planArr[indexPath.row].days
        cell.nameLabel.text = self.planArr[indexPath.row].planName
        cell.priceLabel.text = self.planArr[indexPath.row].price
        cell.selectionStyle = .none
        return cell
    }
    
}
