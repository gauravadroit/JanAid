//
//  PDFView.swift
//  FirstAid
//
//  Created by Adroit MAC on 19/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class PDFView: UIView {
    
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var hospitalNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
    @IBOutlet weak var patientLabelName: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var doctorNameLabel: UILabel!
    @IBOutlet weak var patientCodeLabel: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    var view:UIView!
    var header = ["Investigation","Medication","Advice"]
    @IBOutlet weak var tableView: UITableView!
    var data:[[String]] = []
    
    func loadViewFromNib() -> UIView {
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "PDFView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        tableView.backgroundColor = UIColor.clear
        
        return view
    }
    
   
    
    func renderData(data:[[String]]) {
        self.data = data
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.separatorStyle = .none
        self.tableView.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width - 60, height: UIScreen.main.bounds.size.height - 80)
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

extension PDFView:UITableViewDelegate,UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = data[indexPath.section][indexPath.row]
        cell.textLabel?.textColor = UIColor.lightGray
        cell.backgroundColor = UIColor.clear
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = UITableViewCell()
        cell.textLabel?.text = header[section]
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
}
