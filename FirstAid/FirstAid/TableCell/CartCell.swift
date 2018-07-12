//
//  CartCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 26/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {

    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var mrpLabel: UILabel!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var medicineMetaLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        backView.dropShawdow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
