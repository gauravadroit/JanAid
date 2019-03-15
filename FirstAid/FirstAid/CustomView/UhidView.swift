//
//  UhidView.swift
//  JanAid
//
//  Created by Adroit MAC on 19/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class UhidView: UIView {

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var uhidText: UITextField!
    @IBOutlet weak var registrationText: UITextField!
    var view:UIView!
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "UhidView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        cancelBtn.layer.cornerRadius = 5
        submitBtn.layer.cornerRadius = 5
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
