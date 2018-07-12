//
//  Model.swift
//  FirstAid
//
//  Created by Adroit MAC on 09/05/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import Foundation

class HealthCategory:NSObject {
    var tagName:String!
    var Name:String!
    var image:String!
    
    init(tagName:String, name:String, image:String) {
        self.tagName = tagName
        self.Name = name
        self.image = image
    }
}

class FeaturedPackage: NSObject {
    var offeredPrice:String!
    var discount:String!
    var mrp:String!
    var discountPercentage:String!
    var testName:String!
    var testId:String!
    var testCount:String!
    var labName:String!
    var labId:String!
    var rating:String!
    var accreditationArr:[String] = []
    
    init(offeredPrice:String,discount:String,mrp:String,discountPercentage:String,testName:String,testId:String,testCount:String,labName:String,labId:String,rating:String,accreditationArr:[String]) {
            self.offeredPrice = offeredPrice
            self.discount = discount
            self.mrp = mrp
            self.discountPercentage = discountPercentage
            self.testName = testName
            self.testId = testId
            self.testCount = testCount
            self.labName = labName
            self.labId = labId
            self.rating = rating
            self.accreditationArr = accreditationArr
    }
}


class LabBooking: NSObject {
    var bookingId:String!
    var testId:String!
    var testName:String!
    var status:String!
    
    init(bookingId:String,testId:String,testName:String,status:String) {
        self.bookingId = bookingId
        self.testId = testId
        self.testName = testName
        self.status = status
    }
    
}

