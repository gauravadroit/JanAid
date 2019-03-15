//
//  NiramayaLabCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/10/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class NiramayaLabCell: UITableViewCell {

    @IBOutlet weak var dispatchedLabel: UILabel!
    @IBOutlet weak var reportStatusLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    @IBOutlet weak var orderLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
