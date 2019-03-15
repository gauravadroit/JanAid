//
//  ShowAttachmentViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 22/09/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage
import NVActivityIndicatorView


class ShowAttachmentViewController: UIViewController, UIScrollViewDelegate,UIWebViewDelegate {

    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    var attachmentUrl:String!
    var webView:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Attachment"
        
        if attachmentUrl.contains(".pdf") {
            webView = UIWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
            webView.scalesPageToFit = true
            webView.delegate = self
             self.view.addSubview(webView)
            let url = URL (string: attachmentUrl!)
            let requestObj = URLRequest(url: url!)
            webView.loadRequest(requestObj)
        }else{
            attachmentImageView.sd_setImage(with: URL(string: attachmentUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor").withRenderingMode(.alwaysTemplate))
        }
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return attachmentImageView
    }
    
    func drawPDFfromURL(url: URL) -> UIImage? {
        guard let document = CGPDFDocument(url as CFURL) else { return nil }
        guard let page = document.page(at: 1) else { return nil }
        
        let pageRect = page.getBoxRect(.mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        let img = renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            
            ctx.cgContext.translateBy(x: 0.0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            
            ctx.cgContext.drawPDFPage(page)
        }
        
        return img
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
         
        ShowLoader.startLoader(view: self.view)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        ShowLoader.stopLoader()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        ShowLoader.stopLoader()
        self.view.makeToast("Unable to process", duration: 3.0, position: .bottom)
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
