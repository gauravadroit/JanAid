//
//  AppointmentCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AppointmentCell: UITableViewCell {

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var eyeActionBtn: UIButton!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titlelabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
