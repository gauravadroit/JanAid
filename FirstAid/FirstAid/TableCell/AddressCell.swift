//
//  AddressCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
