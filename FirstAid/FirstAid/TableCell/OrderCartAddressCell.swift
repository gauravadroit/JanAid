//
//  OrderCartAddressCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 27/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OrderCartAddressCell: UITableViewCell {

    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var pincodeLabel: UILabel!
    @IBOutlet weak var localityLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        //backView.dropShawdow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
