//
//  PaymentCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 30/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PaymentCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var optionBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       backView.layer.cornerRadius = 5
        backView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        backView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
