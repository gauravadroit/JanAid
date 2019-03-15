//
//  RecieptViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class RecieptViewController: UIViewController {

    var paymentView:PaymentReceipt!
    var receiptData:[String:String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Payment Reciept"

       paymentView = PaymentReceipt(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        paymentView.setData(data: receiptData)
        self.view.addSubview(paymentView)
        
        let rightBtn = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(self.downloadPdf))
        self.navigationItem.rightBarButtonItem = rightBtn
    }
    
    @objc func downloadPdf() {
      let paymentReciept = paymentView.takeScreenshot()
        self.createPDFDataFromImage(image: paymentReciept)
    }
    
    func createPDFDataFromImage(image: UIImage) {
        let pdfData = NSMutableData()
        let imgView = UIImageView.init(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()
        
       
        
        //try saving in doc dir to confirm:
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = dir?.appendingPathComponent("JanAid_Reciept_\(self.getDate()).pdf")
        print(path)
        do {
            try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
        } catch {
            print("error catched")
        }
        
        let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
       // return pdfData
    }

    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
        return formatter.string(from: date)
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
