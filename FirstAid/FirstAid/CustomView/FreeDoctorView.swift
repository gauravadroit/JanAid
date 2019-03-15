//
//  FreeDoctorView.swift
//  FirstAid
//
//  Created by Adroit MAC on 03/12/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

protocol freeDoctorDelegate {
    func selectedDoctor(index:Int)
}

class FreeDoctorView: UIView {

    @IBOutlet weak var bookNowBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    var doctorArr:[doctor] = []
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var view:UIView!
    var delegate:freeDoctorDelegate?
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "FreeDoctorView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        self.collectionView.register(UINib(nibName: "FreeDoctorCell", bundle: nil), forCellWithReuseIdentifier: "FreeDoctorCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        return view
    }
    
    func loadData(data:[doctor]) {
        self.doctorArr = data
        self.collectionView.reloadData()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }

}

extension FreeDoctorView: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return doctorArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FreeDoctorCell", for: indexPath) as! FreeDoctorCell
        
        cell.nameLabel.text = doctorArr[indexPath.row].doctorName
        cell.specialityLabel.text = doctorArr[indexPath.row].specialityName
        cell.degreeLabel.text = doctorArr[indexPath.row].qualification
        cell.experienceLabel.text = doctorArr[indexPath.row].experience
        if doctorArr[indexPath.row].rating == "0" {
            cell.starRatingLabel.text = ""
            cell.starRatingLabel.backgroundColor = UIColor.clear
            cell.starRatingLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            cell.starRatingLabel.font = UIFont(name: "Helvetica", size: 10.0)
        }else{
            cell.starRatingLabel.text = " " + doctorArr[indexPath.row].rating + " ★ "
            cell.starRatingLabel.backgroundColor = UIColor(red: 19.0/255.0, green: 166.0/255.0, blue: 37.0/255.0, alpha: 1.0)
            cell.starRatingLabel.textColor = UIColor.white
            cell.starRatingLabel.font = UIFont(name: "Helvetica", size: 17.0)
        }
      
        cell.doctorImage.sd_setImage(with: URL(string: self.doctorArr[indexPath.row].newImageUrl), placeholderImage: #imageLiteral(resourceName: "GPdoctor"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.selectedDoctor(index: indexPath.row)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 175.0 , height: 200.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
