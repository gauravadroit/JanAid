//
//  SearchLabsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
class SearchLabsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var searchText:String!
    var selectedTestArr:[String] = []

    struct testSuggestion {
        var name:String!
        var subName:String!
        var id:String!
        var category:String!
        var type:String!
    }
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectLabBtn: UIButton!
    
    var testSuggestionArr:[testSuggestion] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        self.selectLabBtn.addTarget(self, action: #selector(self.selectLabAction(_:)), for: .touchUpInside)
        self.getSearchedLabs()
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

  
    func getSearchedLabs() {
        let headers:[String:String] = [
        "Accept":"application/vnd.healthkartplus.v7+json",
        "HKP-Platform":"HealthKartPlus-9.0.0-Android",
        "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
        "x-api-key":"pansonic123",
        "Authorization": User.oneMGAuthenticationToken
        ]
        
        let replaced = String(searchText.map {
            $0 == " " ? "+" : $0
        })
        
        let location = String(User.location!.map {
            $0 == " " ? "+" : $0
        })
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getSearchTest + location +  "&search_text=" + replaced, headers: headers, { (json) in
            print(json)
            for data in json.arrayValue {
                self.testSuggestionArr.append(testSuggestion.init(
                    name: data["name"].stringValue,
                    subName:data["sub_name"].stringValue,
                    id: data["id"].stringValue,
                    category: data["category"].stringValue,
                    type: data["type"].stringValue
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SearchLabsViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.testSuggestionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PopularTestCell", for: indexPath) as! PopularTestCell
        cell.nameLabel.text = self.testSuggestionArr[indexPath.row].name
        cell.subNameLabel.text = self.testSuggestionArr[indexPath.row].subName
        if self.selectedTestArr.contains(self.testSuggestionArr[indexPath.row].id) {
            cell.selectView.image = UIImage(named: "roundchecked")
        }else{
            cell.selectView.image = UIImage(named: "roundunchecked")
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
            if self.selectedTestArr.contains(self.testSuggestionArr[indexPath.row].id) {
                let index = selectedTestArr.index(of: self.testSuggestionArr[indexPath.row].id)
                selectedTestArr.remove(at: index!)
            }else{
                selectedTestArr = []
                Lab.labType = testSuggestionArr[indexPath.row].category
                selectedTestArr.append(self.testSuggestionArr[indexPath.row].id)
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
