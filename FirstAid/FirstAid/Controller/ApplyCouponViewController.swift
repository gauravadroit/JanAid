//
//  ApplyCouponViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 12/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class ApplyCouponViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var couponText: UITextField!
    @IBOutlet weak var memberMsgLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var benefits:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        couponText.tag = 100
        couponText.delegate = self
        self.title = "Apply Coupon"
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        //couponText.autocapitalizationType = UITextAutocapitalizationTypeSentences
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        applyBtn.layer.cornerRadius = 5
        self.applyBtn.addTarget(self, action: #selector(self.applyPromocode(sender:)), for: .touchUpInside)
        self.getBenefits()
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getBenefits() {
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.couponBenefit + User.patientId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.benefits = []
            
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
    
    @objc func applyPromocode(sender:UIButton) {
        
        self.view.endEditing(true)
        
        if couponText.text! == "" {
           Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter coupon code.")
            return
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let parameter:[String:String] = [
            "PatientID": User.patientId,
            "Code":couponText.text!
        ]
        
        print(parameter)
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.applyMemebership, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                //User.isFreeConsultationApplicable = json["Data"][0]["IsFreeConsultationApplicable"].stringValue
                //User.UsedPromoID =  json["Data"][0]["UsedPromoID"].stringValue
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.navigationController?.popViewController(animated: true)
               
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
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

extension ApplyCouponViewController:UITableViewDelegate, UITableViewDataSource {
    
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

extension ApplyCouponViewController:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        /*if textField.tag == 100 {
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }else if textField.text!.count == 19 {
                return false
            }else if ((textField.text!.count+1)%5 == 0) {
                textField.text = textField.text! + "-";
            }
            return true
        }*/
        
        return true
    }
}
