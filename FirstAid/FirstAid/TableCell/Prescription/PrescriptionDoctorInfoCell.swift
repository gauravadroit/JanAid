//
//  PrescriptionDoctorInfoCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PrescriptionDoctorInfoCell: UITableViewCell {
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var registerationLabel: UILabel!
    @IBOutlet weak var patientInfoLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
