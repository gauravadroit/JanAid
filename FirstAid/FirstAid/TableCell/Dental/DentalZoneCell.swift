//
//  DentalZoneCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 14/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DentalZoneCell: UITableViewCell {

    @IBOutlet weak var zoneImage: UIImageView!
    @IBOutlet weak var zoneLabel: UILabel!
    @IBOutlet weak var customView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        zoneImage.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        zoneImage.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
