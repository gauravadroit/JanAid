//
//  LabListViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
var skusValue:[[String:String]] = []
class LabListViewController: UIViewController {
    
    @IBOutlet weak var continueBtn: UIButton!
    struct Test {
        var mrp:String!
        var offeredPrice:String!
        var discountPercent:String!
        var labId:String!
        var testName:String!
        var testId:String!
        var name:String!
        var category:String!
        var rating:String!
        var labLogo:String!
        var precautions:String!
    }
    
    var TestArr:[Test] = []
    var selectedIndex:Int!

    @IBOutlet weak var tableView: UITableView!
    var selectedTestArr:[String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.continueBtn.isEnabled = false
        self.tableView.separatorStyle = .none
    
        self.getLabs()
    }

    func getLabs() {
        let headers:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        var testStr:String = ""
        
        for test in selectedTestArr {
            if testStr != "" {
                testStr = testStr + "&"
            }
            testStr = testStr + "pathology_test=" + test
        }
       
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let replaced = String(User.location!.map {
            $0 == " " ? "+" : $0
        })
        print(Webservice.selectLab + replaced + "&" + testStr)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.selectLab + replaced + "&" + testStr, headers: headers, { (json) in
            print(json["pathology_labs"]["inventories"])
            for data in json["pathology_labs"]["inventories"].arrayValue {
                self.TestArr.append(Test.init(
                    mrp: data["inventory_price_info"]["mrp"].stringValue,
                    offeredPrice: data["inventory_price_info"]["offered_price"].stringValue,
                    discountPercent: data["inventory_price_info"]["discount_percent"].stringValue,
                    labId: data["lab"]["id"].stringValue,
                    testName: data["tests"][0]["test"]["faqs"]["name"].stringValue,
                    testId: data["tests"][0]["test"]["faqs"]["id"].stringValue,
                    name: data["lab"]["name"].stringValue,
                    category: data["category"].stringValue,
                    rating: data["lab"]["rating"].stringValue,
                    labLogo: data["lab"]["logo"].stringValue,
                    precautions: data["tests"][0]["test"]["precautions"][0].stringValue
                ))
            }
             ShowLoader.stopLoader()
            self.tableView.reloadData()
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    @objc func optionBtn(sender:UIButton) {
        selectedIndex = sender.tag
        self.tableView.reloadData()
        self.continueBtn.isEnabled = true
      //  self.addItem()
    }
    
    func addItem() {
        let headers:[String:String] = [
           
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": User.oneMGLabToken
        ]
        
        var skus:[[String:String]] = []
        
        for test in selectedTestArr {
          
            skus.append([
                "test_id": test,
                "lab_id": self.TestArr[selectedIndex].labId
                ])
        }
        
        skusValue = skus
        let parameter:[String:Any] = [
            "skus":skus,
            "city":User.location!
        ]
        
        print(parameter)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPutWithJson(path: Webservice.addLabToCart, dataDict: parameter, headers: headers, { (json) in
            print(json)
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
        
    }
    
    @IBAction func labAction(_ sender: UIButton) {
        
        var skus:[[String:String]] = []
        
        for test in selectedTestArr {
            skus.append([
                "test_id": test,
                "lab_id": self.TestArr[selectedIndex].labId
                ])
        }
        
        Lab.skusArr = skus
        Lab.labId = self.TestArr[selectedIndex].labId
        Lab.precautions = self.TestArr[selectedIndex].precautions
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
      
      LabAddress.price = self.TestArr[selectedIndex].offeredPrice
        
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddLabAddressViewController") as! AddLabAddressViewController
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

extension LabListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.TestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabListCell", for: indexPath) as! LabListCell
        
        if self.TestArr[indexPath.row].discountPercent == "0" {
            cell.discountLabel.text = ""
            cell.discountPriceLabel.text = ""
        }else{
            cell.discountLabel.text = self.TestArr[indexPath.row].discountPercent + "%"
            cell.discountPriceLabel.text = "₹" + self.TestArr[indexPath.row].offeredPrice
        }
        cell.mrpLabel.text = "₹" + self.TestArr[indexPath.row].mrp
        cell.pathNameLabel.text = self.TestArr[indexPath.row].name
        cell.certificationLabel.text = ""
        cell.labImageView.sd_setImage(with: URL(string: self.TestArr[indexPath.row].labLogo), placeholderImage: UIImage(named: "Medicine"))
        cell.ratingLabel.text = " " + self.TestArr[indexPath.row].rating + " ★ "
        
        if selectedIndex == indexPath.row {
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: .normal)
        }else{
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
        }
        
        cell.optionBtn.tag = indexPath.row
        cell.optionBtn.addTarget(self, action: #selector(self.optionBtn(sender:)), for: .touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
}
