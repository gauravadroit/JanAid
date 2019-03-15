//
//  AttachmentCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

protocol deleteAttachmentDelegate {
    func deleteAttachment(Id:String)
    func showAttachment(url:String)
}

class AttachmentCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var addAttachmentBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var attachmentLabel: UILabel!
    var attachmentArr:[[String:String]] = []
    var isCompleted:String!
    
    var delegate:deleteAttachmentDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        
    }
    
    func renderData(data:[[String:String]],isCompleted:String) {
        tableView.delegate = self
        tableView.dataSource = self
        self.attachmentArr = data
        self.isCompleted = isCompleted
        self.tableView.reloadData()
       
    }
    
   
    @objc func deleteAttachment(sender:UIButton) {
        delegate?.deleteAttachment(Id: self.attachmentArr[sender.tag]["documentId"]!)
    }
    
    @objc func showAttachment(sender:UIButton) {
        
        
        delegate?.showAttachment(url: self.attachmentArr[sender.tag]["documentUrl"]!)
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension AttachmentCell:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  self.attachmentArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachmentInfoCell", for: indexPath) as! AttachmentInfoCell
        cell.attachmentNameLabel.text =  self.attachmentArr[indexPath.row]["fileName"]! +  self.attachmentArr[indexPath.row]["uploadedAt"]!
        if isCompleted == "Completed" {
            cell.deleteBtn.isHidden = true
        }
        cell.deleteBtn.tag = indexPath.row
        cell.deleteBtn.addTarget(self, action: #selector(self.deleteAttachment(sender:)), for: UIControlEvents.touchUpInside)
        cell.viewBtn.tag  = indexPath.row
        cell.viewBtn.addTarget(self, action: #selector(self.showAttachment(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
    }
}
