//
//  SearchMedicineViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 30/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Alamofire
import NVActivityIndicatorView
import SwiftyJSON
import Toast_Swift

struct medicineSearch {
    var pname:String!
    var discountedPrice:String!
    var MRP:Double!
    var manufacturer:String!
    var meta:String!
    var discountPercentageStr:String!
    var id:String!
    var imgUrl:String!
}

class SearchMedicineViewController: UIViewController,SelectAddressDelegate {
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var otpText: UITextField!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    var autoCompleteView:AutoComplete!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    let itemsPerRow:CGFloat = 3
    var request:DataRequest!
    var fromSideMenu = "false"
    
    struct Category {
        var id:String!
        var imageUrl:String!
        var name:String!
    }
    
    var categoryArr:[Category] = []
    
    var medicineArr:[medicineSearch] = []
    
    var imageArr:[String] = ["Vitamins","Weight","Stomoch","Diabetes","WeightLossMgt","Ayurveda","PersonalCare","WeightLossMgt1","SexualWellness"]
    var titleArr:[String] = ["Vitamins & Supplements","Weight Management","Stomach Care","Diabetes Monitoring" ,"Herbal skin Care","Ayurveda","Personal Care","Sexual Health","Bone & Joint Care"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Search Medicine"
        self.searchText.delegate = self
        
        self.uploadBtn.layer.cornerRadius = 5
        let cartbutton = UIBarButtonItem(image: UIImage(named: "shopping-cart"), style: .plain, target: self, action: #selector(self.cartAction(_:)))
        self.navigationItem.rightBarButtonItem  = cartbutton
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
        self.getPopularCategory()
        
        self.otpView.isHidden = true
        
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
        }
        
        
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func cartAction(_ sender: UIBarButtonItem) {
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "CartViewController") as! CartViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func uploadAction(_ sender: UIButton) {
        
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "UploadPrescriptionViewController") as! UploadPrescriptionViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func addAutoCompleteView() {
        autoCompleteView = AutoComplete(frame: CGRect(x: 15, y: 120, width: self.view.frame.size.width - 30, height: 280))
        autoCompleteView.delegate = self
        autoCompleteView.medicineArr = self.medicineArr
        autoCompleteView.layer.cornerRadius = 5
        autoCompleteView.dropShawdow()
        autoCompleteView.tableView.reloadData()
        self.view.addSubview(autoCompleteView)
    }
    
    func selectedIndex(index: Int) {
        autoCompleteView.removeFromSuperview()
        self.view.endEditing(true)
        self.nextViewWithStr(str: medicineArr[index].pname)
        print(index)
    }
    
    func nextViewWithStr(str:String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MedicineViewController") as! MedicineViewController
        nextView.searchStr = str
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func nextView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MedicineViewController") as! MedicineViewController
        nextView.searchStr = searchText.text!
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    
    func getPopularCategory() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        
        let location = String(User.location!.map {
            $0 == " " ? "+" : $0
        })
        
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getPopularCategory + location, headers: headers, { (json) in
            print(json)
            
            self.categoryArr = []
            if json["status"].stringValue == "0" {
                for data in json["result"].arrayValue {
                    self.categoryArr.append(Category.init(
                        id: data["id"].stringValue,
                        imageUrl: data["app_images"]["thumbnail"].stringValue,
                        name: data["name"].stringValue
                    ))
                }
                ShowLoader.stopLoader()
                self.collectionView.reloadData()
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
        
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
        
        let location = String(User.location!.map {
            $0 == " " ? "+" : $0
        })
        
        request =  Alamofire.request(Webservice.searchProduct + "\(name)&pageSize=15&city=\(location)&pageNumber=0&type=product", method: .get, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                    self.medicineArr = []
                    for data in json["result"].arrayValue {
                        print(data)
                        if data["prescriptionRequired"].stringValue == "false" {
                            self.medicineArr.append(medicineSearch.init(
                                pname: data["name"].stringValue,
                                discountedPrice: data["discounted_price"].stringValue,
                                MRP: data["mrp"].doubleValue,
                                manufacturer: data["manufacturer"].stringValue,
                                meta: data["meta"].stringValue,
                                discountPercentageStr: data["discount_percent_str"].stringValue,
                                id: data["id"].stringValue,
                                imgUrl: data["imgUrl"].stringValue
                            ))
                        }
                    }
                    
                    if self.autoCompleteView != nil {
                        self.autoCompleteView.removeFromSuperview()
                    }
                    
                    self.addAutoCompleteView()
                    //self.tableView.reloadData()
                    
                    
                    
                }
            case .failure(let error):
                print(error)
            }
        }
    }
        
        //MARK:- Login with 1 MG
        
        
        func signUpWith1MG(){
            let parameter:[String:String] = [
                "email": User.emailId,
                "name": User.firstName + " " + User.lastName,
                "password": "patient@" + User.patientId,
                "phone_number": User.mobileNumber,
                "cart_oos":"true"
            ]
            
            let headers:[String:String] = [
                "Accept":"application/vnd.healthkartplus.v7+json",
                "HKP-Platform":"HealthKartPlus-9.0.0-Android",
                "x-api-key":"pansonic123",
                ]
            
            print(parameter)
            
            if  !Reachability.isConnectedToNetwork() {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                    
                })
                
                return
            }
            
             
            ShowLoader.startLoader(view: self.view)
            
            DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpWith1MG, dataDict: parameter, headers: headers, { (json) in
                print(json)
                ShowLoader.stopLoader()
                
                
                if json["status"].stringValue == "success" {
                    self.otpView.isHidden = false
                }else if json["status"].stringValue == "1" {
                    self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
                    if json["errors"]["errs"][0]["msg"].stringValue.contains("already registered") {
                        self.loginWithOTP()
                    }
                }
                
                
            }) { (error) in
                print(error)
                self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
                ShowLoader.stopLoader()
            }
        }
    
    func loginWithOTP()  {
        let parameter:[String:String] = [
            "username": User.mobileNumber
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.loginWithOTP, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["status"].stringValue == "success" {
                self.otpView.isHidden = false
            }else if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        otpView.isHidden = true
    }
    
    @IBAction func okAction(_ sender: UIButton) {
        
        if otpText.text!  == "" {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please enter OTP.")
            return
        }
        
        if otpText.text!.count  != 6 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "OTP should be 6 digits.")
            return
        }
        
        let parameter:[String:String] = [
            "verification_token": otpText.text!,
            "password": "patient@" + User.patientId,
            "username": User.mobileNumber,
            "return_token":"true"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            ]
        
        print(parameter)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.verifyToken, dataDict: parameter, headers: headers, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["status"].stringValue == "1" {
                self.view.makeToast(json["errors"]["errs"][0]["msg"].stringValue, duration: 3.0, position: .bottom)
            }else  if json["status"].stringValue == "0" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                self.otpView.isHidden = true
                User.oneMGAuthenticationToken = json["result"]["authToken"].stringValue
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
                self.register1MGPrarmacyToken(token: User.oneMGAuthenticationToken)
            }
            
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    
    func register1MGPrarmacyToken(token:String) {
        let parameter:[String:String] = [
            "Value1":User.patientId,
            "Value2":token
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGpharmacyToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMgPharmacy = "true"
                User.oneMGAuthenticationToken = token
                
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgPharmacy")
                UserDefaults.standard.setValue(User.oneMGAuthenticationToken, forKey: "oneMGAuthenticationToken")
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchMedicineViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchMedicineCell", for: indexPath) as! SearchMedicineCell
        
      //  cell.medicineLabel.text = titleArr[indexPath.row]
        //cell.medicineImageView.image = UIImage(named: imageArr[indexPath.row])
        cell.medicineLabel.text = self.categoryArr[indexPath.row].name
        cell.medicineImageView.sd_setImage(with: URL(string: self.categoryArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "Medicine"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
            return
        }
        
        self.nextViewWithStr(str: self.categoryArr[indexPath.row].name)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (10 ) * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        var heightPerItem:CGFloat!
        
        
         heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 50)/4)
        
        return CGSize(width: widthPerItem , height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}

extension SearchMedicineViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.nextView()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        self.getSearchData(name: textField.text! + string)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if User.oneMgPharmacy == "false" {
            self.signUpWith1MG()
            return false
        }
        
        return true
    }
    
}

