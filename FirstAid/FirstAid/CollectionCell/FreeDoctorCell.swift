//
//  FreeDoctorCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 03/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class FreeDoctorCell: UICollectionViewCell {

    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var starRatingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.borderWidth = 1
        backView.layer.borderColor = Webservice.themeColor.cgColor
        backView.layer.cornerRadius = 5
        
        starRatingLabel.layer.cornerRadius = 5
        starRatingLabel.layer.masksToBounds = true
        
        
        doctorImage.layer.cornerRadius = doctorImage.frame.size.height/2
        doctorImage.layer.masksToBounds = true
        doctorImage.layer.borderWidth = 1
        doctorImage.layer.borderColor = Webservice.themeColor.cgColor
    }

}
