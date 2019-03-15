//
//  DentalHospitalCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DentalHospitalCell: UITableViewCell {

    @IBOutlet weak var bookAppointmentBtn: UIButton!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var hospitalImage: UIImageView!
    @IBOutlet weak var hospitalNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
       // bookAppointmentBtn.layer.borderWidth = 1
       // bookAppointmentBtn.layer.borderColor = Webservice.themeColor.cgColor
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
