//
//  PrescriptionPhotoCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 05/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

protocol cancelPhotoDelegate {
    func removePhoto(selectedIndex:Int)
}

class PrescriptionPhotoCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var photoArr:[UIImage] = []
    var delegate:cancelPhotoDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func showPhotos(albumArr:[UIImage]) {
        photoArr = albumArr
        self.collectionView.reloadData()
    }
    
    @objc func removePhotoAction(sender:UIButton) {
        self.photoArr.remove(at: sender.tag)
         delegate?.removePhoto(selectedIndex: sender.tag)
        self.collectionView.reloadData()
    }
    
}

extension PrescriptionPhotoCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.prescriptionImageView.image = photoArr[indexPath.row]
        cell.cancelBtn.tag = indexPath.row
        cell.cancelBtn.addTarget(self, action: #selector(self.removePhotoAction(sender:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       /* let paddingSpace = (10 ) * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        var heightPerItem:CGFloat!
        /*let heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)!)/4) - 5
         
         let heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4*/
        
        if UIDevice.current.modelName == "iPhone X" {
            heightPerItem = (UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - (self.tabBarController?.tabBar.frame.height)!)/4
        }else{
            heightPerItem = ((UIScreen.main.bounds.height - (self.navigationController?.navigationBar.frame.height)! - 120)/4)
        }*/
        
        return CGSize(width: 100 , height: 116)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
