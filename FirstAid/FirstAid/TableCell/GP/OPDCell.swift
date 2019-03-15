//
//  OPDCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OPDCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var patientImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        patientImage.layer.cornerRadius = patientImage.frame.size.height/2
        patientImage.layer.masksToBounds = true
        patientImage.layer.borderWidth = 1
        patientImage.layer.borderColor = Webservice.themeColor.cgColor
        statusLabel.layer.cornerRadius = statusLabel.frame.size.height/2
        statusLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
