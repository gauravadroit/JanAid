//
//  SpecialityListViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 13/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SDWebImage

class SpecialityListViewController: UIViewController, freeDoctorDelegate {
    
    

   // @IBOutlet weak var contentViewConstraint: NSLayoutConstraint!
   // @IBOutlet weak var getNowBtn: UIButton!
   // @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    let itemsPerRow:CGFloat = 3
    @IBOutlet weak var searchText: UITextField!
    var fromSideMenu = "false"
   // var doctorView:FreeDoctorView!
  //  var freeSpecialityId:String!
   // var freeSpecialityName:String!
    
    struct Speciality {
        var ID:String!
        var name:String!
        var imageUrl:String!
        var isDisable:String!
    }
    var specialityArr:[Speciality] = []
    var filterSpecialityArr:[Speciality] = []
    var doctorArr:[doctor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Select Speciality"
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.searchText.delegate = self
        self.getSpeciality()
       /* if User.isFreeConsultationApplicable == "True" {
            self.getFreeDoctors()
        }*/
        self.setIconInTextfield(textField: searchText)
       // self.getNowBtn.addTarget(self, action: #selector(self.getNowAction(sender:)), for: .touchUpInside)
    
        
        if fromSideMenu == "true" {
            let sidebutton = UIBarButtonItem(image: UIImage(named: "bar"), style: .plain, target: self, action: #selector(self.menuAction(_:)))
            self.navigationItem.leftBarButtonItem  = sidebutton
        }
        
    }
    
    @IBAction func menuAction(_ sender: UIBarButtonItem) {
        self.menuContainerViewController.toggleLeftSideMenuCompletion { () -> Void in
        }
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
   
    func getSpeciality(search:String = "0") {
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
         
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getSpeciality2 + search, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
             self.specialityArr = []
            
            if json["Message"].stringValue == "Success" {
               
                for data in json["Data"].arrayValue {
                    self.specialityArr.append(Speciality.init(
                        ID: data["GroupID"].stringValue,
                        name: data["GroupName"].stringValue,
                        imageUrl: data["IconURL"].stringValue,
                        isDisable: data["Status"].stringValue
                    ))
                }
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
            self.filterSpecialityArr = self.specialityArr
            self.collectionView.reloadData()
            
            
        }) { (error) in
            print(error)
             self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    
    func getFreeDoctors() {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.getDataUsingHeaderAndGet(path: Webservice.getFreeDoctors, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Message"].stringValue == "Success" {
                self.doctorArr = []
              //  self.freeSpecialityId = json["Data2"][0]["GroupID"].stringValue
              //  self.freeSpecialityName = json["Data2"][0]["GroupName"].stringValue
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
                        experience: data["Experience"].stringValue,
                        newImageUrl: data["DoctorProfilePicture"].stringValue,
                        ratingText: data["RatingText"].stringValue
                    ))
                }
            }
            
            /*self.doctorView = FreeDoctorView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 245.0))
            self.doctorView.bookNowBtn.addTarget(self, action: #selector(self.bookNowAction(sender:)), for: .touchUpInside)
            self.contentViewConstraint.constant = 245.0
            self.doctorView.loadData(data: self.doctorArr)
            self.doctorView.delegate = self
            self.contentView.addSubview(self.doctorView)*/
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
        }
    }
    
    func selectedDoctor(index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "DoctorProfile2ViewController") as! DoctorProfile2ViewController
        nextview.doctorId = doctorArr[index].doctorId
        self.navigationController?.pushViewController(nextview, animated: true)
        
    }
    
    @objc func bookNowAction(sender:UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "AvailableDoctorViewController") as! AvailableDoctorViewController
        //nextview.specialityId = freeSpecialityId
        nextview.doctorArr = self.doctorArr
        //nextview.specialityName = freeSpecialityName
        self.navigationController?.pushViewController(nextview, animated: true)
        
    }
    
    @objc func getNowAction(sender:UIButton) {
        let alert = UIAlertController(title: "", message: "Enter membership code.", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = ""
            textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
            textField.tag = 100
            textField.delegate = self
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            
            print("Text field: \(String(describing: textField?.text))")
            self.applyPromocode(promoCode: (textField?.text)!)
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert) in
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func applyPromocode(promoCode:String) {
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
            })
            return
        }
        
        let parameter:[String:String] = [
            "PatientID": User.patientId,
            "Promocode":promoCode
        ]
        
        print(parameter)
        
        ShowLoader.startLoader(view: self.view)
        
        DataProvider.sharedInstance.sendDataUsingHeaderAndPost(path: Webservice.applyPromocode, dataDict: parameter, headers: Webservice.header, { (json) in
            print(json)
            ShowLoader.stopLoader()
            
            if json["Status"].stringValue == "true" {
                User.isFreeConsultationApplicable = json["Data"][0]["IsFreeConsultationApplicable"].stringValue
                User.UsedPromoID =  json["Data"][0]["UsedPromoID"].stringValue
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
                self.getFreeDoctors()
            }else{
                self.view.makeToast(json["Message"].stringValue, duration: 3.0, position: .bottom)
            }
            
        }) { (error) in
            print(error)
            self.view.makeToast("Server not responding.", duration: 3.0, position: .bottom)
            ShowLoader.stopLoader()
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

extension SpecialityListViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterSpecialityArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpecialityCell", for: indexPath) as! SpecialityCell
        cell.specialityLabel.text = filterSpecialityArr[indexPath.row].name
        
        
        if filterSpecialityArr[indexPath.row].isDisable == "Disable" {
             cell.specialityImage.tintColor = UIColor.lightGray
            
            cell.specialityImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.filterSpecialityArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "specialityDefault"), options: .continueInBackground) { (image, error, SDImageCacheType, imageUrl) in
                cell.specialityImage.image = image?.withRenderingMode(.alwaysTemplate)
            }
           
            cell.specialityLabel.textColor = UIColor.lightGray
            cell.isUserInteractionEnabled = false
        }else{
            cell.specialityImage.tintColor = UIColor.lightGray
            cell.specialityImage.sd_setImage(with: URL(string: Webservice.baseUrl +  self.filterSpecialityArr[indexPath.row].imageUrl), placeholderImage: #imageLiteral(resourceName: "specialityDefault").withRenderingMode(.alwaysTemplate))
            
            cell.isUserInteractionEnabled = true
            cell.specialityLabel.textColor = UIColor.black
        }

        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (10 ) * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        var widthPerItem = availableWidth / itemsPerRow
        widthPerItem = widthPerItem - 1.0
        
        
        var heightPerItem:CGFloat!
        
        
        heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 50)/4)
        
        return CGSize(width: widthPerItem , height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextview = storyboard.instantiateViewController(withIdentifier: "AvailableDoctorViewController") as! AvailableDoctorViewController
        nextview.specialityId = filterSpecialityArr[indexPath.row].ID
        nextview.specialityName = filterSpecialityArr[indexPath.row].name
        self.navigationController?.pushViewController(nextview, animated: true)
    }
    
}

extension SpecialityListViewController: UITextFieldDelegate {
    
    func filter(name:String) {
        self.filterSpecialityArr =  specialityArr.filter({( speciality : Speciality) -> Bool in
            return speciality.name.lowercased().contains(name.lowercased())
        })
        self.collectionView.reloadData()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.tag == 100 {
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }else if textField.text!.count == 19 {
                return false
            }else if ((textField.text!.count+1)%5 == 0) {
                    textField.text = textField.text! + "-";
            }
            return true
        }else{
            
            let  char = string.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            let allowedCharacter = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
            let aSet = CharacterSet(charactersIn:allowedCharacter).inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            if string == numberFiltered {
                if  (textField.text!.count == 0 || textField.text!.count == 1) && isBackSpace == -92  {
                    self.getSpeciality()
                }else{
                    self.getSpeciality(search: textField.text! + string)
                }
                return true
            }else{
                return false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
