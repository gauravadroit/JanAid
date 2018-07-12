//
//  SelectDoctorCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class SelectDoctorCell: UITableViewCell {
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var doctorImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var ratinglabel: UILabel!
    @IBOutlet weak var feesLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var offerAmtLabel: UILabel!
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var genderImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        backView.dropShawdow()
        selectBtn.layer.cornerRadius = 5
        selectBtn.layer.borderWidth = 1
        selectBtn.layer.borderColor = UIColor(red: 0.0/255.0, green: 91.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
