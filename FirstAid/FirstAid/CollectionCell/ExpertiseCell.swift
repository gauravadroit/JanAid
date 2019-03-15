//
//  ExpertiseCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 31/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class ExpertiseCell: UICollectionViewCell {
    
    @IBOutlet weak var expertiseLabel: UILabel!
    @IBOutlet weak var yellowView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        yellowView.layer.cornerRadius = yellowView.frame.size.height/2
        
    }
}
