//
//  LocationViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 24/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import CoreLocation
import NVActivityIndicatorView

class LocationViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectCityText: UITextField!
    @IBOutlet weak var getLocationBtn: UIButton!
    let locationManager = CLLocationManager()
    
    struct location {
        var name:String!
        var id:String!
    }
    
    var locationArr:[location] = []
    var filterlocationArr:[location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getLocationBtn.layer.cornerRadius = 5
        self.getLocationBtn.layer.borderWidth = 1
        self.getLocationBtn.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        self.tableView.separatorStyle = .none
        self.getLocationBtn.addTarget(self, action: #selector(self.getLocation), for: UIControlEvents.touchUpInside)
        self.title = "Location"
        
        self.getCitiesList()
        self.searchText.delegate = self
        self.setIconInTextfield(textField: searchText)
        
    }
    
    func setIconInTextfield(textField:UITextField) {
        
        let icon = #imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate)
        let dropdown = UIImageView(image: icon)
        dropdown.tintColor = UIColor.black
        dropdown.frame = CGRect(x: 0.0, y: 0.0, width: dropdown.image!.size.width+15.0, height: dropdown.image!.size.height);
        dropdown.contentMode = UIViewContentMode.center
        textField.rightView = dropdown;
        textField.rightViewMode = UITextFieldViewMode.always
    }
    
    @objc func getLocation(){
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        self.getAddressFromLatLon(pdblLatitude: String(locValue.latitude), withLongitude: String(locValue.longitude))
    }

    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        ceo.reverseGeocodeLocation(loc, completionHandler:
            {(placemarks, error) in
                if (error != nil)
                {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                let pm = placemarks! as [CLPlacemark]
                ShowLoader.stopLoader()
                if pm.count > 0 {
                    let pm = placemarks![0]
                    User.location = pm.locality as! String
                    UserDefaults.standard.setValue(User.location, forKey: "location")
                    self.navigationController?.popViewController(animated: true)
                    print(pm.country)
                    print(pm.locality)
                    print(pm.subLocality)
                    print(pm.thoroughfare)
                    print(pm.postalCode)
                    print(pm.subThoroughfare)
                    var addressString : String = ""
                    if pm.subLocality != nil {
                        addressString = addressString + pm.subLocality! + ", "
                    }
                    if pm.thoroughfare != nil {
                        addressString = addressString + pm.thoroughfare! + ", "
                    }
                    if pm.locality != nil {
                        addressString = addressString + pm.locality! + ", "
                    }
                    if pm.country != nil {
                        addressString = addressString + pm.country! + ", "
                    }
                    if pm.postalCode != nil {
                        addressString = addressString + pm.postalCode! + " "
                    }
                    
                    
                    print(addressString)
                }
        })
        
    }
    
    func getCitiesList() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getCities, headers: Webservice.header, { (json) in
            print(json)
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                    self.locationArr.append(location.init(name: data["Text"].stringValue, id: data["Value"].stringValue))
                }
                self.filterlocationArr = self.locationArr
                ShowLoader.stopLoader()
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

extension LocationViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterlocationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        cell.cityLabel.text = filterlocationArr[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        User.location = filterlocationArr[indexPath.row].name
        UserDefaults.standard.setValue(User.location, forKey: "location")
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension LocationViewController:UITextFieldDelegate {
    
    
    func filter(name:String) {
        self.filterlocationArr =  locationArr.filter({( location : location) -> Bool in
            return location.name.lowercased().contains(name.lowercased())
        })
         self.tableView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
         let  char = string.cString(using: String.Encoding.utf8)!
         let isBackSpace = strcmp(char, "\\b")
         
         if isBackSpace == -92 {
            let str = textField.text!.dropLast()
            if str.count > 1 {
                self.filter(name: String(str))
            }else{
                self.filterlocationArr = self.locationArr
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

