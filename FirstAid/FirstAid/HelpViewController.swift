//
//  HelpViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class HelpViewController: UIViewController, UIWebViewDelegate {

      @IBOutlet weak var webView: UIWebView!
    
    var fromSideMenu = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Help"
        webView.delegate = self
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/help.htm")
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
       
        
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
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
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
