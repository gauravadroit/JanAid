//
//  OrderCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 21/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet weak var qtylabel: UILabel!
    @IBOutlet weak var medicineLabelName: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var trackOrderBtn: UIButton!
    @IBOutlet weak var cancelOrderBtn: UIButton!
    @IBOutlet weak var orderDate: UILabel!
    @IBOutlet weak var orderIdLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       // backView.layer.cornerRadius = 5
      // backView.dropShawdow()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
