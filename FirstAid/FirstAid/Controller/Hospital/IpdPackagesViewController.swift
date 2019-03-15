//
//  IpdPackagesViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class IpdPackagesViewController: UIViewController {

    @IBOutlet weak var AFQBtn: UIButton!
    @IBOutlet weak var hospitalAddress: UILabel!
    @IBOutlet weak var hospitalName: UILabel!
    @IBOutlet weak var hospitalImage: UIImageView!
    @IBOutlet weak var hospitalView: UIView!
    var hospitalId:String!
    var address:String!
    var name:String!
    var imageUrl:String!
    var selectedIndex:Int = -1
    @IBOutlet weak var tableView: UITableView!
    
    struct hospitalPackage {
        var packageName:String!
        var packageId:String!
    }
    
    var hospitalPackageArr:[hospitalPackage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Treatment Packages"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        AFQBtn.layer.cornerRadius = 5
        AFQBtn.backgroundColor = UIColor.gray
        self.AFQBtn.addTarget(self, action: #selector(self.RFQAction(sender:)), for: .touchUpInside)
        hospitalView.dropShawdow()
        hospitalView.layer.cornerRadius = 5
        self.hospitalAddress.text = address
        self.hospitalName.text = name
         hospitalImage.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "Hospital"))
        
        self.ipdPackages()
    }
    
    func ipdPackages() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.IPDPackages + hospitalId, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.hospitalPackageArr = []
            if json["Status"].stringValue == "true" {
                for data in json["Data"]["HospitalPackage"].arrayValue {
                    self.hospitalPackageArr.append(hospitalPackage.init(
                        packageName: data["PackageName"].stringValue,
                        packageId: data["PackageID"].stringValue
                    ))
                }
            }else{
                self.AFQBtn.isHidden = true
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }

    @objc func radioAction(sender:UIButton) {
        AFQBtn.backgroundColor = Webservice.themeColor
        self.selectedIndex = sender.tag
        self.tableView.reloadData()
    }
    
   @objc func RFQAction(sender:UIButton) {
    
        if self.selectedIndex == -1 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select Treatment Package.")
        }else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let next = storyboard.instantiateViewController(withIdentifier: "RFQViewController") as! RFQViewController
            next.packageId = hospitalPackageArr[self.selectedIndex].packageId
            next.packageName = hospitalPackageArr[self.selectedIndex].packageName
            self.navigationController?.pushViewController(next, animated: true)
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

extension IpdPackagesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalPackageArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RFQCell", for: indexPath) as! RFQCell
        cell.IpdNameLabel.text =  hospitalPackageArr[indexPath.row].packageName
        let icon = #imageLiteral(resourceName: "radio")
        let icon2 = #imageLiteral(resourceName: "radioselected")
        if selectedIndex == indexPath.row {
            cell.rfqBtn.setImage(icon2, for: .normal)
        }else{
            cell.rfqBtn.setImage(icon, for: .normal)
        }
        
        cell.rfqBtn.tag = indexPath.row
        cell.rfqBtn.addTarget(self, action: #selector(self.radioAction(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
    
}
