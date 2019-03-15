//
//  DoctorProfile2ViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage
import Toast_Swift

class DoctorProfile2ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    struct education {
        var educationId:String!
        var educationName:String!
        var college:String!
    }
    
    struct feedBack {
        var callOrderId:String!
        var comment:String!
        var patientName:String!
        var feedbackId:String!
        var date:String!
        var rating:String!
    }
    
    var feedbackArr:[feedBack] = []
    
    var educationArr:[education] = []
    
    var fees:String!
    var discount:String!
    var discountAmount:String!
    var discountedFees:String!
    var imageUrl:String!
    var newImageUrl:String!
    var name:String!
    var speciality:String!
    var doctorDescription: String = ""
    var consultationCount:String!
    var UGDegree:String = ""
    var UGCollege:String = ""
    var PGDegree:String = ""
    var PGCollege:String = ""
    var ratingText:String = ""
    
    var gender:String!
    var rating:String!
    var qualification:String!
    var experience:String!
    var professional:String!
    var doctorId:String!
    
    var expertiseArr:[String] = []
    var headerArr:[String] = []
    var professionalArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getDoctorDetails()
        self.title = "Doctor Profile"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }

    func getDoctorDetails() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getDoctorFees + doctorId , headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Data"]["DoctorInformation"][0]["Message"].stringValue == "Success" {
                
                self.fees = json["Data"]["DoctorInformation"][0]["Fee"].stringValue
                self.ratingText = json["Data"]["DoctorInformation"][0]["RatingText"].stringValue
                self.discount = json["Data"]["DoctorInformation"][0]["DiscountPercentage"].stringValue
                self.discountedFees = json["Data"]["DoctorInformation"][0]["SpecialityOfferAmount"].stringValue
                self.imageUrl = json["Data"]["DoctorInformation"][0]["DocImage"].stringValue
                self.name = json["Data"]["DoctorInformation"][0]["DoctorName"].stringValue
                self.doctorDescription = json["Data"]["DoctorInformation"][0]["Description"].stringValue
                self.qualification =  json["Data"]["DoctorInformation"][0]["Qualification"].stringValue
                self.rating =  json["Data"]["DoctorInformation"][0]["Ratings"].stringValue
                self.experience =  json["Data"]["DoctorInformation"][0]["Experience"].stringValue
                self.speciality =  json["Data"]["DoctorInformation"][0]["SpecialityName"].stringValue
                self.gender = json["Data"]["DoctorInformation"][0]["GenderName"].stringValue
                self.consultationCount = json["Data"]["DoctorInformation"][0]["ConsultationCount"].stringValue
                self.professional = json["Data"]["DoctorInformation"][0]["ProfessionalDetail"].stringValue
                self.newImageUrl = json["Data"]["DoctorInformation"][0]["DoctorProfilePicture"].stringValue
               
                for data in json["Data"]["DoctorExpertise"].arrayValue {
                    self.expertiseArr.append(data["ExpertiseName"].stringValue)
                }
                
                for data in json["Data"]["DoctorEducation"].arrayValue {
                    self.educationArr.append(education.init(
                        educationId: data["EducationID"].stringValue,
                        educationName: data["EducationName"].stringValue,
                        college: data["College"].stringValue
                    ))
                }
                
                for data in json["Data"]["ProfessionalDetails"].arrayValue {
                    self.professionalArr.append(data["ProfessionalDetail"].stringValue)
                }
                
                for  data in json["Data"]["Feedback"].arrayValue {
                    self.feedbackArr.append(feedBack.init(
                        callOrderId: data["CallOrderID"].stringValue,
                        comment: data["Comment"].stringValue,
                        patientName: data["PatientName"].stringValue,
                        feedbackId: data["FeedbackID"].stringValue,
                        date: data["SubmittedAt"].stringValue,
                        rating: data["Rating"].stringValue
                    ))
                }
                
                self.headerArr = [" ","ABOUT ME","AREAS OF EXPERTISE", "EDUCATION","PROFESSIONAL DETAIL","REVIEWS"]
               self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
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

extension DoctorProfile2ViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.name  == nil {
            return 0
        }
        
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return self.educationArr.count
        }else if section == 4 {
            return self.professionalArr.count
        }else if section == 5 {
            return self.feedbackArr.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "doctorInfoCell", for: indexPath) as! doctorInfoCell
            cell.doctorImage.sd_setImage(with: URL(string: self.newImageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
            cell.nameLabel.text = self.name
            cell.consultationCountLabel.text = self.consultationCount + " Patient Consulted"
            cell.starRatingLabel.layer.cornerRadius = 5
            cell.starRatingLabel.layer.masksToBounds = true
            
            if self.rating == "0" {
                cell.starRatingLabel.text = self.ratingText
                cell.starRatingLabel.backgroundColor = UIColor.clear
                cell.starRatingLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            }else{
                cell.starRatingLabel.text = " " +  self.rating + " ★ "
                cell.starRatingLabel.backgroundColor = UIColor(red: 19.0/255.0, green: 166.0/255.0, blue: 37.0/255.0, alpha: 1.0)
                cell.starRatingLabel.textColor = UIColor.white
            }
            
            
            if experience == "_" {
                cell.experienceLabel.text = " - "
            }else{
                cell.experienceLabel.text = self.experience + " experience,"
            }
            
            cell.feeLabel.text = "Fee: ₹" +  self.fees
            cell.qualificationLabel.text = self.qualification
            cell.specialityLabel.text = self.speciality
        
            cell.selectionStyle = .none
            return cell
        }else if  indexPath.section == 1 && indexPath.row == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorAboutCell", for: indexPath) as! DoctorAboutCell
            self.doctorDescription = self.doctorDescription.replacingOccurrences(of: "<br>", with: "\n")
            cell.aboutLabel.text =  self.doctorDescription
            cell.selectionStyle = .none
            return cell
        } else  if  indexPath.section == 2 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorExpertiseCell", for: indexPath) as! DoctorExpertiseCell
            cell.setExpertise(dataArr: self.expertiseArr)
            cell.selectionStyle = .none
            return cell
        }else if  indexPath.section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EducationCell
            cell.collegeLabel.text = self.educationArr[indexPath.row].college
            cell.degreeLabel.text = self.educationArr[indexPath.row].educationName
            
            cell.selectionStyle = .none
            return cell
        }else if  indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DoctorProfessionalDetailsCell", for: indexPath) as! DoctorProfessionalDetailsCell
            cell.professionalLabel.text = self.professionalArr[indexPath.row]
            
            cell.selectionStyle = .none
            return cell
        }else if  indexPath.section == 5 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PatientReviewCell", for: indexPath) as! PatientReviewCell
            cell.nameLabel.text = feedbackArr[indexPath.row].patientName
            cell.ratingLabel.text = feedbackArr[indexPath.row].rating + " ★ "
            cell.reviewLabel.text = feedbackArr[indexPath.row].comment
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }else{
            let view = tableView.dequeueReusableCell(withIdentifier: "DoctorHeaderCell") as! DoctorHeaderCell
            view.headerCell.text = self.headerArr[section]
            return view
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
}
