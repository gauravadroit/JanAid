//
//  GPAdviceCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 24/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class GPAdviceCell: UITableViewCell {
    @IBOutlet weak var adviceLabel: UILabel!
    
    @IBOutlet weak var adviceTextView: UITextView!
    override func awakeFromNib() {
        super.awakeFromNib()
        adviceTextView.layer.cornerRadius = 5
        adviceTextView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        adviceTextView.layer.borderWidth = 1
        adviceTextView.delegate = self
        adviceLabel.isHidden = true
        adviceTextView.text = "Advice  "
        adviceTextView.textColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension GPAdviceCell:UITextViewDelegate {
    
   
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text!.count == 0 {
            adviceTextView.text = "Advice  "
            adviceTextView.textColor = UIColor.lightGray
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text! == "Advice  " {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let  char = text.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace == -92 {
            return true
        }
        
        let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890 .,':%&!()-+/"
        let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
        let compSepByCharInSet = text.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        if textView.text.count < 500 {
            return text == numberFiltered
        }else{
            return false
        }
    }
    
}
