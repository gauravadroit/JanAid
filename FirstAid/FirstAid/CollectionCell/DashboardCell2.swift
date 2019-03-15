//
//  DashboardCell2.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DashboardCell2: UICollectionViewCell {
    
    @IBOutlet weak var consultNowBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        
    }
}
