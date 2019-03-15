//
//  PaymentReceipt.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PaymentReceipt: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var specialtyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var transactionLabel: UILabel!
    @IBOutlet weak var amountPayLabel: UILabel!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var consultationView: UIView!
    @IBOutlet weak var paymentView: UIView!
    var view:UIView!
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PaymentReceipt", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.paymentView.layer.borderColor = Webservice.themeColor.cgColor
        self.paymentView.layer.borderWidth = 1
        
        self.consultationView.layer.borderColor = Webservice.themeColor.cgColor
        self.consultationView.layer.borderWidth = 1
        return view
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
    
    func setData(data:[String:String]) {
        nameLabel.text = data["name"]
        mobileLabel.text = data["mobile"]
        specialtyLabel.text = data["speciality"]
        amountLabel.text = "₹" + data["amount"]!
        transactionLabel.text = data["transactionID"]
        amountPayLabel.text = "₹" + data["amount"]!
        noteLabel.text = data["note"]
        orderNumberLabel.text = data["orderNumber"]
        dateLabel.text = data["date"]
    }

}
