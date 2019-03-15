//
//  DoctorProfessionalDetailsCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DoctorProfessionalDetailsCell: UITableViewCell {

    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var professionalLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dotView.layer.cornerRadius = dotView.frame.size.height/2
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
