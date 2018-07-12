//
//  SubcriptionPlanCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SubcriptionPlanCell: UICollectionViewCell {
    
    @IBOutlet weak var planValidityLabel: UILabel!
    @IBOutlet weak var planPriceLabel: UILabel!
    @IBOutlet weak var planTypeLabel: UILabel!
    @IBOutlet weak var buyBtn: UIButton!
    @IBOutlet weak var validityLabel: UILabel!
    @IBOutlet weak var pricelabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        planPriceLabel.layer.cornerRadius = 25
        planPriceLabel.layer.borderWidth = 1
        planPriceLabel.layer.borderColor = UIColor.white.cgColor
        planPriceLabel.layer.masksToBounds = true
        buyBtn.layer.cornerRadius = 5
    }
}
