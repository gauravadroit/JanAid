//
//  PatientReviewCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/11/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PatientReviewCell: UITableViewCell {

    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ratingLabel.layer.cornerRadius = ratingLabel.frame.size.height/2
        ratingLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
