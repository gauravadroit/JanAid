//
//  CartViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 24/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


struct medicine {
    var pname:String!
    var discountedPrice:String!
    var MRP:Double!
    var manufacturer:String!
    var meta:String!
    var discountPercentageStr:String!
    var id:String!
    var imgUrl:String!
    var qty:String!
    var orderId:String!
    var sellingUnit:String!
}

class CartViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var emptyCartView: UIView!
    
    
    var cartArr1:[medicine] = []
    var cartArr2:[medicine] = []
    var cartArr:[[medicine]] = []
    var cartTitleArr:[String] = []
    
    var actualPrice:String!
    var totalPrice:String!
    var discount:String!
    var shiping:String!
    //var prescriptionText:String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.emptyCartView.isHidden = true
        self.navigationController?.navigationBar.isHidden = false
        self.getCartInfo()
    }
    
    
    
    @IBAction func medicineAction(_ sender: UIButton) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers
        for aViewController in viewControllers {
            if aViewController is SearchMedicineViewController {
                self.navigationController!.popToViewController(aViewController, animated: true)
            }
        }
    }
    
    
    @IBAction func checkOutAction(_ sender: UIButton) {
        if totalPrice == "0" {
            return
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "OrderCartViewController") as! OrderCartViewController
        //nextView.medicineArr = cartArr2
         nextView.medicineArr = cartArr1
        nextView.totalPrice = totalPrice
        nextView.actualPrice = actualPrice
        nextView.discount = discount
        nextView.shipingPrice = shiping
        nextView.prescription = cartTitleArr[0]
        
       
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getCartInfo() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        print(headers)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getCart + User.location!, headers: headers, { (json) in
            print(json)
            
            let orderItemGroup = json["result"]["orderItemGroups"].arrayValue
            self.priceLabel.text =  "₹" +  String(json["result"]["discountedMrp"].floatValue)
            
            self.discount = String(json["result"]["totalSavings"].floatValue)
            self.totalPrice = String(json["result"]["totalAmt"].floatValue)
            self.actualPrice = String(json["result"]["actualAmnt"].floatValue)
            self.shiping = String(json["result"]["shippingAmt"].floatValue)
            
            if orderItemGroup.count == 0 {
                 self.emptyCartView.isHidden = false
                
                 NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                return
            }
            
            //print(orderItemGroup)
            if orderItemGroup[0]["title"].stringValue != "" {
                self.cartTitleArr.append(orderItemGroup[0]["title"].stringValue)
            }
            
          /*  if orderItemGroup[1]["title"].stringValue != "" {
                self.cartTitleArr.append(orderItemGroup[1]["title"].stringValue)
            }*/
            
            for data in orderItemGroup[0]["orderItems"].arrayValue {
                print(data)
              
                self.cartArr1.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: String(data["offeredPrice"].floatValue),
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: String(data["offeredPrice"].floatValue),
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: String(data["productQuantity"].intValue/data["sellingUnit"].intValue),
                    orderId: data["orderId"].stringValue,
                    sellingUnit: data["sellingUnit"].stringValue
                ))
            }
            
           /* for data in orderItemGroup[1]["orderItems"].arrayValue {
                print(data)
                
                self.cartArr2.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: data["offeredPrice"].stringValue,
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: data["offeredPrice"].stringValue,
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: data["productQuantity"].stringValue,
                    orderId: data["orderId"].stringValue
                ))
            }*/
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
           // self.cartArr = [self.cartArr1,self.cartArr2]
            self.cartArr = [self.cartArr1]
            self.tableView.reloadData()
            
        }) { (error) in
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            print(error)
        }
    }
    
    
    @objc func removeItem(sender:UIButton) {
        guard let cell = sender.superview?.superview?.superview as? CartCell else {
            return
        }
        let indexPath = tableView.indexPath(for: cell)
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        
        //let cart = cartArr[(indexPath?.section)!]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.deleteUsingHeader(path: Webservice.addCart + "/" + cartArr[(indexPath?.section)!][(indexPath?.row)!].id, headers: headers, { (json) in
            print(json)
            
            self.cartArr = []
            self.cartTitleArr = []
            self.cartArr1 = []
            self.cartArr2 = []
            
            let orderItemGroup = json["result"]["orderItemGroups"].arrayValue
            self.priceLabel.text =  "₹" +  String(json["result"]["discountedMrp"].floatValue)
            
            self.discount = String(json["result"]["totalSavings"].floatValue)
            self.totalPrice = String(json["result"]["totalAmt"].floatValue)
            self.actualPrice = String(json["result"]["actualAmnt"].floatValue)
            self.shiping = String(json["result"]["shippingAmt"].floatValue)
            
            if orderItemGroup.count == 0 {
                self.tableView.reloadData()
                self.emptyCartView.isHidden = false
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                return
            }
            
            
            
            
            
            print(orderItemGroup)
            self.cartTitleArr.append(orderItemGroup[0]["title"].stringValue)
            // self.cartTitleArr.append(orderItemGroup[1]["title"].stringValue)
            
            for data in orderItemGroup[0]["orderItems"].arrayValue {
                print(data)
                
                self.cartArr1.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: String(data["offeredPrice"].floatValue),
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: String(data["offeredPrice"].floatValue),
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: String(data["productQuantity"].intValue/data["sellingUnit"].intValue),
                    orderId: data["orderId"].stringValue,
                    sellingUnit: data["sellingUnit"].stringValue
                ))
            }
            
            /* for data in orderItemGroup[1]["orderItems"].arrayValue {
             print(data)
             
             self.cartArr2.append(medicine.init(
             pname: data["productName"].stringValue,
             discountedPrice: data["offeredPrice"].stringValue,
             MRP: data["item_price"].doubleValue,
             manufacturer: data["manuName"].stringValue,
             meta: data["packSizeLabel"].stringValue,
             discountPercentageStr: data["offeredPrice"].stringValue,
             id: data["pid"].stringValue,
             imgUrl: data["url"].stringValue,
             qty: data["productQuantity"].stringValue,
             orderId: data["orderId"].stringValue
             ))
             }*/
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.cartArr = [self.cartArr1]
            //self.cartArr = [self.cartArr1,self.cartArr2]
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    
    @objc func increment(sender:UIButton){
        guard let cell = sender.superview?.superview?.superview as? CartCell else {
            return
        }
        let indexPath = tableView.indexPath(for: cell)
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        let prductQty = Int(cartArr[(indexPath?.section)!][(indexPath?.row)!].qty)!
        let sellingUnit = Int(cartArr[(indexPath?.section)!][(indexPath?.row)!].sellingUnit)!
        let qty = String((prductQty + 1) * sellingUnit )
        
        let parameter:[String:String] = [
            "productQuantity":qty,
            "cart_oos":"true",
            "city":User.location!
        ]
        
        //let cart = cartArr[(indexPath?.section)!]
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.addCart + "/" + cartArr[(indexPath?.section)!][(indexPath?.row)!].id, dataDict: parameter, headers: headers, { (json) in
            print(json)
            
            self.cartArr = []
            self.cartTitleArr = []
            self.cartArr1 = []
            self.cartArr2 = []
            
            let orderItemGroup = json["result"]["orderItemGroups"].arrayValue
            self.priceLabel.text =  "₹" +  String(json["result"]["discountedMrp"].floatValue)
            self.discount = String(json["result"]["totalSavings"].floatValue)
            self.totalPrice = String(json["result"]["totalAmt"].floatValue)
            self.actualPrice = String(json["result"]["actualAmnt"].floatValue)
            self.shiping = String(json["result"]["shippingAmt"].floatValue)
            
            
            print(orderItemGroup)
            self.cartTitleArr.append(orderItemGroup[0]["title"].stringValue)
           // self.cartTitleArr.append(orderItemGroup[1]["title"].stringValue)
            
            for data in orderItemGroup[0]["orderItems"].arrayValue {
                print(data)
            
                self.cartArr1.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: String(data["offeredPrice"].floatValue),
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: String(data["offeredPrice"].floatValue),
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: String(data["productQuantity"].intValue/data["sellingUnit"].intValue),
                    orderId: data["orderId"].stringValue,
                    sellingUnit: data["sellingUnit"].stringValue
                ))
            }
            
           /* for data in orderItemGroup[1]["orderItems"].arrayValue {
                print(data)
                
                self.cartArr2.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: data["offeredPrice"].stringValue,
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: data["offeredPrice"].stringValue,
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: data["productQuantity"].stringValue,
                    orderId: data["orderId"].stringValue
                ))
            }*/
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.cartArr = [self.cartArr1]
            //self.cartArr = [self.cartArr1,self.cartArr2]
            self.tableView.reloadData()
            
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    @objc func decrement(sender:UIButton) {
        guard let cell = sender.superview?.superview?.superview as? CartCell else {
            return
        }
        let indexPath = tableView.indexPath(for: cell)
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        var qty = String(Int(cartArr[(indexPath?.section)!][(indexPath?.row)!].qty)! - 1)
        if qty == "0" {
            return
        }
        
        let prductQty = Int(cartArr[(indexPath?.section)!][(indexPath?.row)!].qty)!
        let sellingUnit = Int(cartArr[(indexPath?.section)!][(indexPath?.row)!].sellingUnit)!
        qty = String((prductQty - 1) * sellingUnit )
        
        let parameter:[String:String] = [
            "productQuantity":qty,
            "cart_oos":"true",
            "city":User.location!
        ]
        
        //let cart = cartArr[(indexPath?.section)!]
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.addCart + "/" + cartArr[(indexPath?.section)!][(indexPath?.row)!].id, dataDict: parameter, headers: headers, { (json) in
            print(json)
            
            self.cartArr = []
            self.cartTitleArr = []
            self.cartArr1 = []
            self.cartArr2 = []
            
            let orderItemGroup = json["result"]["orderItemGroups"].arrayValue
            self.priceLabel.text =  "₹" +  String(json["result"]["discountedMrp"].floatValue)
            self.discount = String(json["result"]["totalSavings"].floatValue)
            self.totalPrice = String(json["result"]["totalAmt"].floatValue)
            self.actualPrice = String(json["result"]["actualAmnt"].floatValue)
            self.shiping = String(json["result"]["shippingAmt"].floatValue)
            
            print(orderItemGroup)
            self.cartTitleArr.append(orderItemGroup[0]["title"].stringValue)
           // self.cartTitleArr.append(orderItemGroup[1]["title"].stringValue)
            
            for data in orderItemGroup[0]["orderItems"].arrayValue {
                print(data)
                
                self.cartArr1.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: String(data["offeredPrice"].floatValue),
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: String(data["offeredPrice"].floatValue),
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: String(data["productQuantity"].intValue/data["sellingUnit"].intValue),
                    orderId: data["orderId"].stringValue,
                    sellingUnit: data["sellingUnit"].stringValue
                ))
            }
            
            /*for data in orderItemGroup[1]["orderItems"].arrayValue {
                print(data)
                
                self.cartArr2.append(medicine.init(
                    pname: data["productName"].stringValue,
                    discountedPrice: data["offeredPrice"].stringValue,
                    MRP: data["item_price"].doubleValue,
                    manufacturer: data["manuName"].stringValue,
                    meta: data["packSizeLabel"].stringValue,
                    discountPercentageStr: data["offeredPrice"].stringValue,
                    id: data["pid"].stringValue,
                    imgUrl: data["url"].stringValue,
                    qty: data["productQuantity"].stringValue,
                    orderId: data["orderId"].stringValue
                ))
            }*/
            
           // self.cartArr = [self.cartArr1,self.cartArr2]
             self.cartArr = [self.cartArr1]
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

