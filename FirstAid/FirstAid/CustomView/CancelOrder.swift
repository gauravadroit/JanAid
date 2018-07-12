//
//  CancelOrder.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class CancelOrder: UIView {

    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    var view:UIView!
    @IBOutlet weak var tableView: UITableView!
    var selectedIndex:Int = 0
    var selectedId:String!
    
    struct reason {
        var id:String!
        var reason:String!
    }
    
    var reasonArr:[reason] = []
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CancelOrder", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        tableView.register(UINib(nibName: "CancelOrderCell", bundle: nil), forCellReuseIdentifier: "CancelOrderCell")
        self.tableView.separatorStyle = .none
        self.getCancelReason()
        return view
    }
    
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    func getCancelReason() {
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getCancelReason, headers: headers, { (json) in
            print(json)
            
            for data in json["result"].arrayValue {
                self.reasonArr.append(reason.init(
                    id: data["id"].stringValue,
                    reason: data["name"].stringValue
                ))
            }
            
            self.selectedId = self.reasonArr[self.selectedIndex].id
            self.tableView.reloadData()
            
        }) { (error) in
            print(error)
        }
        
    }

}
extension CancelOrder:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reasonArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CancelOrderCell", for: indexPath) as! CancelOrderCell
        
        cell.reasonLabel.text = reasonArr[indexPath.row].reason
        cell.optionBtn.tag = indexPath.row
        if self.selectedIndex == indexPath.row {
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radioselected"), for: UIControlState.normal)
        }else{
            cell.optionBtn.setImage(#imageLiteral(resourceName: "radio"), for: UIControlState.normal)
        }
        cell.optionBtn.addTarget(self, action: #selector(self.selectOtion(sender:)), for: UIControlEvents.touchUpInside)
        cell.selectionStyle = .none
        
        return cell
    }
    
    @objc func selectOtion(sender:UIButton) {
        self.selectedIndex = sender.tag
        self.selectedId = self.reasonArr[self.selectedIndex].id
        self.tableView.reloadData()
    }
}

