//
//  editEducationCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 26/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class EditEducationCell: UITableViewCell {

    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var collegeLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