extension CartViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return self.cartArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cartArr[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        
        if indexPath.section == 0 {
            cell.medicineMetaLabel.text = self.cartArr1[indexPath.row].meta
            cell.nameLabel.text = self.cartArr1[indexPath.row].pname
            cell.qtyLabel.text = self.cartArr1[indexPath.row].qty
           // cell.mrpLabel.text = "MRP: ₹" + String(format: "%.1f",self.cartArr1[indexPath.row].MRP)
            cell.mrpLabel.text = "MRP: ₹" + self.cartArr1[indexPath.row].discountedPrice
            //cell.removeBtn.tag = indexPath
        }else{
            cell.medicineMetaLabel.text = self.cartArr2[indexPath.row].meta
            cell.nameLabel.text = self.cartArr2[indexPath.row].pname
            cell.qtyLabel.text = self.cartArr2[indexPath.row].qty
           // cell.mrpLabel.text = "MRP: ₹" + String(format: "%.1f",self.cartArr2[indexPath.row].MRP)
             cell.mrpLabel.text = "MRP: ₹" + self.cartArr1[indexPath.row].discountedPrice
        }
        
        cell.removeBtn.addTarget(self, action: #selector(self.removeItem(sender:)), for: UIControlEvents.touchUpInside)
        cell.plusBtn.addTarget(self, action: #selector(self.increment(sender:)), for: UIControlEvents.touchUpInside)
        cell.minusBtn.addTarget(self, action: #selector(self.decrement(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return cartTitleArr[section]
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    
    
}

