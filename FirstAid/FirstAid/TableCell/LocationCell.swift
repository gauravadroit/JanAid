//
//  LocationCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 25/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backView.layer.cornerRadius = 5
        self.backView.layer.borderColor = UIColor.gray.withAlphaComponent(0.3).cgColor
        self.backView.layer.borderWidth = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
