//
//  LabCartViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LabCartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    struct test {
        var name:String!
        var id:String!
        var price:String!
        var mrp:String!
        var isAvailable:String!
        var isIncludedinPackage:String!
    }
    
    var labName:String = ""
    var labImageUrl:String = ""
    var labId:String = ""
    var totalAmount:String = ""
    var subTotalAmount:String = ""
    
    var testArr:[test] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = .none
        self.getCart()
    }

    func getCart(){
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.labCart + User.location!, headers: headers, { (json) in
            print(json)
            
            self.labId = json["pathology_cart"]["lab"]["id"].stringValue
            self.labName = json["pathology_cart"]["lab"]["name"].stringValue
            self.labImageUrl = json["pathology_cart"]["lab"]["logo"].stringValue
            self.subTotalAmount = json["payment_info"]["payable_price_without_charges"].stringValue
            self.totalAmount = json["payment_info"]["payable_price"].stringValue

            
            for data in json["pathology_cart"]["items"].arrayValue {
               self.testArr.append(test.init(
                name: data["test"]["name"].stringValue,
                id: data["test"]["id"].stringValue,
                price: data["price"].stringValue,
                mrp: data["mrp"].stringValue,
                isAvailable: data["available"].stringValue,
                isIncludedinPackage: data["is_included_in_package"].stringValue
               ))
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
        }
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LabOrderDetailsViewController") as! LabOrderDetailsViewController
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

extension LabCartViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testArr.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabNameCell", for: indexPath) as! LabNameCell
            cell.labLogoImage.sd_setImage(with: URL(string:labImageUrl), placeholderImage: UIImage(named: "Medicine"))
            cell.nameLabel.text = labName
            cell.selectionStyle = .none
            return cell
        }else if indexPath.row == (self.testArr.count + 1) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabAmountCell", for: indexPath) as! LabAmountCell
            cell.subTotalLabel.text = self.subTotalAmount
            cell.amountLabel.text =  "₹" +  self.totalAmount
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "LabChargeCell", for: indexPath) as! LabChargeCell
            cell.testName.text = self.testArr[indexPath.row - 1].name
            cell.testPriceLabel.text =  "₹" +  self.testArr[indexPath.row - 1].price
            cell.selectionStyle = .none
            return cell
        }
    }
}
