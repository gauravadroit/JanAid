//
//  PrescriptionViewController.swift
//  FirstAid
//
//  Created by Adroit MAC on 23/07/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PrescriptionViewController: UIViewController {

    var doctorData:[String:String]!
    var history:[String] = []
    var investigation:[String] = []
    var symptom:[String] = []
    var medicineList:[MediDetail] = []
    
    var dataArr:[Int] = []
    var menuArr:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = doctorData["title"]
        
        
        let backButton = UIBarButtonItem()
        backButton.title = " "
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        self.tableView.separatorStyle = .none
        
        dataArr.append(1)
        menuArr.append("Doctor")
        
        if symptom.count != 0 {
            dataArr.append(symptom.count)
            menuArr.append("Symptom")
        }
        
        if history.count != 0 {
            dataArr.append(history.count)
            menuArr.append("History")
        }
        
         if medicineList.count != 0 {
            dataArr.append(medicineList.count)
            menuArr.append("Medicine")
        }
        
        if investigation.count != 0 {
            dataArr.append(investigation.count)
            menuArr.append("Investigation")
        }
        
        dataArr.append(1)
        menuArr.append("Signature")
        
        let rightBtn = UIBarButtonItem(image: UIImage(named: "download"), style: .plain, target: self, action: #selector(self.downloadPdf))
        self.navigationItem.rightBarButtonItem = rightBtn
    }
    
    @objc func downloadPdf() {
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        let pdfPageBounds = CGRect(x:0, y:0, width:tableView.frame.width, height:self.tableView.frame.height + 20)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
        }
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
        let path = dir?.appendingPathComponent("JanAid_Precription_\(self.getDate()).pdf")
        print(path)
        do {
            try pdfData.write(to: path!, options: NSData.WritingOptions.atomic)
        } catch {
            print("error catched")
        }
        
        let activityViewController = UIActivityViewController(activityItems: [path], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
        // return pdfData
    }
    
    func getDate() -> String{
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd_MM_yyyy_hh_mm_ss"
        return formatter.string(from: date)
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

extension PrescriptionViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return menuArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionDoctorInfoCell", for: indexPath) as! PrescriptionDoctorInfoCell
            cell.degreeLabel.text = doctorData["qualification"]
            cell.dateLabel.text = doctorData["date"]
            cell.doctorNameLabel.text = doctorData["doctorName"]
            cell.patientInfoLabel.text = doctorData["patientName"]! + "," + doctorData["PatientAge"]! + " " + doctorData["gender"]!
            cell.registerationLabel.text = doctorData["registration"]
            cell.selectionStyle = .none
            return cell
        } else if  menuArr[indexPath.section] == "Symptom" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrecriptionDataCell", for: indexPath) as! PrecriptionDataCell
            cell.serialNumLabel.text =  String(indexPath.row + 1) + "."
            cell.dataLabel.text = symptom[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }else if  menuArr[indexPath.section] == "History" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrecriptionDataCell", for: indexPath) as! PrecriptionDataCell
             cell.serialNumLabel.text =  String(indexPath.row + 1) + "."
            cell.dataLabel.text = history[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }else if  menuArr[indexPath.section] == "Medicine" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionMedicineCell", for: indexPath) as! PrescriptionMedicineCell
            cell.serialNumberLabel.text = String(indexPath.row + 1) + "."
            cell.nameLabel.text = medicineList[indexPath.row].medicine
            cell.timeLabel.text = medicineList[indexPath.row].dosage
            cell.durationLabel.text = medicineList[indexPath.row].days + " days"
            cell.commentLabel.text = medicineList[indexPath.row].comments
            cell.selectionStyle = .none
            return cell
        }else if  menuArr[indexPath.section] == "Investigation" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrecriptionDataCell", for: indexPath) as! PrecriptionDataCell
            cell.serialNumLabel.text =  String(indexPath.row + 1) + "."
            cell.dataLabel.text = investigation[indexPath.row]
            cell.selectionStyle = .none
            return cell
        }else if  menuArr[indexPath.section] == "Signature" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionSignatureCell", for: indexPath) as! PrescriptionSignatureCell
            cell.degreeLabel.text = doctorData["qualification"]
            cell.nameLabel.text = doctorData["doctorName"]
            cell.specialityLabel.text = doctorData["speciality"]
            cell.adviceLabel.text = doctorData["advice"]
            cell.disclaimerLabel.text = doctorData["Disclaimer"]! + "                                                                                   .                                                                                                             .                                                                    "
          
            cell.selectionStyle = .none
            return cell
        }else{
            let cell = UITableViewCell()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionHeaderCell") as! PrescriptionHeaderCell
        /*cell.dataLabel.textAlignment = .center
        cell.dataLabel.textColor = .white
        cell.dataLabel.text = " " + menuArr[section] + " "
        cell.dataLabel.backgroundColor = .yellow
        cell.dataLabel.layer.cornerRadius =  cell.dataLabel.frame.size.height/2
        cell.backgroundColor = UIColor.white*/
        
        cell.headerLabel.text = " " + menuArr[section] + " "
        cell.headerLabel.layer.cornerRadius =  cell.headerLabel.frame.size.height/2
        cell.headerLabel.layer.masksToBounds = true
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  menuArr[section] == "Signature" || menuArr[section] == "Doctor" {
            return 0
        }
        return 40
    }
    
}



