//
//  PrescriptionSignatureCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PrescriptionSignatureCell: UITableViewCell {

    @IBOutlet weak var disclaimerLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
