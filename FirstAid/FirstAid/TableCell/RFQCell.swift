//
//  RFQCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 22/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class RFQCell: UITableViewCell {

    @IBOutlet weak var rfqBtn: UIButton!
    @IBOutlet weak var IpdNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        rfqBtn.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
