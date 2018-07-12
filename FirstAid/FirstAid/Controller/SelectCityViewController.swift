//
//  SelectCityViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 01/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol selectCityDelegate {
    func cityInfo(name:String, value:String)
}

class SelectCityViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var backView: UIView!
    var delegate:selectCityDelegate?
    struct city {
        var name:String!
        var value:String!
    }
    
    var cityArr:[city] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.white.cgColor
        
        self.getCities()
    }

    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getCities() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getCities, headers: Webservice.header, { (json) in
            print(json)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
                self.cityArr = []
                for data in json["Data"].arrayValue {
                    self.cityArr.append(city.init(name: data["Text"].stringValue, value: data["Value"].stringValue))
                }
                
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
    }

}

extension SelectCityViewController:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = cityArr[indexPath.row].name
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.cityInfo(name: cityArr[indexPath.row].name, value: cityArr[indexPath.row].value)
        self.dismiss(animated: true, completion: nil)
    }
    
}
