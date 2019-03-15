//
//  PatientDescriptionCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PatientDescriptionCell: UITableViewCell {

    @IBOutlet weak var showProfileBtn: UIButton!
    @IBOutlet weak var whiteView: UIView!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var patientDescriptionLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       // backView.layer.cornerRadius = backView.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
