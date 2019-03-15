//
//  UnlimitedConsultationViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 14/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class UnlimitedConsultationViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewLabel: UILabel!
    var callNumber:String!
    var benefits:[String] = []
    
    var titleStr:String!
    var titleStr1:String!
    var index:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
       // self.title = titleStr
        
        
        actionBtn.addTarget(self, action: #selector(self.actionBtnAction(sender:)), for: .touchUpInside)
        self.actionBtn.layer.cornerRadius = self.actionBtn.frame.size.height/2
        
        if index == 0 {
            self.getFreeConsultation()
            self.actionBtn.setTitle("Call Now", for: .normal)
        }else if index == 1 {
            self.getHealthCheckups()
            self.actionBtn.setTitle("Proceed", for: .normal)
        }
        
    }
    

    @IBAction func closeAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getFreeConsultation() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getUnlimitedConsultation + User.UsedPromoID, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.benefits = []
            
            self.titleLabel.text = json["Message"].stringValue
            self.title = json["Message"].stringValue
            self.callNumber = json["Data2"].stringValue
            self.titleStr1 = json["Message"].stringValue
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.benefits.append(data["Details"].stringValue)
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            
        }
    }
    
    
    func getHealthCheckups() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getHealthCheckUp + User.UsedPromoID, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.benefits = []
            
            self.titleLabel.text = json["Message"].stringValue
            self.title = json["Message"].stringValue
            self.titleStr1 = json["Message"].stringValue
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.benefits.append(data["PackageDetail"].stringValue)
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            
        }
    }
    
    
    @objc func actionBtnAction(sender:UIButton) {
        
        if sender.titleLabel?.text == "Call Now" {
            if let url = URL(string: "tel://\(callNumber!)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }else{
            let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
            let nextview = storyboard.instantiateViewController(withIdentifier: "BookLabTestViewController") as! BookLabTestViewController
            nextview.titleStr = titleStr1
            self.navigationController?.pushViewController(nextview, animated: true)
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UnlimitedConsultationViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.benefits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponBenfitCell", for: indexPath) as! CouponBenfitCell
        cell.benefitLabel.text = self.benefits[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
}
