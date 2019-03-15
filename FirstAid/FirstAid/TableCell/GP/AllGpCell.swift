//
//  AllGpCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AllGpCell: UITableViewCell {

    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var appointmentDate: UILabel!
    @IBOutlet weak var hospitalName: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var hospitalStatusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        countLabel.layer.cornerRadius = countLabel.frame.size.width/2
        countLabel.layer.borderColor = UIColor.lightGray.cgColor
        countLabel.layer.borderWidth = 1
        countLabel.layer.masksToBounds = true
    }

}
