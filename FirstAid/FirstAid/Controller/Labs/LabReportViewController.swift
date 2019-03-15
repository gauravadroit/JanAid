//
//  LabReportViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 20/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

class LabReportViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    var reportLink:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lab Report"
        webView.delegate = self
        let url = URL (string: reportLink)
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
        let rightBtn = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(self.downloadFile))
        
        let rightBtn2 = UIBarButtonItem(image: UIImage(named: "sharing"), style: .plain, target: self, action: #selector(self.shareFile))
        self.navigationItem.rightBarButtonItems = [rightBtn, rightBtn2]
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
    
    @objc func downloadFile() {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        let destination = DownloadRequest.suggestedDownloadDestination()
        Alamofire.download(reportLink, to: destination).response { response in
            ShowLoader.stopLoader()
            let activityViewController = UIActivityViewController(activityItems: [response.temporaryURL!], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        
       
        }
        
    }
    
    @objc func shareFile() {
        let URL = NSURL(string: reportLink)!
        let activityViewController = UIActivityViewController(activityItems: [URL], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
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
