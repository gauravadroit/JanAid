//
//  LabsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SwiftyJSON
import NVActivityIndicatorView
import Toast_Swift

class LabsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var webView: UIWebView!
    var fromSideMenu = "false"
    var headerTitle:[String] = ["Popular Tests","Health Packages Categories","Featured Packages","Featured Labs"]
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectLabBtn: UIButton!
    var category:String!
    
    struct popularTest {
        var name:String!
        var id:String!
        var subName:String!
        var category:String!
        var type:String!
    }
    var popularTestArr:[popularTest] = []
    var healthCategoryArr:[HealthCategory] = []
    var packageArr:[FeaturedPackage] = []
    var selectedTestArr:[String] = []
    
    struct sposnored {
        var name:String!
        var logo:String!
        var id:String!
        var category:String!
    }
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var textBackView: UIView!
    var sposnoredArr:[HealthCategory] = []
    
    var totalData:[[Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Labs & Diagnostics"
        self.tableView.separatorStyle = .none
       // self.tabBarController?.tabBar.isHidden = true
       // self.getHash()
        
        self.textBackView.layer.cornerRadius = 5
        self.textBackView.layer.borderColor = UIColor.white.cgColor
        self.textBackView.layer.borderWidth = 1
        
        searchTextField.delegate = self
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
        //self.getLabTest()
        if User.oneMGLab == "false" {
            self.signUpwith1MG()
        }else{
            self.getLabTest()
        }
       // "authentication_token" : "e35863c7-5baf-4eac-9394-f828eb6dec5c",
    }
    
    
    func signUpwith1MG() {
        let header:[String:String] = [
            "Content-Type":"application/x-www-form-urlencoded",
            "THIRD-PARTY":"panasonic"
        ]
        
        let parameter:[String:String] = [
            "api_key":"98cf1ce6-a4b1-4fe4-94ab-a4d1a9dc0cb3", //live
            //"api_key":"12345678-1234-5678-1234-567812345678", // staging
            "user_id":User.emailId
        ]
        
        print(parameter)
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.signUpwithLab, dataDict: parameter, headers: header, { (json) in
            print(json)
            
            if json["authentication_token"].stringValue != "" {
                self.register1MGLabToken(token: json["authentication_token"].stringValue)
            }
            
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    func register1MGLabToken(token:String) {
        let parameter:[String:String] = [
            "Value1":User.patientId,
            "Value2":token
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPut(path: Webservice.save1MGLabToken, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Status"].stringValue == "true" {
                self.view.makeToast("Successful", duration: 3.0, position: .bottom)
                User.oneMGLab = "true"
                User.oneMGLabToken = token
                UserDefaults.standard.setValue(User.oneMgPharmacy, forKey: "ISRegisteredOn1mgLAB")
                UserDefaults.standard.setValue(User.oneMGLabToken, forKey: "oneMGLabToken")
                self.getLabTest()
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if selectedTestArr.count > 0 {
            self.selectLabBtn.isHidden = false
            tableViewBottomConstraint.constant = 50
        }else{
            self.selectLabBtn.isHidden = true
            tableViewBottomConstraint.constant = 0
        }
    }
    
    @IBAction func selectLabAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LabListViewController") as! LabListViewController
        nextView.selectedTestArr = self.selectedTestArr
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    func newScreenAction() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "SearchLabsViewController") as! SearchLabsViewController
        nextview.searchText = searchTextField.text!
        self.navigationController?.pushViewController(nextview, animated: true)
    }
    
    
   
    func getLabTest() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGLabToken
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getPopularTest + User.location! + "&popular_test_size=5&packages_page_size=3", headers: headers, { (json) in
            print(json)
            
            for data in json["popular_tests"].arrayValue {
                self.popularTestArr.append(popularTest.init(
                    name: data["name"].stringValue,
                    id: data["id"].stringValue,
                    subName: data["sub_name"].stringValue,
                    category: data["category"].stringValue,
                    type: data["type"].stringValue
                ))
            }
            
            for data in json["categories"].arrayValue {
                self.healthCategoryArr.append(HealthCategory.init(
                    tagName: data["tag_name"].stringValue,
                    name: data["name"].stringValue,
                    image: data["category_image"].stringValue
                ))
            }
            
            for data in json["featured_packages"].arrayValue {
                var accreditationArr:[String] = []
                
                for val in data["accreditation"].arrayValue {
                    accreditationArr.append(val["name"].stringValue)
                }
                
                self.packageArr.append(FeaturedPackage.init(
                    offeredPrice: data["new_price_info"]["final_offered_price"].stringValue,
                    discount: data["new_price_info"]["discount_amount"].stringValue,
                    mrp: data["new_price_info"]["mrp"].stringValue,
                    discountPercentage: data["new_price_info"]["discount_percent"].stringValue,
                    testName: data["test"]["name"].stringValue,
                    testId: data["test"]["id"].stringValue,
                    testCount: data["test"]["composition_count"].stringValue,
                    labName: data["lab"]["name"].stringValue,
                    labId: data["lab"]["id"].stringValue,
                    rating: data["lab"]["rating"].stringValue,
                    accreditationArr: accreditationArr
                ))
            }
            
            for data in json["sponsored_labs"].arrayValue {
               /* self.sposnoredArr.append(sposnored.init(
                    name: data["name"].stringValue,
                    logo:  data["logo"].stringValue,
                    id:  data["id"].stringValue,
                    category:  data["category"].stringValue
                ))*/
                
                self.sposnoredArr.append(HealthCategory.init(
                    tagName: data["name"].stringValue,
                    name: data["name"].stringValue,
                    image: data["logo"].stringValue
                ))
                
            }
            
            self.totalData = [self.popularTestArr,["o"],self.packageArr, ["o"]]
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }

    
    @objc func addTocartAction(sender:UIButton) {
        let headers:[String:String] = [
           // "Accept":"application/vnd.healthkartplus.v7+json",
            //"HKP-Platform":"HealthKartPlus-9.0.0-Android",
            //"X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            //"x-api-key":"pansonic123",
            "Content-Type":"application/x-www-form-urlencoded",
            "Authorization": "dba63911-852d-4281-a720-11b816facc07"
        ]
        
        guard let cell = sender.superview?.superview as? FeaturedPackageCell else {
            return
        }
        let indexPath = tableView.indexPath(for: cell)
       
        
        let parameter:[String:Any] = [
            "skus":[
                [
                    "test_id": self.packageArr[(indexPath?.row)!].testId,
                    "lab_id": self.packageArr[(indexPath?.row)!].labId
                ]
            ],
            "city": User.location!
        ]
        
       let para = JSON(parameter)
        print(para)
       // let  jsonData = try? JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
        //self.httpPost(jsonData: jsonData!)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPutWithJson(path: Webservice.addLabToCart, dataDict: parameter, headers: headers, { (json) in
            print(json)
        }) { (error) in
            print(error)
        }
        
    }
    
    
   /* func httpPost(jsonData: Data) {
        if !jsonData.isEmpty {
            
            let headers:[String:String] = [
                "Accept":"application/vnd.healthkartplus.v7+json",
                "HKP-Platform":"HealthKartPlus-9.0.0-Android",
                "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
                "x-api-key":"pansonic123",
                "Content-Type":"application/x-www-form-urlencoded",
                "Authorization": User.oneMGAuthenticationToken
            ]
            
            let url = URL(string: Webservice.addLabToCart)!
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
          //  request.allHTTPHeaderFields = headers
            
            request.addValue("dba63911-852d-4281-a720-11b816facc07", forHTTPHeaderField: "Authorization")
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.getAllTasks { (openTasks: [URLSessionTask]) in
                NSLog("open tasks: \(openTasks)")
            }
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: { (responseData: Data?, response: URLResponse?, error: Error?) in
                NSLog("\(response)")
            })
            task.resume()
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

}

extension LabsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.totalData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.totalData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopularTestCell", for: indexPath) as! PopularTestCell
            cell.nameLabel.text = self.popularTestArr[indexPath.row].name
            cell.subNameLabel.text = self.popularTestArr[indexPath.row].subName
            
            if self.selectedTestArr.contains(self.popularTestArr[indexPath.row].id) {
                cell.selectView.image = UIImage(named: "roundchecked")
            }else{
                cell.selectView.image = UIImage(named: "roundunchecked")
            }
            
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeaturedPackageCell", for: indexPath) as! FeaturedPackageCell
            cell.mrplabel.text = "₹" + packageArr[indexPath.row].mrp
            cell.offeredPriceLabel.text = "₹" + packageArr[indexPath.row].offeredPrice
            cell.packageNameLabel.text = packageArr[indexPath.row].testName
            cell.labNameLabel.text = packageArr[indexPath.row].labName
            cell.discountBtn.setTitle(packageArr[indexPath.row].discountPercentage + " % OFF", for: .normal)
            cell.ratingLabel.text = "  \(packageArr[indexPath.row].rating!)  "
            cell.testInfoLabel.text = "Includes \(packageArr[indexPath.row].testCount!) Tests"
            cell.addTocartBtn.addTarget(self, action: #selector(self.addTocartAction(sender:)), for: .touchUpInside)
            cell.certificationLabel.text = packageArr[indexPath.row].accreditationArr.joined()
            cell.selectionStyle = .none
            return cell
        }else if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HealthPackageCategoryCell", for: indexPath) as! HealthPackageCategoryCell
            cell.showCategories(category: self.sposnoredArr)
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "HealthPackageCategoryCell", for: indexPath) as! HealthPackageCategoryCell
            cell.showCategories(category: self.healthCategoryArr)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return headerTitle[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if self.category != nil {
                
                if self.category !=  popularTestArr[indexPath.row].category {
                        self.view.makeToast("you select differt category.", duration: 3.0, position: .bottom)
                        self.category = popularTestArr[indexPath.row].category
                        selectedTestArr = []
                }
                
            }else{
                self.category = popularTestArr[indexPath.row].category
            }
            
            if self.selectedTestArr.contains(popularTestArr[indexPath.row].id) {
                let index = selectedTestArr.index(of: popularTestArr[indexPath.row].id)
                selectedTestArr.remove(at: index!)
            }else{
                selectedTestArr = []
                Lab.labType = popularTestArr[indexPath.row].category
                selectedTestArr.append(self.popularTestArr[indexPath.row].id)
            }
            
            tableView.reloadData()
            
            if selectedTestArr.count > 0 {
                self.selectLabBtn.isHidden = false
                tableViewBottomConstraint.constant = 50
            }else{
                 self.selectLabBtn.isHidden = true
                tableViewBottomConstraint.constant = 0
            }
        }
    }
    
}

extension LabsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.newScreenAction()
        return true
    }
    
}

