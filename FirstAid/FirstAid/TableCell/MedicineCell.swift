//
//  MedicineCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class MedicineCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mrpLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var fixedMrpLabel: UILabel!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var addTocardBtn: UIButton!
    @IBOutlet weak var productQuantitylabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.dropShawdow()
        backView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
