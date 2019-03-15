//
//  OrderItemCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 02/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OrderItemCell: UITableViewCell {
    @IBOutlet weak var medicineNameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var medicineDetailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
