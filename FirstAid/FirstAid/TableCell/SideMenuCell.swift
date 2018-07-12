//
//  SideMenuCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 02/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SideMenuCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
