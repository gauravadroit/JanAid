//
//  AddSymptomsCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AddSymptomsCell: UITableViewCell {

    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var symptomText: UITextField!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var completeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor(red: 22.0/255.0, green: 89.0/255.0, blue: 141.0/255.0, alpha: 1.0).cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
