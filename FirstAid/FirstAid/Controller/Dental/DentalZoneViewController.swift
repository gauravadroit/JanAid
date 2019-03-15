//
//  DentalZoneViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DentalZoneViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    struct zone {
        var zoneName:String!
        var zoneId:String!
        var Url:String!
    }
    
    var zoneArr:[zone] = []
     var fromSideMenu = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Dental Zone"
        self.tabBarController?.tabBar.isHidden = true
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
        self.getZone()
    }
    
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    

    func getZone()  {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getDentalZone, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            
             self.zoneArr = []
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                   
                    self.zoneArr.append(DentalZoneViewController.zone.init(
                        zoneName: data["ZoneName"].stringValue,
                        zoneId: data["ZoneID"].stringValue,
                        Url: data["Image"].stringValue
                    ))
                }
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }

}

extension DentalZoneViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.zoneArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DentalZoneCell", for: indexPath) as! DentalZoneCell
        cell.zoneLabel.text = self.zoneArr[indexPath.row].zoneName
        cell.zoneImage.sd_setImage(with: URL(string: self.zoneArr[indexPath.row].Url), placeholderImage: UIImage(named: "Hospital"))
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "DentalHospital", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "DentalHospitalViewController") as! DentalHospitalViewController
        nextView.zoneId = self.zoneArr[indexPath.row].zoneId
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}
