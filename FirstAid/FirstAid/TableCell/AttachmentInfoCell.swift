//
//  AttachmentInfoCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 18/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AttachmentInfoCell: UITableViewCell {

    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var attachmentNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
