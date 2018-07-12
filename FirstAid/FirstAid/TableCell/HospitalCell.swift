//
//  HosiptalCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 16/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class HospitalCell: UITableViewCell {

    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var cookAptBtn: UIButton!
    @IBOutlet weak var viewDoctorBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var hospitalImageView: UIImageView!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var opdLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.dropShawdow()
        backView.layer.cornerRadius = 5
        opdLabel.layer.cornerRadius = 5
        opdLabel.layer.masksToBounds = true
        
        //hospitalImageView.layer.cornerRadius = hospitalImageView.frame.height/2
       //                                          hospitalImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
