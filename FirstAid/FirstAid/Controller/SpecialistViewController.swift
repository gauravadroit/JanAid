//
//  SpecialistViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 25/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class SpecialistViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    struct specialist {
        var id:String!
        var name:String!
    }
    
    var specialistArr:[specialist] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .none
        self.getSpecilistList()
    }

    func getSpecilistList(){
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getSpecialist, headers: Webservice.header, { (json) in
            print(json)
            self.specialistArr.append(specialist.init(
                id: "0",
                name: "All"
            ))
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.specialistArr.append(specialist.init(
                        id: data["Value"].stringValue,
                        name: data["Text"].stringValue
                    ))
                }
            }
            
            ShowLoader.stopLoader()
            self.tableView.reloadData()
            
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

extension SpecialistViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return specialistArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.cityLabel.text = specialistArr[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        User.speciality = specialistArr[indexPath.row].name
        User.specialityId = specialistArr[indexPath.row].id
        UserDefaults.standard.setValue(User.speciality, forKey: "speciality")
        UserDefaults.standard.setValue(User.specialityId, forKey: "specialityId")
        self.navigationController?.popViewController(animated: true)
    }
    
}

