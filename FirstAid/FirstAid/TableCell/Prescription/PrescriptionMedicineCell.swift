//
//  PrescriptionMedicineCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PrescriptionMedicineCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var serialNumberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
