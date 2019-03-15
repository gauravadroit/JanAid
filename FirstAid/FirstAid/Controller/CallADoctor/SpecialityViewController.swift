//
//  SpecialityViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SpecialityDelegate {
    func speciality(specialityId:String, specialityName:String)
}

class SpecialityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var backView: UIView!
    var delegate:SpecialityDelegate?
    
    struct Speciality {
        var ID:String!
        var name:String!
    }
    
    var specialityArr:[Speciality] = []
    var filterSpecialityArr:[Speciality] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.white.cgColor
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        searchText.delegate = self
        searchText.tintColor = UIColor.white
       self.getSpeciality()
    }

   
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getSpeciality(search:String = "0") {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getSpeciality + search, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.specialityArr = []
                for data in json["Data"].arrayValue {
                    self.specialityArr.append(Speciality.init(
                        ID: data["Value"].stringValue,
                        name: data["Text"].stringValue
                    ))
                }
                
                self.filterSpecialityArr = self.specialityArr
                
                self.tableView.reloadData()
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

extension SpecialityViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterSpecialityArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalWardCell", for: indexPath) as! HospitalWardCell
        cell.wardNameLabel.text = self.filterSpecialityArr[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.speciality(specialityId: self.filterSpecialityArr[indexPath.row].ID, specialityName: self.filterSpecialityArr[indexPath.row].name)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SpecialityViewController: UITextFieldDelegate {
    
    func filter(name:String) {
        self.filterSpecialityArr =  specialityArr.filter({( speciality : Speciality) -> Bool in
            return speciality.name.lowercased().contains(name.lowercased())
        })
        self.tableView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //self.getSpeciality(search: textField.text! + string)
        
        let  char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        
        if isBackSpace == -92 {
            let str = textField.text!.dropLast()
            if str.count > 1 {
                self.filter(name: String(str))
            }else{
                self.filterSpecialityArr = self.specialityArr
                self.tableView.reloadData()
            }
        }else{
            self.filter(name: textField.text! + string)
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

