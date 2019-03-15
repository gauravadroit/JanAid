//
//  HospitalWardViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 07/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage
import Toast_Swift

class HospitalWardViewController: UIViewController {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var hospitalImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var tableView: UITableView!
    var hospitalId:String!
    var hospitalName:String!
    var address:String!
    var imageUrl:String!
    
    struct department {
        var SpecialityName:String!
        var SpecialityID:String!
        var KeyValue:String!
        var KeyText:String!
    }
    
    var departmentArr:[department] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorStyle = .none
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.backView.dropShawdow()
        self.backView.layer.cornerRadius = 5
        self.hospitalLabel.text = hospitalName
        self.addressLabel.text = address
        hospitalImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "Hospital"))
        self.title = "Speciality"
        self.getAllHospitalWard()
    }
    
    func getAllHospitalWard() {
        
        let parameter:[String:String] = [
            "FlagNo":"1",
            "Value1":hospitalId,
            "Value2":"0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getDepartment, dataDict: parameter, headers: Webservice.header, { (json) in
           ShowLoader.stopLoader()
            print(json)
            
            if json["Status"].stringValue == "true" {
                
                self.departmentArr.append(department.init(
                    SpecialityName: "All",
                    SpecialityID: "0",
                    KeyValue: "0",
                    KeyText: "0"
                ))
                
                for data in json["Data"].arrayValue {
                    self.departmentArr.append(department.init(
                        SpecialityName: data["SpecialityName"].stringValue,
                        SpecialityID: data["SpecialityID"].stringValue,
                        KeyValue: data["KeyValue"].stringValue,
                        KeyText: data["KeyText"].stringValue
                    ))
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
             ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            print(error)
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

extension HospitalWardViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.departmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalWardCell", for: indexPath) as! HospitalWardCell
        cell.wardNameLabel.text = self.departmentArr[indexPath.row].SpecialityName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
         let nextView = storyboard.instantiateViewController(withIdentifier: "DoctorViewController") as! DoctorViewController
        
        nextView.hospitalId = self.hospitalId
        nextView.specId = self.departmentArr[indexPath.row].SpecialityID
        nextView.hospitalName = self.hospitalName
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

