//
//  SubscriptionPlanViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SubscriptionPlanViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var itemsPerRow:CGFloat = 2
    
    struct plan {
        var planName:String!
        var planPrice:String!
        var Days:String!
        var calls:String!
        var planId:String!
        var description:String!
    }
    
    var planArr:[plan] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.title = "Plans"
        self.getPlan()
    }

    func getPlan() {
        
        let parameter:[String:String] = [
            "FlagNo":"2",
            "PageSize":"50",
            "PageNumber":"1",
            "Value1":"0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getPlan, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                for val in json["Data"].arrayValue {
                self.planArr.append(plan.init(
                    planName: val["PlanName"].stringValue,
                    planPrice:  val["PlanPrice"].stringValue,
                    Days:  val["DurationInDays"].stringValue,
                    calls:  val["NoOfCallsAllowed"].stringValue,
                    planId:  val["PlanID"].stringValue,
                    description:  val["Description"].stringValue
                ))
            }
            }
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            self.collectionView.reloadData()
            
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    

    @objc func buyAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "BuyPlanViewController") as! BuyPlanViewController
        nextView.name = self.planArr[sender.tag].planName
        nextView.price = self.planArr[sender.tag].planPrice
        nextView.validity = self.planArr[sender.tag].Days
        nextView.planId = self.planArr[sender.tag].planId
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


extension SubscriptionPlanViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.planArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubcriptionPlanCell", for: indexPath) as! SubcriptionPlanCell
        cell.planTypeLabel.text = self.planArr[indexPath.row].planName
        cell.planPriceLabel.text =  "₹" + self.planArr[indexPath.row].planPrice
        cell.planValidityLabel.text = self.planArr[indexPath.row].Days + " Days"
        cell.pricelabel.text =   "₹" + self.planArr[indexPath.row].planPrice
        cell.validityLabel.text = self.planArr[indexPath.row].Days + " Days"
        cell.buyBtn.tag = indexPath.row
        cell.buyBtn.addTarget(self, action: #selector(self.buyAction(sender:)), for: .touchUpInside)
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (10 ) * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        var heightPerItem:CGFloat!
        /*let heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)!)/4) - 5
         
         let heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4*/
        
       /* if UIDevice.current.modelName == "iPhone X" {
            heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/3
        }else{
            heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 50)/3)
        }*/
        
        heightPerItem = UIScreen.main.bounds.height/3
        
        return CGSize(width: widthPerItem , height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
}
}
