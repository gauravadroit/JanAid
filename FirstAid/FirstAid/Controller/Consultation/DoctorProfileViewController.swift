//
//  DoctorProfileViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 30/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class DoctorProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var feeLabel: UILabel!
    @IBOutlet weak var experienceLabel: UILabel!
    @IBOutlet weak var qualificationLabel: UILabel!
    @IBOutlet weak var specialityLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var doctorImage: UIImageView!
    
    @IBOutlet weak var noOfConsultationLabel: UILabel!
    @IBOutlet weak var expertiseLabel: UILabel!
    @IBOutlet weak var UGLabel: UILabel!
    @IBOutlet weak var PGLabel: UILabel!
    @IBOutlet weak var ugCollegeLabel: UILabel!
    @IBOutlet weak var pgCollegeLabel: UILabel!
    @IBOutlet weak var professionalLabel: UILabel!
    
    struct education {
        var educationId:String!
        var educationName:String!
        var college:String!
    }
    
    var educationArr:[education] = []
    
    var fees:String!
    var discount:String!
    var discountAmount:String!
    var discountedFees:String!
    var imageUrl:String!
    var name:String!
    var speciality:String!
    var doctorDescription: String = ""
    var consultationCount:String!
    var UGDegree:String = ""
    var UGCollege:String = ""
    var PGDegree:String = ""
    var PGCollege:String = ""
    
    var gender:String!
    var rating:String!
    var qualification:String!
    var experience:String!
    var professional:String!
    
    var expertiseArr:[String] = []
    
   
    var doctorId:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.getDoctorDetails()
        self.title = "Doctor Profile"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        doctorImage.layer.cornerRadius = doctorImage.frame.size.height/2
        doctorImage.layer.masksToBounds = true
        doctorImage.layer.borderWidth = 1
        doctorImage.layer.borderColor = Webservice.themeColor.cgColor
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
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
                
                self.setData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
        }
    }
    
    func setData() {
        
        self.doctorNameLabel.text = self.name
        self.qualificationLabel.text = self.qualification
        self.experienceLabel.text = self.experience + " experience,"
        self.feeLabel.text = "Fee: ₹" + self.discountedFees
        self.doctorImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        self.specialityLabel.text = self.speciality
        self.doctorDescription = self.doctorDescription.replacingOccurrences(of: "<br>", with: "\n")
        self.aboutMeLabel.text = self.doctorDescription
        self.noOfConsultationLabel.text = self.consultationCount + " Patient Consulted"
        self.professionalLabel.text = professional
        
        self.tableView.reloadData()
        self.collectionView.reloadData()
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

extension DoctorProfileViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expertiseArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpertiseCell", for: indexPath) as! ExpertiseCell
        
        cell.expertiseLabel.text = self.expertiseArr[indexPath.row]
        
        return cell
    }
   
}

extension DoctorProfileViewController:UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return educationArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EducationCell", for: indexPath) as! EducationCell
        cell.collegeLabel.text = educationArr[indexPath.row].college
        cell.degreeLabel.text = educationArr[indexPath.row].educationName
        
        cell.selectionStyle = .none
        return cell
    }
}

