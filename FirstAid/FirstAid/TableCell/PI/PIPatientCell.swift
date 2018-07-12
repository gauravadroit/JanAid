//
//  PIPatientCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/06/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PIPatientCell: UITableViewCell {

    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var PIStatusLabel: UILabel!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var patientNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var registrationNoLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var reassignBtn: UIButton!
    @IBOutlet weak var reassignLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       countLabel.layer.cornerRadius = countLabel.frame.size.height/2
        countLabel.layer.borderColor = UIColor.black.withAlphaComponent(0.4).cgColor
        countLabel.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
