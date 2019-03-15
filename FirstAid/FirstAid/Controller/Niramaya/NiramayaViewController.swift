//
//  NiramayaViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NiramayaViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    struct LabTest {
        var orderReference:String!
        var testName:String!
        var dispatchedAt:String!
        var reportUrl:String!
        var reportStatus:String!
    }
    
    var labTestArr:[LabTest] = []
    
    var fromSideMenu = "false"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Reports"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
       // }
        
        if let tabItems = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = tabItems[3] as! UITabBarItem
            tabItem.badgeValue = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getLabTest()
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    func getLabTest() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getNiramayaLabTest + User.mobileNumber, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            
            if json["Status"].stringValue == "true" {
            self.labTestArr = []
            for data in json["Data"].arrayValue {
                self.labTestArr.append(LabTest.init(
                    orderReference: data["OrderReference"].stringValue,
                    testName: data["TestName"].stringValue,
                    dispatchedAt: data["RiportDispatchedAt"].stringValue,
                    reportUrl: data["ReportUrl"].stringValue,
                    reportStatus: data["ReportStatus"].stringValue
                ))
            }
            self.tableView.reloadData()
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension NiramayaViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labTestArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NiramayaLabCell", for: indexPath) as! NiramayaLabCell
        cell.dispatchedLabel.text = labTestArr[indexPath.row].dispatchedAt
        cell.orderLabel.text = labTestArr[indexPath.row].orderReference
        cell.reportStatusLabel.text = labTestArr[indexPath.row].reportStatus
        cell.testNameLabel.text = labTestArr[indexPath.row].testName
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "LabReportViewController") as! LabReportViewController
        nextView.reportLink = labTestArr[indexPath.row].reportUrl
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}
