//
//  PickerTool.swift
//  FFF
//
//  Created by Vinay on 10/11/17.
//  Copyright © 2017 I-WebServices. All rights reserved.
//

import UIKit

class PickerTool: UIView, UIPickerViewDelegate, UIPickerViewDataSource
{
    @IBOutlet weak var _pickerView: UIPickerView!
    var _pickerItems:[Any] = []
    var _outoutTF: UITextField?
    
    var completionHandler: ((_ detail: PickerModel) -> Void)? = nil
    
    
    class func loadClass() -> Any
    {
        let tool = Bundle.main.loadNibNamed("PickerTool", owner: self, options: nil)?.first as? PickerTool
        return tool!
    }
    
    func pickerViewMethod(_ textField: UITextField, arr objArray: [AnyHashable])
    {
        _outoutTF = textField
        _pickerItems = objArray
        _pickerView.reloadAllComponents()
    }
    
    // MARK: pickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return _pickerItems.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return string(forRow: row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let str: String = string(forRow: row)
        _outoutTF?.text = str
        if completionHandler != nil
        {
            completionHandler!(_pickerItems[row] as! PickerModel)
        }

    }
    
    func string(forRow row: Int) -> String
    {
        let object = _pickerItems[row]
        if (object is String)
        {
            return (object as? String) ?? ""
        }
        else if (object is Int)
        {
            return (object as? String) ?? ""
        }
        else if (object is PickerModel)
        {
            let obj = object as? PickerModel
            return (obj?.dataValue.capitalized)!
        }
        
        return ""
    }
}

class PickerModel: NSObject
{
    var dataId: String = ""
    var dataValue: String = ""
    
    class func initWithDictionaryCountry(dictionary:NSDictionary) -> PickerModel
    {
        let result = PickerModel()
        
        result.setDataInDictionaryCountry(dictionary: dictionary)
        return result
    }
    
    func setDataInDictionaryCountry(dictionary:NSDictionary)
    {
        dataId = dictionary["country_code"] as? String ?? ""
        dataValue = dictionary["country_name"] as? String ?? ""
    }
    
    class func initWithDictionarySector(dictionary:NSDictionary) -> PickerModel
    {
        let result = PickerModel()
        
        result.setDataInDictionarySector(dictionary: dictionary)
        return result
    }
    
    func setDataInDictionarySector(dictionary:NSDictionary)
    {
        //dataId = dictionary["country_code"] as? String ?? ""
        dataValue = dictionary["name"] as? String ?? ""
    }
    
    class func initWithDictionaryAge(dictionary:NSDictionary) -> PickerModel
    {
        let result = PickerModel()
        
        result.setDataInDictionaryAge(dictionary: dictionary)
        return result
    }
    
    func setDataInDictionaryAge(dictionary:NSDictionary)
    {
        //dataId = dictionary["country_code"] as? String ?? ""
        dataValue = dictionary["name"] as? String ?? ""
    }
}
