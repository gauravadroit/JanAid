//
//  BannerSliderCell2.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/08/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

protocol BannerDelegate {
    func BannerAction(type:String)
}

class BannerSliderCell2: UICollectionViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    var sectionInsets =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    var delegate:BannerDelegate?
    var height:CGFloat!
    var timer:Timer!
   
    var bannerPathDic:[[String:String]] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(UINib(nibName: "AddMembershipCell", bundle: nil), forCellWithReuseIdentifier: "AddMembershipCell")
        self.timer = nil
        collectionView.delegate = self
        collectionView.dataSource = self

    }
    
    func loadCollectionView(height:CGFloat,pathDic:[[String:String]]) {
       
        bannerPathDic = pathDic
        self.height = height
        collectionView.reloadData()
        if bannerPathDic.count != 0 {
            self.addTimer()
        }
    }
    
    func addTimer() {
        let timer1 = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.nextPage), userInfo: nil, repeats: true)
        RunLoop.main.add(timer1, forMode: RunLoopMode.commonModes)
        self.timer = timer1
    }
    
    
    func resetIndexPath() -> IndexPath {
        let currentIndexPath = self.collectionView.indexPathsForVisibleItems.last
        let currentIndexPathReset = IndexPath(item: (currentIndexPath?.item)!, section: 0)
        self.collectionView.scrollToItem(at: currentIndexPathReset, at: UICollectionViewScrollPosition.left, animated: true)
        return currentIndexPath!
    }
    
    func removeTimer() {
        if self.timer != nil {
            self.timer.invalidate()
        }
        self.timer = nil
    }
    
    
    @objc func nextPage() {
        let currentIndexPathReset:IndexPath = self.resetIndexPath()
        var nextItem = currentIndexPathReset.item + 1
        let nextSection = currentIndexPathReset.section
        if nextItem == bannerPathDic.count{
            nextItem = 0
        }
        var nextIndexPath = IndexPath(item: nextItem, section: nextSection)
        if nextItem == 0 {
            self.collectionView.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.left, animated: false)
        }
        self.collectionView.scrollToItem(at: nextIndexPath, at: UICollectionViewScrollPosition.left, animated: true)
    }
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.addTimer()
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = collectionView.contentOffset
        visibleRect.size = collectionView.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath: IndexPath? = collectionView.indexPathForItem(at: visiblePoint)
      //  pageControlView.currentPage = (visibleIndexPath?.row)!
    }
    
}

extension BannerSliderCell2:UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if bannerPathDic.count == 0 {
            return 1
        }else{
            return bannerPathDic.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if bannerPathDic.count != 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCell2", for: indexPath) as! BannerCell2
            cell.bannerImageView.tintColor = UIColor.white
        
            if bannerPathDic[indexPath.row]["bannerUrl"]!.contains(".gif") {
                let gifURL : String =  bannerPathDic[indexPath.row]["bannerUrl"]!
                let jeremyGif = UIImage.gifImageWithURL(gifURL)
                cell.bannerImageView.image = jeremyGif
            }else{
                cell.bannerImageView.sd_setImage(with: URL(string: bannerPathDic[indexPath.row]["bannerUrl"]!), placeholderImage: #imageLiteral(resourceName: "Default_Banner").withRenderingMode(.alwaysTemplate))
                
            }
            
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddMembershipCell", for: indexPath) as! AddMembershipCell
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20.0 , height: self.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if bannerPathDic.count == 0 {
            delegate?.BannerAction(type: "applyCoupon")
        }else{
            delegate?.BannerAction(type: bannerPathDic[indexPath.row]["code"]!)
        }
    }
    
}

