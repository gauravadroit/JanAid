//
//  DoctorCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DoctorCell: UITableViewCell {

    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var bookApptBtn: UIButton!
    @IBOutlet weak var specialistLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        backView.layer.cornerRadius = 5
        backView.dropShawdow()
        
        let icon = #imageLiteral(resourceName: "calendarGreen").withRenderingMode(.alwaysTemplate)
        bookApptBtn.setImage(icon, for: .normal)
       // bookApptBtn.tintColor = UIColor.white
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
