//
//  PhotoCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 05/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var prescriptionImageView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2
        
        
    }
}
