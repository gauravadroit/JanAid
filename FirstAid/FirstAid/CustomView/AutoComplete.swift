//
//  AutoComplete.swift
//  FirstAid
//
//  Created by Adroit MAC on 01/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import UIKit

class AutoComplete: UIView {
    @IBOutlet weak var tableView: UITableView!
    var medicineArr:[medicineSearch] = []
    var delegate:SelectAddressDelegate?
    
    var view:UIView!
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "AutoComplete", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        //view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        //backView.layer.cornerRadius = 5
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "AutoCompleteCell", bundle: nil), forCellReuseIdentifier: "AutoCompleteCell")
        
        return view
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

extension AutoComplete: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicineArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteCell", for: indexPath) as! AutoCompleteCell
        cell.titleLabel.text = medicineArr[indexPath.row].pname
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.selectedIndex(index: indexPath.row)
    }
    
}
