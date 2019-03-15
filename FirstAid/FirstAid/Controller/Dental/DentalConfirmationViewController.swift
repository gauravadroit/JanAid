//
//  DentalConfirmationViewController.swift
//  JanAid
//
//  Created by Adroit MAC on 04/01/19.
//  Copyright © 2019 Adroit MAC. All rights reserved.
//

import UIKit
import SDWebImage

class DentalConfirmationViewController: UIViewController {

    @IBOutlet weak var clinicImage: UIImageView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var clinicNameLabel: UILabel!
    
    var clinicImageUrl:String!
    var parameter:[String:String]!
    var hospitalName:String!
    var address:String!
    var date:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Confirm Appointment"
        confirmBtn.layer.cornerRadius = 5
        dateLabel.text = date
        addressLabel.text = address
        clinicNameLabel.text = hospitalName
        clinicImage.sd_setImage(with: URL(string: clinicImageUrl), placeholderImage: UIImage(named: "Hospital"))
        
        confirmBtn.addTarget(self, action: #selector(self.confirmAppointment(sender:)), for: .touchUpInside)
    }
    
    @objc func confirmAppointment(sender:UIButton) {
        if !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.bookDentalAppointment, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                UIApplication.shared.keyWindow?.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextView = storyboard.instantiateViewController(withIdentifier: "ApptSuccessViewController") as! ApptSuccessViewController
                self.navigationController?.pushViewController(nextView, animated: true)
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
