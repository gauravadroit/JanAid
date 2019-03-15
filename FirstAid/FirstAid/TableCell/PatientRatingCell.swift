//
//  PatientRatingCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/11/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PatientRatingCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
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
