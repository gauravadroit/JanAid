//
//  DoctorExpertiseCell.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class DoctorExpertiseCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    var expertiseArr:[String] = []
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
    func setExpertise(dataArr:[String]) {
        expertiseArr = dataArr
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expertiseArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExpertiseCell", for: indexPath) as! ExpertiseCell
        
        cell.expertiseLabel.text = self.expertiseArr[indexPath.row]
        
        return cell
    }

}
