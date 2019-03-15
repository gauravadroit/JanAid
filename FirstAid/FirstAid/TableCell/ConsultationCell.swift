//
//  ConsultationCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 19/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class ConsultationCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        doctorImage.layer.cornerRadius = doctorImage.frame.size.height/2
        doctorImage.layer.borderWidth = 1
        doctorImage.layer.masksToBounds = true
        doctorImage.layer.borderColor = Webservice.themeColor.cgColor
        statusLabel.layer.cornerRadius = statusLabel.frame.size.height/2
        statusLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
