//
//  HosiptalsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 16/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView
import Toast_Swift

class HospitalsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    var fromSideMenu = "false"
    
    
    struct Hospital {
        var name:String!
        var logoName:String!
        var cityName:String!
        var address:String!
        var emailId:String!
        var hosiptalId:String!
        var stateName:String!
        var contactNumber:String!
        var lat:String!
        var long:String!
        var ipdDiscount:String!
        var opdDiscount:String!
    }
    
    var hospitalArr:[Hospital] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hospitals"
        tableView.separatorStyle = .none
        filterView.layer.cornerRadius = 5
        filterView.dropShawdow()
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if User.location != nil {
            locationLabel.text = User.location
        }
        self.getHospital()
    }

    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    @IBAction func locationAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @objc func directionAction(_ sender: UIButton) {
      
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "IpdPackagesViewController") as! IpdPackagesViewController
        nextView.hospitalId = self.hospitalArr[sender.tag].hosiptalId
        nextView.address = self.hospitalArr[sender.tag].address
        nextView.name = self.hospitalArr[sender.tag].name
        nextView.imageUrl =  Webservice.hospitalImageUrl + hospitalArr[sender.tag].hosiptalId + "/" + hospitalArr[sender.tag].logoName
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func filterAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func getHospital() {
        
        var location = "0"
        
        if User.location != "" && User.location != nil {
            location = User.location
        }
        
        let parameter = [
            "Value1":"0",
            "Value2":"0",
            "Value3":"0",
            "Value4":location,
            "Value5":"0", // Lat
            "Value6":"0", //long
            "PageNumber":"1",
            "PageSize":"100"
            ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getHospital, dataDict: parameter, headers: Webservice.header, { (json) in
        
            ShowLoader.stopLoader()
        
            print(json)
            
            //if json[]
              self.hospitalArr = []
            for data in json["Data"].arrayValue {
                self.hospitalArr.append(Hospital.init(
                    name: data["HospitalName"].stringValue,
                    logoName: data["Logo"].stringValue,
                    cityName: data["CityName"].stringValue,
                    address: data["Address"].stringValue,
                    emailId: data["EmailID"].stringValue,
                    hosiptalId: data["HospitalID"].stringValue,
                    stateName: data["StateName"].stringValue,
                    contactNumber: data["ContactNo"].stringValue,
                    lat: data["Latitude"].stringValue,
                    long: data["Longitude"].stringValue,
                    ipdDiscount: data["IpdDiscount"].stringValue,
                    opdDiscount: data["OpdDiscount"].stringValue
                ))
            }
            
            if self.hospitalArr.count == 0 {
                self.view.makeToast("No record found.", duration: 3.0, position: .bottom)
            }
            
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
        
    }
    
    
    @objc func viewDoctorAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
       
        let nextView = storyboard.instantiateViewController(withIdentifier: "HospitalWardViewController") as! HospitalWardViewController
        nextView.hospitalId = hospitalArr[sender.tag].hosiptalId
        nextView.hospitalName = hospitalArr[sender.tag].name
        nextView.address = hospitalArr[sender.tag].address
        nextView.imageUrl = Webservice.hospitalImageUrl + hospitalArr[sender.tag].hosiptalId + "/" + hospitalArr[sender.tag].logoName
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

extension HospitalsViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hospitalArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HospitalCell", for: indexPath) as! HospitalCell
        cell.addressLabel.text = self.hospitalArr[indexPath.row].address
        cell.hospitalNameLabel.text = self.hospitalArr[indexPath.row].name
        cell.hospitalImageView.sd_setImage(with: URL(string: Webservice.hospitalImageUrl + hospitalArr[indexPath.row].hosiptalId + "/" + hospitalArr[indexPath.row].logoName), placeholderImage: UIImage(named: "Hospital"))
        cell.viewDoctorBtn.tag = indexPath.row
        cell.viewDoctorBtn.addTarget(self, action: #selector(self.viewDoctorAction(sender:)), for: UIControlEvents.touchUpInside)
        cell.directionBtn.tag = indexPath.row
        cell.directionBtn.addTarget(self, action: #selector(self.directionAction(_:)), for: UIControlEvents.touchUpInside)
        
        if self.hospitalArr[indexPath.row].opdDiscount == "0" {
            cell.opdLabel.text = ""
            cell.discountLabel.text = ""
        }else{
            cell.opdLabel.text = " " + self.hospitalArr[indexPath.row].opdDiscount + " % OPD "
            cell.discountLabel.text = "Discount:"
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        nextView.lat = hospitalArr[indexPath.row].lat
        nextView.long = hospitalArr[indexPath.row].long
        nextView.hosiptalName = hospitalArr[indexPath.row].name
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}
