//
//  RelationCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 30/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class RelationCell: UICollectionViewCell {
    
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var relationImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        relationImageView.layer.cornerRadius = relationImageView.frame.size.height/2
        relationImageView.layer.masksToBounds = true
        relationImageView.layer.borderWidth = 1
       
    }
}

