//
//  SymptomCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 22/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SymptomCell: UITableViewCell {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var symptomLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
