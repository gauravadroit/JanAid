//
//  AboutUsViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 17/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class AboutUsViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var fromSideMenu = "false"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "About Us"
        webView.delegate = self
        
        let url = URL (string: Webservice.baseUrl + "Areas/_Documents/DataFiles/AboutUs.htm")
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
        //self.getAbout()
        
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
    
    
    /*func getAbout() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.aboutUs, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            if json["Status"].stringValue == "true" {
                self.aboutTextView.text = json["Data"].stringValue
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }*/

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
