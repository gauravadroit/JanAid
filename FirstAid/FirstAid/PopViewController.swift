//
//  PopViewController.swift
//  Phase
//
//  Created by Mahabir on 23/02/18.
//  Copyright © 2018 Mahabir. All rights reserved.
//

import UIKit

protocol PopViewControllerDelegate {
    func saveString( _ strText : String)
}


class PopViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var arr = ["Reschedule","Progress","Cancelled"]
    var delegate : PopViewControllerDelegate?
    
    //var tagValue: Int? =
    var tagValue: Int = 0
    
    var isExist:Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.tag = self.tagValue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(arr)
        if isExist == false {
            isExist = true
        }else{
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.tableView.reloadData()
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

extension PopViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = arr[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((self.delegate) != nil)
        {
            self.dismiss(animated: true, completion: nil)
            delegate?.saveString(arr[indexPath.row]);
        }
    }
}

