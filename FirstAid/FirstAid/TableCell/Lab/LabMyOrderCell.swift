//
//  LabMyOrderCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LabMyOrderCell: UITableViewCell {

    @IBOutlet weak var accreditationLabel: UILabel!
    @IBOutlet weak var labImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var labNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingLabel.layer.cornerRadius = 5
        ratingLabel.layer.masksToBounds = true
        labImage.layer.borderWidth = 1
        labImage.layer.borderColor = UIColor.lightGray.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
