//
//  AddToCart.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AddToCart: UIView {

    @IBOutlet weak var discountconstraint: NSLayoutConstraint!
    @IBOutlet weak var discountedPriceLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var mrpLabel: UILabel!
    @IBOutlet weak var quantityDEscriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var view:UIView!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AddToCart", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        backView.layer.cornerRadius = 5
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
    

}
