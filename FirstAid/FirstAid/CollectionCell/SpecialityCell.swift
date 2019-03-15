//
//  SpecialityCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SpecialityCell: UICollectionViewCell {
    
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var specialityImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.black.withAlphaComponent(0.3).cgColor
    }
}
