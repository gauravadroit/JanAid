//
//  OrderDetailCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 03/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OrderDetailCell: UITableViewCell {

    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var shipingChargesLabel: UILabel!
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
