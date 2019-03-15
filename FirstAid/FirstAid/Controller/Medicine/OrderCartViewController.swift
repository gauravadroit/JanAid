//
//  OrderCartViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 27/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Toast_Swift

class OrderCartViewController: UIViewController, SelectAddressDelegate {
    
    @IBOutlet weak var paidLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    struct address {
        var name:String!
        var state:String!
        var city:String!
        var street:String!
        var contact:String!
        var pincode:String!
        var id:String!
        var country:String!
        var locality:String!
    }
    
    
    
    var medicineArr:[medicine] = []
    var addressArr:[address] = []
    var totalPrice:String!
    var actualPrice:String!
    var discount:String!
    var shipingPrice:String!
    var prescription:String!
    var selectedIndex:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.tableView.separatorStyle = .none
        
        
        paidLabel.text = "Price: ₹" + totalPrice
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getPatientAddressFrom1MG()
    }

    
    func getPatientAddressFrom1MG() {
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
                    country: data["country"].stringValue,
                    locality: data["locality"].stringValue
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
        }
    }
    
    func selectedIndex(index: Int) {
        self.selectedIndex = index
        self.getPatientAddressFrom1MG()
    }
    
    @objc func addAddress(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func changeAddress(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyBoard.instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        nextView.fromMedicine = "yes"
        nextView.delegate = self
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        print(headers)
        
        if addressArr.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please add Address", withError: nil, onClose: {
            })
            return
        }
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.OneMGbaseUrl + "webservices/addresses/\(addressArr[selectedIndex].id!)/check-serviceability-select-address", dataDict: [:], headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "0" {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
                nextView.totalprice = self.totalPrice
                self.navigationController?.pushViewController(nextView, animated: true)
            }else if json["status"].stringValue == "1" {
              let errorMsg = json["errors"]["errs"][0]["msg"].stringValue
                self.view.makeToast(errorMsg, duration: 4.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
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

extension OrderCartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else if section == 1 {
            return medicineArr.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if addressArr.count == 0 {
                let cell = UITableViewCell()
                let addAddressBtn = UIButton(frame: CGRect(x: cell.contentView.frame.size.width - 80, y: 8, width: 120, height: 30))
                addAddressBtn.setTitle("Add Address", for: UIControlState.normal)
                //addAddressBtn.currentTitleColor = UIColor.blue
                addAddressBtn.setTitleColor(UIColor.blue, for: UIControlState.normal)
                addAddressBtn.addTarget(self, action: #selector(self.addAddress), for: UIControlEvents.touchUpInside)
                cell.contentView.addSubview(addAddressBtn)
            
                let infoLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 200, height: 30))
                infoLabel.text = "No address available"
                cell.contentView.addSubview(infoLabel)
            
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCartAddressCell", for: indexPath) as! OrderCartAddressCell
                cell.nameLabel.text = addressArr[self.selectedIndex].name
                cell.addressLabel.text = addressArr[self.selectedIndex].street
                cell.localityLabel.text = addressArr[self.selectedIndex].locality
                cell.pincodeLabel.text = addressArr[self.selectedIndex].city + "," + addressArr[self.selectedIndex].state + " - " + addressArr[self.selectedIndex].pincode
                cell.mobileLabel.text = "Mobile: " + addressArr[self.selectedIndex].contact
                return cell
            }
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCartMedicineCell", for: indexPath) as! OrderCartMedicineCell
            cell.medicineName.text = medicineArr[indexPath.row].pname
            cell.metaName.text = medicineArr[indexPath.row].qty + "x " + medicineArr[indexPath.row].meta
            cell.fixedMRPLabel.text = "MRP ₹" + String(format: "%.1f",self.medicineArr[indexPath.row].MRP)
            cell.discountedMrpLabel.text = "Total ₹" + medicineArr[indexPath.row].discountedPrice
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalPriceCell", for: indexPath) as! TotalPriceCell
            cell.totalPriceLabel.text = "₹" + totalPrice
            cell.discountLabel.text = "₹" + discount
            cell.mrpTotalLabel.text = "₹" + actualPrice
            cell.shipingLabel.text = "₹" + shipingPrice
        
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30.0))
            let changeAddressBtn = UIButton(frame: CGRect(x: headerView.frame.size.width - 100, y: 8, width: 100, height: 30))
            headerView.backgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
            changeAddressBtn.setTitle("CHANGE", for: UIControlState.normal)
            changeAddressBtn.setTitleColor(Webservice.themeColor, for: UIControlState.normal)
            changeAddressBtn.addTarget(self, action: #selector(self.changeAddress), for: UIControlEvents.touchUpInside)
            headerView.addSubview(changeAddressBtn)
            
            let infoLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 200, height: 30))
            infoLabel.text = "Delivery Address"
            headerView.addSubview(infoLabel)
            
            return headerView
        }else if section == 1 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 30.0))
            let infoLabel = UILabel(frame: CGRect(x: 8, y: 8, width: 300, height: 30))
            infoLabel.text = prescription
            headerView.addSubview(infoLabel)
            
            return headerView
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
           return 30.0
        }else{
            return 45.0
        }
    }
    
    
    
}
