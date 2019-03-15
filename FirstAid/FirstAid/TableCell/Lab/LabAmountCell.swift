//
//  LabAmountCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 11/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LabAmountCell: UITableViewCell {
    @IBOutlet weak var subTotalLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
