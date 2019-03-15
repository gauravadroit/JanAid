//
//  ShowSpecialityViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView


class ShowSpecialityViewController: UIViewController {
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    struct Speciality {
        var ID:String!
        var name:String!
    }
    
    var specialityArr:[Speciality] = []
    var filterSpecialityArr:[Speciality] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        searchText.layer.cornerRadius = 5
        searchText.layer.borderWidth = 1
        searchText.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
        searchText.placeholder = "Search..."
        searchText.placeHolderColor = UIColor.black.withAlphaComponent(0.3)
        searchText.tintColor = UIColor.black
        searchText.delegate = self
        self.setIconInTextfield(textField: searchText)
        
        self.title = "Select Speciality"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.getSpeciality()
    }
    
    func setIconInTextfield(textField:UITextField) {
        let icon = #imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate)
        let dropdown = UIImageView(image: icon)
        dropdown.tintColor = UIColor.black.withAlphaComponent(0.3)
        dropdown.frame = CGRect(x: 0.0, y: 0.0, width: dropdown.image!.size.width+15.0, height: dropdown.image!.size.height);
        dropdown.contentMode = UIViewContentMode.center
        textField.leftView = dropdown;
        textField.leftViewMode = UITextFieldViewMode.always
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

extension ShowSpecialityViewController:UITableViewDelegate, UITableViewDataSource {
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SelectSpecialityViewController") as! SelectSpecialityViewController
        nextView.specialityId = self.filterSpecialityArr[indexPath.row].ID
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

extension ShowSpecialityViewController: UITextFieldDelegate {
    
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
