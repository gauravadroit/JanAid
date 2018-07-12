//
//  FeaturedPackageCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class FeaturedPackageCell: UITableViewCell {

    @IBOutlet weak var addTocartBtn: UIButton!
    @IBOutlet weak var certificationLabel: UILabel!
    @IBOutlet weak var discountBtn: UIButton!
    @IBOutlet weak var offeredPriceLabel: UILabel!
    @IBOutlet weak var mrplabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var labNameLabel: UILabel!
    @IBOutlet weak var testInfoLabel: UILabel!
    @IBOutlet weak var packageNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
