//
//  GPProfileViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CropViewController
import SwiftyJSON
import Alamofire

class GPProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var imagePicker = UIImagePickerController()
    var chosenImage:UIImage!
    var profileImageView:UIImageView!
    
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
    var doctorId:String!
    
    var jsonData:JSON!
    
    var expertiseArr:[String] = []
    var headerArr:[String] = []
    var professionalArr:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Profile"
        
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = false
        self.getDoctorDetails()
    }
    
    func getDoctorDetails() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getDoctorFees + GPUser.memberId , headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            self.jsonData = json
            if json["Data"]["DoctorInformation"][0]["Message"].stringValue == "Success" {
                
                self.fees = json["Data"]["DoctorInformation"][0]["Fee"].stringValue
                self.discount = json["Data"]["DoctorInformation"][0]["DiscountPercentage"].stringValue
                self.discountedFees = json["Data"]["DoctorInformation"][0]["SpecialityOfferAmount"].stringValue
                self.imageUrl = json["Data"]["DoctorInformation"][0]["DoctorProfilePicture"].stringValue
                self.name = json["Data"]["DoctorInformation"][0]["DoctorName"].stringValue
                self.doctorDescription = json["Data"]["DoctorInformation"][0]["Description"].stringValue
                self.qualification =  json["Data"]["DoctorInformation"][0]["Qualification"].stringValue
                self.rating =  json["Data"]["DoctorInformation"][0]["Ratings"].stringValue
                self.experience =  json["Data"]["DoctorInformation"][0]["Experience"].stringValue
                self.speciality =  json["Data"]["DoctorInformation"][0]["SpecialityName"].stringValue
                self.gender = json["Data"]["DoctorInformation"][0]["GenderName"].stringValue
                self.consultationCount = json["Data"]["DoctorInformation"][0]["ConsultationCount"].stringValue
                self.professional = json["Data"]["DoctorInformation"][0]["ProfessionalDetail"].stringValue
                
                /*self.UGCollege = json["Data"]["DoctorEducation"][0]["College"].stringValue
                 self.UGDegree = json["Data"]["DoctorEducation"][0]["EducationName"].stringValue
                 self.PGCollege = json["Data"]["DoctorEducation"][1]["College"].stringValue
                 self.PGDegree = json["Data"]["DoctorEducation"][1]["EducationName"].stringValue*/
                
                self.expertiseArr = []
                self.professionalArr = []
                self.educationArr = []
                
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
                
                self.headerArr = [" ","ABOUT ME","AREAS OF EXPERTISE", "EDUCATION","PROFESSIONAL DETAIL"]
                self.tableView.reloadData()
            }
            
        }) { (error) in
            print(error)
            ShowLoader.stopLoader()
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
        }
    }
    
    
    @objc func editAction(sender:UIButton) {
        if sender.tag == 1 {
            let storyboard = UIStoryboard(name: "GP", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "AboutMeViewController") as! AboutMeViewController
            nextView.aboutme = self.doctorDescription
            self.navigationController?.pushViewController(nextView, animated: true)
        }else{
            let storyboard = UIStoryboard(name: "GP", bundle: nil)
            let nextView = storyboard.instantiateViewController(withIdentifier: "EditGPProfileViewController") as! EditGPProfileViewController
            nextView.jsonData = jsonData
            if sender.tag == 2 {
                nextView.dataType = "expertise"
            }else if sender.tag == 3 {
                nextView.dataType = "education"
            }else if sender.tag == 4 {
                nextView.dataType = "professional"
            }
            self.navigationController?.pushViewController(nextView, animated: true)
        }
       
    }
    
    //MARK: - Upload file
    
    func uploadPicture() {
        
        let parameter:[String:String] = [
            "DoctorID":GPUser.memberId
        ]
        
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        
         
        ShowLoader.startLoader(view: self.view)
        
        //let imgData = UIImageJPEGRepresentation(albumArr[0], 0.7)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            let imgData = UIImageJPEGRepresentation(self.chosenImage, 0.8)!
            multipartFormData.append(imgData, withName: "Files",fileName: "file.jpg", mimeType: "image/jpg")
           
            for (key, value) in parameter {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Webservice.updateDoctorImage, headers:Webservice.header)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                    ShowLoader.stopLoader()
                    
                    if json["Status"].stringValue == "true" {
                       // self.imageUrl = json["Data"].stringValue
                        self.getDoctorDetails()
                       // self.tableView.reloadData()
                        self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                    }
                }
                
            case .failure(let encodingError):
                ShowLoader.stopLoader()
                print(encodingError)
            }
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

extension GPProfileViewController:UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.name  == nil {
            return 0
        }
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            return self.educationArr.count
        }else if section == 4 {
            return self.professionalArr.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "doctorInfoCell", for: indexPath) as! doctorInfoCell
            
            cell.uploadBtn.addTarget(self, action: #selector(self.changePicture), for: .touchUpInside)
            let icon = #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate)
            cell.uploadBtn.setImage(icon, for: .normal)
            cell.uploadBtn.tintColor = UIColor.white
            cell.uploadBtn.layer.cornerRadius = cell.uploadBtn.frame.size.height/2

            
            cell.doctorImage.sd_setImage(with: URL(string: self.imageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
            cell.nameLabel.text = self.name
            cell.consultationCountLabel.text = self.consultationCount + " Patient Consulted"
            if experience == "_" {
                cell.experienceLabel.text = " - "
            }else{
                cell.experienceLabel.text = self.experience + " experience,"
            }
            profileImageView =  cell.doctorImage
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
            view.editBtn.tag = section
            view.editBtn.addTarget(self, action: #selector(self.editAction(sender:)), for: .touchUpInside)
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

extension GPProfileViewController: UINavigationControllerDelegate , UIImagePickerControllerDelegate, CropViewControllerDelegate {
    
    @IBAction func changePicture() {
        let refreshAlert = UIAlertController(title: "Picture", message: title, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction!) in
            self.openLibrary(type: "image")
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.openCamera(type: "image")
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
                self.cropImage(image: chosenImage)
            }
        }
        dismiss(animated: true, completion: nil)
        
    }
    
    // take phota using camera
    func openCamera(type:String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // take photo from library
    func openLibrary(type:String) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func cropImage(image:UIImage) {
        
        self.dismiss(animated: true, completion: nil)
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        self.present(cropViewController, animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        // 'image' is the newly cropped version of the original image
        self.dismiss(animated: true, completion: nil)
        profileImageView.image = image
        self.uploadPicture()
    }
    
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
