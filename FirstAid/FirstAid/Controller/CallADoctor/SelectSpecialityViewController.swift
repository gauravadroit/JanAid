//
//  SelectSpecialityViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 04/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class SelectSpecialityViewController: UIViewController,SpecialityDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var specialityText: UITextField!
    var specialityId:String!
    
    struct doctor {
        var discountPercentage:String!
        var gender:String!
        var specialityName:String!
        var doctorName:String!
        var rating:String!
        var doctorId:String!
        var fees:String!
        var offerAmount:String!
        var discountAmt:String!
        var qualification:String!
        var imageUrl:String!
        var experience:String!
    }
    
    var doctorArr:[doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Speciality Consultation"
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.getDoctorList(specialityId: self.specialityId)
        
        self.setIconInTextfield(textField: specialityText)
    }
    
    func setIconInTextfield(textField:UITextField) {
        
        let icon = #imageLiteral(resourceName: "search").withRenderingMode(.alwaysTemplate)
        let dropdown = UIImageView(image: icon)
        dropdown.tintColor = UIColor.black
        dropdown.frame = CGRect(x: 0.0, y: 0.0, width: dropdown.image!.size.width+15.0, height: dropdown.image!.size.height);
        dropdown.contentMode = UIViewContentMode.center
        textField.rightView = dropdown;
        textField.rightViewMode = UITextFieldViewMode.always
    }


    @IBAction func selectSpecialityAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SpecialityViewController") as! SpecialityViewController
        nextView.delegate = self
        self.present(nextView, animated: true, completion: nil)
    }
    
    func speciality(specialityId: String, specialityName: String) {
        self.specialityId = specialityId
        self.specialityText.text = specialityName
        self.getDoctorList(specialityId: self.specialityId)
    }
    
    func getDoctorList(specialityId:String)  {
        let parameter:[String:String] = [
            "PageSize":"100",
            "PageNumber":"1",
            "Value1":specialityId,
            "Value2":"0",
            "Value3":"0"
        ]
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.getDoctorListForCall, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            
            if json["Message"].stringValue == "Success" {
                self.doctorArr = []
                for data in json["Data"].arrayValue {
                    self.doctorArr.append(doctor.init(
                        discountPercentage: data["DiscountPercentage"].stringValue,
                        gender: data["Gender"].stringValue,
                        specialityName: data["SpecialityName"].stringValue,
                        doctorName: data["DoctorName"].stringValue,
                        rating: data["Rating"].stringValue,
                        doctorId: data["DoctorID"].stringValue,
                        fees: data["Fee"].stringValue,
                        offerAmount: data["OfferedAmount"].stringValue,
                        discountAmt: data["DiscountAmount"].stringValue,
                        qualification: data["Qualification"].stringValue,
                        imageUrl: data["DocImage"].stringValue,
                        experience: data["Experience"].stringValue
                    ))
                }
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
             NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        }
        
    }
    
    @objc func selectBtnAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "PayDetailViewController") as! PayDetailViewController
        nextView.fees = doctorArr[sender.tag].fees
        nextView.discount = doctorArr[sender.tag].discountPercentage
        nextView.discountAmount = doctorArr[sender.tag].discountAmt
        nextView.discountedFees = doctorArr[sender.tag].offerAmount
        nextView.name = doctorArr[sender.tag].doctorName
        nextView.speciality = doctorArr[sender.tag].qualification
        nextView.imageUrl = doctorArr[sender.tag].imageUrl
        nextView.doctorId = doctorArr[sender.tag].doctorId
        self.navigationController?.pushViewController(nextView, animated: true)
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

extension SelectSpecialityViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doctorArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectDoctorCell", for: indexPath) as! SelectDoctorCell
        cell.discountLabel.text =  doctorArr[indexPath.row].discountPercentage + "%"
        cell.experienceLabel.text = doctorArr[indexPath.row].experience
       // cell.feesLabel.text = "₹" + doctorArr[indexPath.row].fees
        cell.nameLabel.text = doctorArr[indexPath.row].doctorName
        cell.offerAmtLabel.text = "₹" + doctorArr[indexPath.row].offerAmount
        cell.qualificationLabel.text = doctorArr[indexPath.row].qualification
        cell.ratinglabel.text = "  " + doctorArr[indexPath.row].rating + " ★"
        cell.doctorImageView.sd_setImage(with: URL(string: Webservice.baseUrl + self.doctorArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        
        if doctorArr[indexPath.row].gender == "Male" {
            cell.genderImageView.image = UIImage(named: "man")
        }else{
            cell.genderImageView.image = UIImage(named: "girl")
        }
        
        let attributeString =  NSMutableAttributedString(string: "₹\(doctorArr[indexPath.row].fees!)")
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle,
                                     value: NSUnderlineStyle.styleSingle.rawValue,
                                     range: NSMakeRange(0, attributeString.length))
        cell.feesLabel.attributedText = attributeString
        cell.selectBtn.tag = indexPath.row
        cell.selectBtn.addTarget(self, action: #selector(self.selectBtnAction(sender:)), for: UIControlEvents.touchUpInside)
        
        cell.selectionStyle = .none
        return cell
        
    }
    
}
