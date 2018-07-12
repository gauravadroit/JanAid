//
//  ProfileViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ProfileViewController: UIViewController {

    @IBOutlet weak var patientCodeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var motherLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var locationBtn: UIBarButtonItem!
    
    struct member {
        var firstName:String = ""
        var lastName:String = ""
        var gender:String = ""
        var mobile:String = ""
        var patientId:String = ""
        var patientCode:String = ""
        var relation:String = ""
    }
    
    var memberArr:[member] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        backgroundView.layer.cornerRadius = 5
        //backgroundView.layer.borderWidth = 1
        //backgroundView.layer.borderColor = UIColor.lightGray.cgColor
        //User.patientId = "1092"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        backgroundView.dropShawdow()
        self.getUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getMember()
         self.tabBarController?.tabBar.isHidden = false
        if let temp = UserDefaults.standard.string(forKey: "location") {
            print(temp)
            User.location = temp
            locationBtn.title = temp
        }else{
            User.location = "Gurgaon"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func locationAction(_ sender: UIBarButtonItem) {
        self.tabBarController?.tabBar.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func addMemberAction(_ sender: UIButton) {
        self.tabBarController?.tabBar.isHidden = true
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddMemberViewController") as! AddMemberViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getUserProfile() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.getProfile + User.patientId, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
                let data = json["Data"][0].dictionaryValue
                self.nameLabel.text = (data["FirstName"]?.stringValue)! + " " + (data["LastName"]?.stringValue)! + " (" + (data["GenderName"]?.stringValue)! + ")"
                self.mobileLabel.text = (data["MobileNumber"]?.stringValue)!
                self.motherLabel.text = (data["MotherName"]?.stringValue)!
                self.patientCodeLabel.text = (data["PatientCode"]?.stringValue)!
                User.mobileNumber = (data["MobileNumber"]?.stringValue)!
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
    func getMember() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingGet(path: Webservice.getMember + User.patientId, { (json) in
            print(json)
            
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            if json["Status"].stringValue == "true" {
                    self.memberArr = []
                for data in json["Data"].arrayValue {
                    self.memberArr.append(member.init(
                        firstName: data["FirstName"].stringValue,
                        lastName: data["LastName"].stringValue,
                        gender: data["GenderName"].stringValue,
                        mobile: data["MobileNumber"].stringValue,
                        patientId: data["PatientID"].stringValue,
                        patientCode: data["PatientCode"].stringValue,
                        relation: data["RelationName"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
                
            }
            
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }
    
   @objc func deleteMamber(sender:UIButton) {
        
        let parameter = [
            "FlagNo":"2",
            "PatientID":memberArr[sender.tag].patientId,
            "StatusID":"2"
        ]
        
    if  !Reachability.isConnectedToNetwork() {
        Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            
        })
        
        return
    }
    
    let activityData = ActivityData()
    NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.registartion, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Status"].stringValue == "true" {
                self.memberArr.remove(at: sender.tag)
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
   @objc func editMember(sender:UIButton) {
        self.tabBarController?.tabBar.isHidden = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "AddMemberViewController") as! AddMemberViewController
        nextView.editGender = self.memberArr[sender.tag].gender
        nextView.editRelation = self.memberArr[sender.tag].relation
        nextView.editFirstName = self.memberArr[sender.tag].firstName
        nextView.editLastName = self.memberArr[sender.tag].lastName
        nextView.editPatientId = self.memberArr[sender.tag].patientId
        nextView.edit = true
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

extension ProfileViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as! MemberCell
        cell.nameLabel.text = memberArr[indexPath.row].firstName + " " + memberArr[indexPath.row].lastName + " (" + memberArr[indexPath.row].gender + ")"
        
        cell.contactLabel.text = memberArr[indexPath.row].mobile
        cell.relationLabel.text = memberArr[indexPath.row].relation
        cell.patientCodeLabel.text = memberArr[indexPath.row].patientCode
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteMamber(sender:)), for: UIControlEvents.touchUpInside)
        cell.editBtn.tag = indexPath.row
        cell.editBtn.addTarget(self, action: #selector(self.editMember(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
}

