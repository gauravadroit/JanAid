//
//  MedicineViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Toast_Swift
import NVActivityIndicatorView

class MedicineViewController: UIViewController {

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchText: UITextField!
    var request:DataRequest!
    var addTocartView:AddToCart!
    
    @IBOutlet weak var notificationLabel: UILabel!
    
    struct medicine {
        var pname:String!
        var discountedPrice:String!
        var MRP:Double!
        var manufacturer:String!
        var meta:String!
        var discountPercentageStr:String!
        var id:String!
        var imgUrl:String!
        var avaliablity:String!
        var prescriptionRequired:String!
        var oprice:String!
        var sellingUnit:String!
        
    }
    
    var medicineArr:[medicine] = []
    var searchStr:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MEDICINES"
        self.navigationController?.navigationBar.isHidden = true
       // self.tabBarController?.tabBar.isHidden = true
        self.notificationLabel.layer.cornerRadius = self.notificationLabel.frame.size.height/2
        self.notificationLabel.layer.masksToBounds = true
        self.notificationLabel.backgroundColor = UIColor.red
        self.notificationLabel.isHidden = true
    
        self.searchText.delegate = self
        self.searchView.backgroundColor = UIColor.clear
        self.searchView.layer.cornerRadius = 5
        self.searchView.layer.borderColor = UIColor.white.cgColor
        self.searchView.layer.borderWidth = 1
        
        self.tableView.separatorStyle = .none
        
        self.searchText.text = searchStr
        self.getSearchData(name: searchStr)
        
