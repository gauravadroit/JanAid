//
//  TotalPriceCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 28/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class TotalPriceCell: UITableViewCell {

    @IBOutlet weak var shipingLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var mrpTotalLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
      //  backView.dropShawdow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
