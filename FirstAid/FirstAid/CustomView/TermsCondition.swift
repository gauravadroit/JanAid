//
//  TermsCondition.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class TermsCondition: UIView, UIWebViewDelegate {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    var view:UIView!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TermsCondition", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.layer.borderWidth = 1
        contentTextView.layer.cornerRadius = 5
        self.webView.delegate = self
        
        return view
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
         
        ShowLoader.startLoader(view: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ShowLoader.stopLoader()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ShowLoader.stopLoader()
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
