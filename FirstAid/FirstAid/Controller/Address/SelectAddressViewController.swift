//
//  SelectAddressViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 19/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SelectAddressDelegate {
    func selectedIndex(index:Int)
}

class SelectAddressViewController: UIViewController {

    @IBOutlet weak var addAddressBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var prescriptionId:String!
    struct address {
        var name:String!
        var state:String!
        var city:String!
        var street:String!
        var contact:String!
        var pincode:String!
        var id:String!
        var country:String!
    }
    var fromMedicine:String!
    @IBOutlet weak var placeOrderBtn: UIButton!
    var addressArr:[address] = []
    var selectedIndex:Int = 0
    var delegate:SelectAddressDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Select Address"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        addAddressBtn.layer.cornerRadius = 5
        
        if fromMedicine == "yes" {
            placeOrderBtn.setTitle("Back", for: UIControlState.normal)
        }
        
    }
  
    override func viewWillAppear(_ animated: Bool) {
         self.getPatientAddressFrom1MG()
    }
    
    @IBAction func placeOrderAction(_ sender: UIButton) {
        
        if addressArr.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please add address.")
            return
        }
        
        if sender.titleLabel?.text == "Back" {
            delegate?.selectedIndex(index:selectedIndex)
            self.navigationController?.popViewController(animated: true)
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "OrderSummaryViewController") as! OrderSummaryViewController
            nextView.city = addressArr[selectedIndex].city
            nextView.mobile = addressArr[selectedIndex].contact
            nextView.country = addressArr[selectedIndex].country
            nextView.state = addressArr[selectedIndex].state
            nextView.street = addressArr[selectedIndex].street
            nextView.Name = addressArr[selectedIndex].name
            nextView.addressId = addressArr[selectedIndex].id
            nextView.pincode = addressArr[selectedIndex].pincode
            Prescription.addressId = addressArr[selectedIndex].id
            self.navigationController?.pushViewController(nextView, animated: true)
        }
        
    
        
    }
    
    func getPatientAddressFrom1MG() {
        let headers:[String:String] = [
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getAddressFrom1MG, headers: headers, { (json) in
            print(json)
            self.addressArr = []
            for data in json["result"].arrayValue {
                self.addressArr.append(address.init(
                    name: data["name"].stringValue,
                    state: data["state"].stringValue,
                    city: data["city"].stringValue,
                    street: data["street1"].stringValue,
                    contact: data["contact_number"].stringValue,
                    pincode: data["pincode"].stringValue,
                    id: data["id"].stringValue,
                    country: data["country"].stringValue
                ))
            }
             ShowLoader.stopLoader()
            if self.addressArr.count == 1 {
                self.selectedIndex = 0
            }
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
             ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
        
    }
    
    @IBAction func addAddressAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
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

extension SelectAddressViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addressArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddressCell", for: indexPath) as! AddressCell
        cell.nameLabel.text = addressArr[indexPath.row].name
        cell.streetLabel.text = addressArr[indexPath.row].street
        cell.cityLabel.text = addressArr[indexPath.row].city + "," + addressArr[indexPath.row].state + "-" + addressArr[indexPath.row].pincode
        cell.mobileLabel.text = "Mobile: " +  addressArr[indexPath.row].contact
        cell.optionBtn.tag = indexPath.row
        if self.selectedIndex == indexPath.row {
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
        }else{
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
        }
        cell.optionBtn.addTarget(self, action: #selector(self.selectOtion(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func selectOtion(sender:UIButton) {
        self.selectedIndex = sender.tag
        self.tableView.reloadData()
    }
    
}
