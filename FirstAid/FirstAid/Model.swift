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
    var id:String!
    
    init(tagName:String, name:String, image:String,id:String) {
        self.tagName = tagName
        self.Name = name
        self.image = image
        self.id = id
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

class MediDetail: NSObject {
    var medicine:String!
    var dosage:String!
    var days:String!
    var comments:String!
    
     init(medicine:String,dosage:String,days:String,comments:String) {
        self.medicine = medicine
        self.dosage = dosage
        self.days = days
        self.comments = comments
    }
}

class doctor:NSObject {
    var discountPercentage:String!
    var gender:String!
    var specialityName:String!
    var doctorName:String!
    var rating:String!
    var doctorId:String!
    var fees:String!
    var offerAmount:String!
    var discountAmt:String!
    var qualification:String!
    var imageUrl:String!
    var experience:String!
    var newImageUrl:String!
    var ratingText:String!
    init(discountPercentage:String,gender:String,specialityName:String,doctorName:String,rating:String,doctorId:String,fees:String,offerAmount:String,discountAmt:String,qualification:String,imageUrl:String,experience:String,newImageUrl:String,ratingText:String) {
        
        self.discountPercentage = discountPercentage
        self.gender = gender
        self.specialityName = specialityName
        self.doctorName = doctorName
        self.rating = rating
        self.doctorId = doctorId
        self.fees = fees
        self.offerAmount = offerAmount
        self.discountAmt = discountAmt
        self.qualification = qualification
        self.imageUrl = imageUrl
        self.experience = experience
        self.newImageUrl = newImageUrl
        self.ratingText = ratingText
    }
    
}

