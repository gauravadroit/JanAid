//
//  OrderInfoViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 06/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class OrderInfoViewController: UIViewController {
    @IBOutlet weak var radio1Btn: UIButton!
    @IBOutlet weak var radio2Btn: UIButton!
    @IBOutlet weak var radio3Btn: UIButton!
    
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var dosageTextfield: UITextField!
    @IBOutlet weak var commentextView: UITextView!
    
    @IBOutlet weak var view3Heightconstraint: NSLayoutConstraint!
    @IBOutlet weak var view2HeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var view1HeightConstraint: NSLayoutConstraint!
 
    var sectionInsets =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var photoArr:[UIImage] = []
    var selectedFlag:Int = 0
    var labFlag:Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        view1.isHidden = true
        view2.isHidden = true
        view1HeightConstraint.constant = 45
        view2HeightConstraint.constant = 45
       // view3Heightconstraint.constant = 45
        collectionView.isHidden = true
        dosageTextfield.keyboardType = .numberPad
        radio1Btn.tag = 1
        radio2Btn.tag = 2
        radio3Btn.tag = 3
        
        radio1Btn.addTarget(self, action: #selector(self.radioAction(sender:)), for: .touchUpInside)
        radio2Btn.addTarget(self, action: #selector(self.radioAction(sender:)), for: .touchUpInside)
        radio3Btn.addTarget(self, action: #selector(self.radioAction(sender:)), for: .touchUpInside)
        
    }
    
    
   @objc func radioAction(sender:UIButton) {
        if sender.tag == 1 {
            selectedFlag = 1
            view1.isHidden = false
            view1HeightConstraint.constant = 100
            radio1Btn.setImage(#imageLiteral(resourceName: "radioselected"), for: .normal)
            radio2Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            radio3Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            view2.isHidden = true
            view2HeightConstraint.constant = 45
        }else if sender.tag == 2 {
            selectedFlag = 2
            view1.isHidden = true
            view1HeightConstraint.constant = 45
            radio1Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            radio2Btn.setImage(#imageLiteral(resourceName: "radioselected"), for: .normal)
            radio3Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            view2.isHidden = false
            view2HeightConstraint.constant = 130
        }else if sender.tag == 3 {
            selectedFlag = 3
            view1.isHidden = true
            view1HeightConstraint.constant = 45
            radio1Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            radio2Btn.setImage(#imageLiteral(resourceName: "radio"), for: .normal)
            radio3Btn.setImage(#imageLiteral(resourceName: "radioselected"), for: .normal)
            view2.isHidden = true
            view2HeightConstraint.constant = 45
        }
    }

    @IBAction func hideAction(_ sender: UIButton) {
        if sender.titleLabel?.text == "Show" {
            //view3Heightconstraint.constant = 200
            collectionView.isHidden = false
            sender.setTitle("Hide", for: .normal)
        }else{
           // view3Heightconstraint.constant = 45
            collectionView.isHidden = true
            sender.setTitle("Show", for: .normal)
        }
    }
    
    @IBAction func labTestAction(_ sender: UIButton) {
        if labFlag == 0 {
            sender.setImage(#imageLiteral(resourceName: "checked"), for: .normal)
            labFlag = 1
        }else {
            sender.setImage(#imageLiteral(resourceName: "unchecked"), for: .normal)
            labFlag = 0
        }
    }
    
    
    @IBAction func continueAction(_ sender: UIButton) {
        
        if self.selectedFlag == 0 {
            Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please select the option.")
            return
        }else if self.selectedFlag == 1 {
            if self.dosageTextfield.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill the value.")
                return
            }
            Prescription.orderChoice = "1"
            Prescription.durationInDays = dosageTextfield.text!
            Prescription.comment = "order everything as per prescription"
            Prescription.labTest = self.labFlag
            
        }else if self.selectedFlag == 2 {
            if self.commentextView.text! == "" {
                Utility.showMessageDialog(onController: self, withTitle: "Alert", withMessage: "Please fill the value.")
                return
            }
            
            Prescription.orderChoice = "2"
            Prescription.durationInDays = ""
            Prescription.comment = commentextView.text!
            Prescription.labTest = self.labFlag
            
        }else if self.selectedFlag == 3 {
            Prescription.orderChoice = "3"
            Prescription.durationInDays = ""
            Prescription.comment = "Call me for details"
            Prescription.labTest = self.labFlag
        }
        
        
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextView = storyboard.instantiateViewController(withIdentifier: "SelectAddressViewController") as! SelectAddressViewController
        self.navigationController?.pushViewController(nextView, animated: true)
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


extension OrderInfoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderInfoCell", for: indexPath) as! OrderInfoCell
        cell.prescriptionImage.image = photoArr[indexPath.row]
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
        
        return CGSize(width: 100 , height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
}
