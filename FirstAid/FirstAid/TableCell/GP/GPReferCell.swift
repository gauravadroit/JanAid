//
//  GPReferCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class GPReferCell: UITableViewCell {

    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var assignBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
       

        assignBtn.layer.cornerRadius = 5
        assignBtn.layer.borderColor = UIColor(red: 22.0/255.0, green: 89.0/255.0, blue: 141.0/255.0, alpha: 1.0).cgColor
        assignBtn.layer.borderWidth = 1
    }

}
