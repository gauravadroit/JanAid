//
//  MyPrescriptionViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 05/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class MyPrescriptionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var urlArr:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Prescription"
        self.getAllPrescription()
    }

    func getAllPrescription()  {
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
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getPrescription, headers: headers, { (json) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            print(json)
            
            if json["status"].stringValue == "0" {
                for data in json["result"].arrayValue {
                    self.urlArr.append(data["prescriptionUrl"].stringValue)
                }
                
                self.collectionView.reloadData()
            }
            
        }) { (error) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            print(error)
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

extension MyPrescriptionViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return urlArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyPrescriptionCell", for: indexPath) as! MyPrescriptionCell
        cell.prescriptionImage.sd_setImage(with: URL(string: urlArr[indexPath.row]), placeholderImage: #imageLiteral(resourceName: "pencil"))
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /* let paddingSpace = (10 ) * (itemsPerRow + 1)
         let availableWidth = view.frame.width - paddingSpace
         let widthPerItem = availableWidth / itemsPerRow
         var heightPerItem:CGFloat!
         /*let heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)!)/4) - 5
         
         let heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4*/
         
         if UIDevice.current.modelName == "iPhone X" {
         heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4
         }else{
         heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 120)/4)
         }*/
        
        return CGSize(width: 100 , height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