    //    self.getHash()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        //self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = false
    }
    @IBAction func backAction(_ sender: UIButton) {
        self.navigationController?.navigationBar.isHidden = false
        //self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
    
    func getSearchData(name:String) {
        
        
        if request != nil {
            request.cancel()
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        let replaced = String(name.map {
            $0 == " " ? "+" : $0
        })
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        request =  Alamofire.request(Webservice.searchProduct + "\(replaced)&pageSize=15&city=\(User.location!)&pageNumber=0&type=product", method: .get, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    //self.notificationLabel.isHidden = false
                   // self.notificationLabel.text = json["totalRecordCount"].stringValue
                    self.medicineArr = []
                    for data in json["result"].arrayValue {
                        print(data)
                        self.medicineArr.append(medicine.init(
                            pname: data["name"].stringValue,
                            discountedPrice: data["discounted_price"].stringValue,
                            MRP: data["mrp"].doubleValue,
                            manufacturer: data["manufacturer"].stringValue,
                            meta: data["packSizeLabel"].stringValue,
                            discountPercentageStr: data["discount_percent_str"].stringValue,
                            id: data["id"].stringValue,
                            imgUrl: data["imgUrl"].stringValue,
                            avaliablity: data["available"].stringValue,
                            prescriptionRequired: data["prescriptionRequired"].stringValue,
                            oprice: data["oPrice"].stringValue,
                            sellingUnit: data["su"].stringValue
                        ))
                    }
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    self.tableView.reloadData()
                    
                    
                    
                }
            case .failure(let error):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                print(error)
            }
        }
        
    }
    

   /* func getHash() {
        let parameter = [
            "api_key":"pansonic123",
            "user_id":"2504",
            "name": User.firstName,
            "redirect_url":"https://stag.1mg.com/",
            "source":"panasonic",
            "contact_number":"8585858585",
            "email":"gaurav.saini@adroit.com"
            ]
        
        DataProvider.sharedInstance.getDataUsingPost(path: Webservice.getHash, dataDict: parameter, { (json) in
            print(json)
            
            if json["hash"].stringValue != "" {
                let url = URL(string: Webservice.showMedicine + json["hash"].stringValue)
                let req = URLRequest(url: url!)
                self.webView.delegate = self
                self.webView.loadRequest(req)
            }
            
        }) { (error) in
            print(error)
        }
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @objc func addToCartAction(sender:UIButton) {
        self.addTocartView = AddToCart(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        
        if medicineArr[sender.tag].discountedPrice != "" {
            self.addTocartView.discountedPriceLabel.text = "₹" + medicineArr[sender.tag].discountedPrice
            self.addTocartView.discountconstraint.constant = 8.0
        }else{
            self.addTocartView.discountedPriceLabel.text =  ""
            self.addTocartView.discountconstraint.constant = 0.0
        }
        
        self.addTocartView.mrpLabel.text = "MRP: ₹" + String(format: "%.1f",medicineArr[sender.tag].MRP)
        self.addTocartView.nameLabel.text = medicineArr[sender.tag].pname
        self.addTocartView.quantityDEscriptionLabel.text = medicineArr[sender.tag].meta
        self.addTocartView.cancelBtn.addTarget(self, action:#selector(self.removeCustomView), for: .touchUpInside)
        self.addTocartView.minusBtn.tag = sender.tag
        self.addTocartView.plusBtn.tag = sender.tag
        self.addTocartView.minusBtn.addTarget(self, action:#selector(self.decrement(sender:)), for: .touchUpInside)
        self.addTocartView.plusBtn.addTarget(self, action:#selector(self.increment(sender:)), for: .touchUpInside)
        self.addTocartView.confirmBtn.tag = sender.tag
        self.addTocartView.confirmBtn.addTarget(self, action: #selector(self.addCartAction(sender:)), for: .touchUpInside)
        
        UIApplication.shared.keyWindow?.addSubview(self.addTocartView)
    }
    
    @IBAction func cartAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func removeCustomView(){
        self.addTocartView.removeFromSuperview()
    }
    
    @objc func increment(sender: UIButton){
        var value:Int = Int(self.addTocartView.quantityLabel.text!)!
        value = value + 1
        self.addTocartView.quantityDEscriptionLabel.text = String(value) + "x " + medicineArr[sender.tag].meta
        self.addTocartView.quantityLabel.text! = String(value)
    }
    
    @objc func decrement(sender: UIButton) {
        if self.addTocartView.quantityLabel.text! == "1" {
            
        }else{
            var value:Int = Int(self.addTocartView.quantityLabel.text!)!
            value = value - 1
            self.addTocartView.quantityDEscriptionLabel.text = String(value) + "x " + medicineArr[sender.tag].meta
            self.addTocartView.quantityLabel.text! = String(value)
        }
    }
    
    @objc func addCartAction(sender:UIButton) {
        
        
       let qty = Int(self.addTocartView.quantityLabel.text!)! * Int(self.medicineArr[sender.tag].sellingUnit)!
        let parameter:[String:String] = [
            "qty": String(qty),
            "cart_oos":"true",
            "productId":self.medicineArr[sender.tag].id,
           // "productId":"jghfj",
            "city":User.location!
            ]
        
        print(parameter)
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization":User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
    
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.addCart, dataDict: parameter, headers: headers, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["status"].intValue == 0 {
                self.notificationLabel.isHidden = false
                self.notificationLabel.text = json["totalRecordCount"].stringValue
                self.view.makeToast("Medicine added successfully.", duration: 3.0, position: .bottom)
                self.addTocartView.removeFromSuperview()
            }else{
              //  self.view.makeToast("This is a piece of toast", duration: 3.0, position: .bottom, style: style)
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
                
            }
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    

}

extension MedicineViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.medicineArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedicineCell", for: indexPath) as! MedicineCell
        
        cell.nameLabel.text = medicineArr[indexPath.row].pname
        
        if medicineArr[indexPath.row].discountedPrice != "" {
            cell.mrpLabel.text = "MRP: ₹" + medicineArr[indexPath.row].discountedPrice
            cell.fixedMrpLabel.text = "MRP: ₹" + String(format: "%.1f",medicineArr[indexPath.row].MRP)
            cell.discountLabel.text = medicineArr[indexPath.row].discountPercentageStr
            cell.fixedMrpLabel.isHidden = false
            cell.discountLabel.isHidden = false
        }else{
            cell.mrpLabel.text = "MRP: ₹" + String(format: "%.1f",medicineArr[indexPath.row].MRP)
            cell.fixedMrpLabel.isHidden = true
            cell.discountLabel.isHidden = true
        }
        cell.manufacturerLabel.text = medicineArr[indexPath.row].manufacturer
        cell.productQuantitylabel.text = medicineArr[indexPath.row].meta
        
        if medicineArr[indexPath.row].prescriptionRequired == "true" || medicineArr[indexPath.row].avaliablity == "false"{
            if medicineArr[indexPath.row].avaliablity == "false" {
                 cell.addTocardBtn.setTitle("Out Of Stock", for: .normal)
            }
            
            cell.addTocardBtn.isEnabled = false
        }else{
            if medicineArr[indexPath.row].avaliablity == "true" {
                cell.addTocardBtn.setTitle("ADD TO CART", for: .normal)
            }
            cell.addTocardBtn.isEnabled = true
        }
        
        cell.addTocardBtn.tag = indexPath.row
        cell.addTocardBtn.addTarget(self, action: #selector(self.addToCartAction(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
}

extension MedicineViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.getSearchData(name: textField.text!)
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
}
