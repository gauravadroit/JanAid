//
//  LabListCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LabListCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var labImageView: UIImageView!
    @IBOutlet weak var discountPriceLabel: UILabel!
    @IBOutlet weak var mrpLabel: UILabel!
    @IBOutlet weak var certificationLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var pathNameLabel: UILabel!
    @IBOutlet weak var optionBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
