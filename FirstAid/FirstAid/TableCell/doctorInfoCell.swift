//
//  doctorInfoCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class doctorInfoCell: UITableViewCell {
    @IBOutlet weak var doctorImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var consultationCountLabel: UILabel!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var starRatingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doctorImage.layer.cornerRadius = doctorImage.frame.size.height/2
        doctorImage.layer.masksToBounds = true
        doctorImage.layer.borderWidth = 1
        doctorImage.layer.borderColor = Webservice.themeColor.cgColor
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
