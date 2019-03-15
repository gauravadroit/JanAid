//
//  LabMyOrderCell2.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LabMyOrderCell2: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewReportLabel: UILabel!
    @IBOutlet weak var testStatusLabel: UILabel!
    @IBOutlet weak var testNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
