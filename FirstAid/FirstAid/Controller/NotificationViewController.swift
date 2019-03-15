//
//  NotificationViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var parameter:[String:Any]!
    
    struct Notification {
        var title:String!
        var message:String!
        var calledAt:String!
        var userType:String!
    }
    
    var notificationArr:[Notification] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Notification"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.getNotification()
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
    }
    
    
    func getNotification() {
        
        print(parameter)
       
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingPost(path: Webservice.getNotification, dataDict: parameter, { (json) in
            print(json)
            
            if json["Status"].stringValue == "true" {
                for data in json["Data"].arrayValue {
                self.notificationArr.append(Notification.init(
                    title: data["Title"].stringValue,
                    message: data["Message"].stringValue,
                    calledAt: data["CalledAt"].stringValue,
                    userType: data["UserType"].stringValue
                ))
                }
                
                ShowLoader.stopLoader()
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

extension NotificationViewController:UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.titleLabel.text = notificationArr[indexPath.row].title
        cell.descriptionLabel.text = notificationArr[indexPath.row].message
        cell.datelabel.text = notificationArr[indexPath.row].calledAt
        cell.selectionStyle = .none
        return cell
    }
    
}
