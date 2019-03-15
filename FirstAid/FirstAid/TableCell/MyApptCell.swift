//
//  MyApptCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class MyApptCell: UITableViewCell {
    @IBOutlet weak var bookedDateLabel: UILabel!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var apptdateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
