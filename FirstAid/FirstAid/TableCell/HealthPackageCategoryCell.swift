//
//  HealthPackageCategoryCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

protocol FeatureLabDelegate {
    func featureLab(id:String)
}

class HealthPackageCategoryCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var categoryArr:[HealthCategory] = []
    var delegate:FeatureLabDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func showCategories(category:[HealthCategory]) {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.categoryArr = category
        self.collectionView.reloadData()
    }

}


extension HealthPackageCategoryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HealthCategoryCell", for: indexPath) as! HealthCategoryCell
       cell.titleLabel.text = categoryArr[indexPath.row].Name
       // cell.categoryImage.image
        cell.categoryImage.sd_setImage(with: URL(string: categoryArr[indexPath.row].image), placeholderImage: #imageLiteral(resourceName: "pencil"))
      
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
        
        return CGSize(width: 120 , height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       delegate?.featureLab(id: categoryArr[indexPath.row].id)
        
    }
    
}
