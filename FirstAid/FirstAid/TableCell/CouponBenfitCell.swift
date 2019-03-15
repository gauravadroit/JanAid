//
//  CouponBenfitCell.swift
//  JanAid
//
//  Created by Adroit MAC on 12/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit

class CouponBenfitCell: UITableViewCell {

    @IBOutlet weak var benefitLabel: UILabel!
    @IBOutlet weak var roundDot: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roundDot.layer.cornerRadius = roundDot.frame.size.width/2
        roundDot.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
