//
//  UploadPrescriptionViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 05/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire
import SwiftyJSON

class UploadPrescriptionViewController: UIViewController, cancelPhotoDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var uploadImage: UIImageView!
    var imagePicker = UIImagePickerController()
    var chosenImage:UIImage!
    var albumArr:[UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        self.title = "Upload Prescription"
        
    }
    @IBAction func galleryAction(_ sender: UIButton) {
        self.openLibrary()
    }
    
    @IBAction func cameraAction(_ sender: UIButton) {
        self.openCamera()
    }
    
    @IBAction func myPrescriptionAction(_ sender: UIButton) {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "MyPrescriptionViewController") as! MyPrescriptionViewController
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        self.uploadPrescriptionTo1Mg()
        
       // let storyboard = UIStoryboard(name: "Main", bundle: nil)
       // let nextView = storyboard.instantiateViewController(withIdentifier: "OrderInfoViewController") as! OrderInfoViewController
       //  nextView.photoArr = self.albumArr
       // self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func removePhoto(selectedIndex: Int) {
        self.albumArr.remove(at: selectedIndex)
        self.tableView.reloadData()
    }
    
    func uploadPrescriptionTo1Mg() {
        
        
        
        let parameter:[String:String] = [
            "email_id": "gaurav.saini@mailinator.com"
        ]
        
        let headers:[String:String] = [
            "Accept":"application/vnd.healthkartplus.v7+json",
            "HKP-Platform":"HealthKartPlus-9.0.0-Android",
            "X-1mgLabs-Platform":"HealthKartPlus-9.0.0-Android",
            "x-api-key":"pansonic123",
            "Authorization": User.oneMGAuthenticationToken
        ]
        
        //  let activityData = ActivityData()
        // NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        if  !Reachability.isConnectedToNetwork() {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: Message.noInternet, withError: nil, onClose: {
                
            })
            
            return
        }
        
        if albumArr.count == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please upload Prescription", withError: nil, onClose: {
            })
            
            return
        }
        
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        //let imgData = UIImageJPEGRepresentation(albumArr[0], 0.7)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            for img in self.albumArr {
                let imgData = UIImageJPEGRepresentation(img, 0.5)!
                multipartFormData.append(imgData, withName: "file",fileName: "file.jpg", mimeType: "image/jpg")
            }
            for (key, value) in parameter {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: Webservice.uploadPrescription, headers:headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    let json = JSON(response.result.value)
                    print(json)
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    if json["status"].stringValue == "0" {
                      //  self.pdfView.removeFromSuperview()
                        //self.orderNowBtn.removeFromSuperview()
                        print(json["result"][0]["result"]["id"].stringValue)
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let nextView = storyboard.instantiateViewController(withIdentifier: "OrderInfoViewController") as! OrderInfoViewController
                        nextView.photoArr = self.albumArr
                       // nextView.prescriptionId = json["result"][0]["result"]["cpId"].stringValue
                        Prescription.prescriptionId = json["result"][0]["result"]["cpId"].stringValue
                        Prescription.prescriptionUrl = json["result"][0]["result"]["alternateSizeImageURLs"]["med"].stringValue
                        self.navigationController?.pushViewController(nextView, animated: true)
                    }
                    
                }
                
            case .failure(let encodingError):
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
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

extension UploadPrescriptionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.albumArr.count == 0 {
            return 1
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.albumArr.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as! PrescriptionCell
            cell.selectionStyle = .none
            return cell
        }else{
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionPhotoCell", for: indexPath) as! PrescriptionPhotoCell
                cell.delegate = self
                cell.showPhotos(albumArr: albumArr)
                cell.selectionStyle = .none
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionCell", for: indexPath) as! PrescriptionCell
                cell.selectionStyle = .none
                return cell
            }
        }
        
    }
}

extension UploadPrescriptionViewController: UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    
    @IBAction func changePicture(_ sender: Any) {
        let refreshAlert = UIAlertController(title: "Picture", message: title, preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction!) in
            self.openLibrary()
            
        }))
        refreshAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction!) in
            self.openCamera()
        }))
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        present(refreshAlert, animated: true, completion: nil)
        
        
    }
    
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
               // let image = self.resizeImage(chosenImage, targetSize: CGSize(width: 100.0, height: 100.0))
                //uploadImage.isHidden = false
                //uploadImage.image = image
                self.albumArr.append(chosenImage)
                self.tableView.reloadData()
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    /*
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
     let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
     if let fileURL =  info[UIImagePickerControllerMediaURL] as? URL {
     do {
     try  FileManager.default.moveItem(at: fileURL, to: documentsDirectoryURL.appendingPathComponent("videoName.mov"))
     
     print("movie saved")
     } catch {
     print(error)
     }
     }
     }*/
    
    
    
    
    // take phota using camera
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // take photo from library
    func openLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            print("Button capture")
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
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

