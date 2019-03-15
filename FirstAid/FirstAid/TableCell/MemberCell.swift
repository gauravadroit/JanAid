//
//  MemberCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {

    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var patientCodeLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
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
