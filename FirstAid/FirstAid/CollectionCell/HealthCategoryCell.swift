//
//  HealthCategoryCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class HealthCategoryCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1
        backView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
    }
    
}
