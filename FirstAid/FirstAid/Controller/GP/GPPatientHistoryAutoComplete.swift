//
//  GPPatientHistoryAutoComplete.swift
//  FirstAid
//
//  Created by Adroit MAC on 28/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol HistoryDelegate {
    func historyValue( _ history : String)
}

class GPPatientHistoryAutoComplete: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var backView: UIView!
    var request:DataRequest!
    var symArr:[String] = []
    var delegate : HistoryDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.white.cgColor
        searchText.delegate = self
        searchText.becomeFirstResponder()
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func getSearchData(name:String) {
        
        if request != nil {
            request.cancel()
        }
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet)
            return
        }
        
        let parameter:[String:String] = ["Text":name]
        
        
        request =  Alamofire.request(Webservice.getHistory, method: .post, parameters:parameter, encoding: JSONEncoding.default, headers:Webservice.header).responseJSON { response in
            
            switch response.result {
            case .success:
                if let value = response.result.value {
                    let json = JSON(value)
                    print(json)
                   
                    self.symArr = []
                    for data in json["Data"].arrayValue {
                        self.symArr.append(data["Text"].stringValue)
                    }
                    
                    if self.symArr.contains(self.searchText.text!) == false && self.searchText.text! != "" {
                        self.symArr.insert(self.searchText.text!, at: 0)
                    }
                    
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
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

extension GPPatientHistoryAutoComplete:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.symArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = self.symArr[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if((self.delegate) != nil)
        {
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
            delegate?.historyValue(self.symArr[indexPath.row]);
        }
    }
    
}


extension GPPatientHistoryAutoComplete:UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.getSearchData(name: textField.text! + string)
        return true
    }
}
