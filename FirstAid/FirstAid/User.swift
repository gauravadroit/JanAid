//
//  User.swift
//  FirstAid
//
//  Created by Adroit MAC on 12/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import Foundation


class User: NSObject {
    
    static var firstName:String!
    static var lastName:String!
    static var motherName:String!
    static var mobileNumber:String!
    static var patientId:String!
    static var emailId:String!
    static var genderId:String!
    static var statusId:String!
    static var flagNumber:String!
    static var location:String!
    static var speciality:String!
    static var specialityId:String!
    static var oneMgPharmacy:String!
    static var oneMGLab:String!
    static var isMFI:String!
    static var valiedEmail:String!

    static var oneMGAuthenticationToken:String!
    static var oneMGLabToken:String!
    
    static var isFreeConsultationApplicable:String = "False"
    static var UsedPromoID:String!
    
}

class Prescription: NSObject {
    static var addressId:String!
    static var prescriptionId:String!
    static var prescriptionUrl:String!
    static var durationInDays:String!
    static var comment:String!
    static var orderChoice:String!
    static var labTest:Int!
}

class Lab: NSObject {
    static var labId:String!
    static var skusArr:[[String:String]] = []
    static var precautions:String!
    static var labType:String!
}

class GPUser: NSObject {
    static var name:String!
    static var descr:String!
    static var UserId:String!
    static var merchantKey:String!
    static var active:String!
    static var memberId:String!
}

class PIUser: NSObject {
    static var name:String!
    static var descr:String!
    static var UserId:String!
    static var merchantKey:String!
    static var appointmentDate:String!
    static var dentalDate:String!
}

class GPAdvice: NSObject {
    static var callId:String!
    static var patientName:String!
    static var patientAge:String!
    static var patientGender:String!
    static var patientAddress:String!
    static var date:String!
}

class LabAddress: NSObject {
    static var pincodeText: String!
    static var localityText: String!
    static var cityText: String!
    static var stateText: String!
    static var genderText: String!
    static var contactText: String!
    static var ageText: String!
    static var nameText: String!
    static var flatText: String!
    static var price:String!
}

class MedicineData:NSObject {
     static var OrderID:String!
     static var OrderDate:String!
     static var OrderStatus_1mg:String!
     static var TotalAmount:String!
     static var DiscountAmount:String!
     static var ActualAmount:String!
    static var ShippingAmount:String!
}

