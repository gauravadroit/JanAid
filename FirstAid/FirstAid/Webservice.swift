//
//  Webservice.swift
//  FirstAid
//
//  Created by Adroit MAC on 10/04/18.
//  Copyright © 2018 Adroit MAC. All rights reserved.
//

import Foundation

class Webservice: NSObject {
    
    static let header:[String:String] = [
        "merchant_key":"Android@2018",
        "Content-Type":"application/x-www-form-urlencoded",
        "Platform":"iOS",
        "Version":"2.0"
    ]
    
    static let themeColor = UIColor(red: 0.0/255.0, green: 91.0/255.0, blue: 151.0/255.0, alpha: 1.0)
    static let googleMap = "AIzaSyBFKezYkorOgrOTRrOL-7Y0N4np6BqZvxw"
    static let callCenter = "01206103228" //Test
    //static let callCenter = "18002585677" //Live
    
    static let razorPay = "rzp_live_rbQmcmPedidAsk" //Live Key
    //static let razorPay = "rzp_test_PJ4YxZi3tiXURY" //Test Key
    
    static let baseUrl = "http://janaidapiv3.1.janaid.com/"  //live URL
   // static let baseUrl = "http://staging.janaid.com/" // staging
    static var hospitalImageUrl =  baseUrl + "Images/HospitalLogo/hst_"
    
    static var registerDeviceToken = baseUrl + "api/srv_apiUpdateToken"
    static var registartion = baseUrl + "api/ManagePatient"
    static var getRegisterCity = baseUrl + "Services/srv_AutoComplete/GetCity"
    static var getProfile = baseUrl + "api/srv_patProfile/"
    static var getMember = baseUrl + "api/srv_patMembers/"
    static var getRelation = baseUrl + "api/srv_ddlRelation"
    static var getNotification = baseUrl + "api/srv_conGetNotification"
    static var getHospital = baseUrl + "api/ShowHospitals"
    static var getDoctorForhospital = baseUrl + "api/ShowDoctorWithTiming"
    static var getDoctor = baseUrl + "api/api_DoctorReport"
    static var getAppointment = baseUrl + "api/srv_patCallDetail"
    static var genratePrescription = baseUrl + "api/srv_apiGetEMR/"
    static var getCities = baseUrl + "api/GetCity/0"
    static var getSpecialist = baseUrl + "api/GetSpeciality/0"
    static var bookAppt = baseUrl + "/api/BookAppointment"
    static var showAppt = baseUrl + "/api/ShowAppointment"
    static var getDepartment = baseUrl + "api/GetHospitalSpecialities"
    static var subscriptionPlan = baseUrl +  "api/GetPatientSubscribedPlan/"
    static var getPlan = baseUrl + "api/GetPlan"
    static var save1MGpharmacyToken = baseUrl + "api/Update1mgPharmacyAuthorization"
    static var save1MGLabToken = baseUrl + "api/Update1mgLabAuthorization"
    static var save1MgOrder = baseUrl + "api/Add1mgPharmacyOrder"
    static var save1MGLabOrder = baseUrl + "api/Add1mgLaboratoryOrder"
    static var getAgentCode = baseUrl + "api/GetOTPViaExecutiveCode/"
    static var cancelAppointment = baseUrl + "api/UpdateAppointment"
    static var patientLogout = baseUrl + "api/LogOutPatient"
    static var getCallDetails = baseUrl + "Services/srv_pacGetCallDetail/GetCallDetail"
    static var getOrderIDForPay = baseUrl + "api/GenerateCallOrder"
    static var getDoctorFees = baseUrl + "api/GetDoctorInformation/"
    static var getSpeciality = baseUrl + "api/GetSpecialityForCallOrder/"
    static var getSpeciality2 = baseUrl + "api/GetSpecialityGroupForCallOrder/"
    static var getLocality = baseUrl + "api/LocalityMaster"
    static var getDoctorListForCall = baseUrl + "api/GetDoctorListForCallOrder"
    static var updatePaymentStatus = baseUrl + "api/UpdatePaymentStatus"
    static var getSpecialtyOrderId = baseUrl + "api/GenerateCallOrderWithSpecialityGroup" //"api/GenerateCallOrderWithSpeciality"
    static var getConsultationRecord = baseUrl + "api/GetPatientConsultations/"
    static var getConsultationDetails = baseUrl + "api/GetPatientConsultationDetail/"
    static var getOffer = baseUrl + "api/GetDashboardForPatient/"
    static var uploadDocument = baseUrl + "api/UploadAttachmentWithCallOrder"
    static var deleteAttachment = baseUrl + "api/RemoveUploadedAttachment"
    static var terms = baseUrl + "api/TermsAndConditionsForPatient"
    static var aboutUs = baseUrl + "api/GetAboutUs"
    static var help = baseUrl + "api/GetHelp"
    static var privacyPolicy = baseUrl + "api/GetPrivacyPolicy"
    static var get1MgLabReport = baseUrl + "api/GetLabReportLink/"
    static var getNiramayaLabTest = baseUrl + "api/GetNirAmayaLabTest?MobileNumber="
    static var getOTP = baseUrl + "api/GetOTPForPateintRegistration/"
    static var IPDPackages = baseUrl + "api/GetHospitalPackage/"
    static var IPDpackagesInfo = baseUrl + "api/GetHospitalPackageDetail/"
    static var submitRQA = baseUrl + "api/SubmitQuote"
    static var updateEmail = baseUrl + "api/UpdatePatientEmail"
    static var insertFeedback = baseUrl + "api/AddConsultationFeedback"
    static var getFreeDoctors = baseUrl + "api/GetJanAidDoctorAgainstPromocodes/0"
    static var applyPromocode = baseUrl + "api/ApplyConsultationPromoCodeForConsultation"
    static var applyMemebership  = baseUrl + "api/ApplyMembershipCoupon"
    static var getUnlimitedConsultation = baseUrl + "api/GetNirAmayaUnlimitedConsutationDetails?PromoID="
    static var getHealthCheckUp = baseUrl + "api/GetNirAmayaHealthCheckupDetail?PromoID="
    static var validatePincode = baseUrl + "api/ValidateNirAmayaLabPincode?Pincode="
    static var getTimeSlot = baseUrl + "api/GetNirAmayaLabTimeSlot?Text=0"
    static var validateHealthCoupon = baseUrl + "api/ValidateNiramayaHealthCheckupRequest"
    static var confirmNiramayaBooking = baseUrl + "/api/BookedNiramayaHealthPackage?PatientID="
    
    static var thirdPartyLogin = baseUrl + "api/LoginWithThirdParty"
    static var registerWithSocialMedia = baseUrl + "api/PatientRegistrationWithThirdParty"
    static var loginOTP = baseUrl + "api/PatientLogInWithOTP"
    static var loginWithVerifiedNumber = baseUrl + "api/PatientLoginVerifyMobileNumberAndSendOTP/"
    
    static let registerPatient = baseUrl + "api/PatientSignUp"
    static let couponBenefit = baseUrl + "api/GetMembershipBenefits?PatientID="
    
    
    //Dental
    static let getDentalZone = baseUrl + "api/GetDentalServiceZones/0"
    static let getDentalHospital = baseUrl + "api/GetDentalClinicsInDentalZone?ZoneID="
    static var bookDentalAppointment = baseUrl + "api/BookAppointmentWithDentalClinic"
    static let cancelDentalAppointmet = baseUrl + "api/CancelDentalAppointment"
    
    static var getOrderIdForRazorPay = baseUrl + "/api/GenerateTempOrderForRazorPay"
    static var sendStatus = baseUrl + "api/AddPurchasedPlanOrder"
    static var gpLogin = baseUrl +  "/Services/srv_Login/LoginUser" // "/srv_Login/LoginUser"
    static var GPAll = baseUrl + "/GP/AssignedPatient/GP_GetAssignedPatients"
    static var addSympton = baseUrl + "Services/srv_EMR/ManageSymptom"
    static var getSymptom =  baseUrl + "Services/srv_AutoComplete/GetSymptom/"
    static var getHistory = baseUrl + "Services/srv_AutoComplete/GetHistory"
    static var addHistory = baseUrl + "Services/srv_EMR/ManageHistory"
    static var viewHistory = baseUrl + "AssignHospital/GetVisitHistory"
    static var previousConsultation =  baseUrl + "api/GetPreviousConsultation"
    static var GPProfile = baseUrl + "srv_usrProfile/GetUserProfile"
    static var GPgetHosptial = baseUrl + "Masters/DropDown/GetHospital"
    static var GPHospital = baseUrl + "/api/GetHospitalToTransferCall/"
    static var GPgetSpeciality = baseUrl + "Masters/DropDown/GetHospitalSpeciality?HospitalID="
    static var GPgetDoctor =  baseUrl + "AssignHospital/GetDoctorByHospitalSpeciality"
    static var GPAssignHospital = baseUrl + "GP/AssignHospital/GP_AssignHospital"
    static var GPAddMedicine = baseUrl + "Services/srv_EMR/ManageMedicine"
    static var GPAddLab = baseUrl + "Services/srv_EMR/ManageInvestigation"
    static var GPAddAdvice = baseUrl + "Hospital/EMR/ManageEMR"
    static var logout = baseUrl + "Services/srv_Login/LogOutUser_APK"
    static var activeGP = baseUrl + "api/UpdateUserActiveStatus"
    static var cancelPramacy = baseUrl + "api/Cancel1mgPharmacyOrder"
    static var cancelLab = baseUrl + "api/Cancel1mgLaboratoryOrder"
    static var GPGetOPD = baseUrl + "api/GetNewjobs/"
    static var GPTakeOPD = baseUrl + "api/TakeNewJob"
    static var GPBookedOPD = baseUrl + "api/GetAcceptedJob/"
    static var GPDosage = baseUrl + "api/GetDosage/0"
    static var GPConversation = baseUrl + "Services/srv_Conversation/GPAdviced"
    static var GPTerms = baseUrl + "api/GetTermsAndConditionsForGP"
    static var GPAttachment = baseUrl + "api/GetCallOrderAttachments/"
    static var GPUpdateAboutMe = baseUrl + "api/UpdateDoctorAboutMe"
    static var updateEducation = baseUrl + "api/ManageDoctorEducation"
    static var deleteEducation = baseUrl + "api/RemoveDoctorEducation"
    static var updateProfession = baseUrl + "api/ManageDoctorProfessionalDetail"
    static var deleteProfession = baseUrl + "/api/RemoveDoctorProfessionalDetail"
    static var updateExpertise = baseUrl + "api/ManageDoctorExpertise"
    static var deleteExpertise = baseUrl + "api/RemoveDoctorExpertise"
    static var updateDoctorImage = baseUrl + "api/UpdateDoctorImage"
    static var UploadPrescriptionImage = baseUrl + "api/UploadPrescriptionAgainstCallOrder"
    static var getPrescriptionAttachment = baseUrl + "api/GetCallOrderPrescription/"
    static var deletePrescription = baseUrl + "api/RemoveUploadedPrescription"
    // PI
    
    static var PIAppointment = baseUrl + "api/ShowAppointmentsForPI"
    static var PIpatient = baseUrl + "PacificUser/AssignedPatient/GetAssignedPatients"
    static var PIpatientStatus = baseUrl + "PacificUser/AssignedPatient/pacUpdateCallStatus"
    static var reassignHospital = baseUrl + "PacificUser/AssignedPatient/PAC_ReassignHospital"
    static var PIProfile = baseUrl + "Services/srv_usrProfile/getUserProfile"
    static let PIDentalAppointment = baseUrl + "api/ShowDentalAppointments"
    static let PIConfirmDentalAppt = baseUrl + "api/ConfirmDentalAppointment"
    static let PICompleteDentalAppt = baseUrl + "api/CompleteDentalAppointment"
    static let PIUpdateAppointment = baseUrl + "api/UpdateAppointment"

    
    
    
    //static let OneMGbaseUrl = "https://stagapi.1mg.com/"
    static let OneMGbaseUrl = "https://api.1mg.com/"
    static var getHash = "https://stagapi.1mg.com/webservices/merchants/generate-merchant-hash"
    static let showMedicine = "https://stag.1mg.com?_source=panasonic&merchant_token="
    
    static var signUpWith1MG = OneMGbaseUrl + "webservices/users/signup"
    static var verifyToken = OneMGbaseUrl + "webservices/users/token/verify"
    static var loginWithOTP = OneMGbaseUrl + "webservices/users/otp-login"
    static var renewToken1MG = OneMGbaseUrl + "webservices/public/renew-token"
    static var uploadPrescription = OneMGbaseUrl + "webservices/multi-prescriptions"
    static var getAddressFrom1MG = OneMGbaseUrl + "webservices/addresses?need_availability=true"
    static var addAddress = OneMGbaseUrl + "webservices/addresses"
    static var placeOrderTo1MG = OneMGbaseUrl + "webservices/prescription-order"
    static var getAllOrders = OneMGbaseUrl + "webservices/orders/all-orders?pageSize=20&pageNumber=0"
    static var getCancelReason = OneMGbaseUrl + "webservices/orders/cancelReasons"
    static var cancelOrder = OneMGbaseUrl + "webservices/orders/cancel/"
    static var trackOrder = OneMGbaseUrl + "webservices/order/"
    static var searchProduct = OneMGbaseUrl + "webservices/search-beta?name="
    static var addCart = OneMGbaseUrl + "webservices/cart"
    static var removeItem = OneMGbaseUrl + "webservices/cart/"
    static var getCart = OneMGbaseUrl + "webservices/cart?cart_oos=true&city="
    static var placeOrder = OneMGbaseUrl + "webservices/orders/current/place?device=Android"
    static var getPrescription = OneMGbaseUrl + "webservices/prescriptions?pageNumber=0&pageSize=12"
    static var getPopularCategory = OneMGbaseUrl + "popular-category?city="
    static var oneMGlogin = OneMGbaseUrl + "webservices/authenticate"
    
   // static let OneMGTestbaseUrl = "http://jupiterapi.1mglabs.com/"
    static let OneMGTestbaseUrl = "http://api.1mglabs.com/"
    static var signUpwithLab = OneMGTestbaseUrl + "webservices/public/sign-up"
    static var getPopularTest = OneMGTestbaseUrl + "home?city="
    static var getSearchTest = OneMGTestbaseUrl + "v4/tests?city="
    static var addLabToCart = OneMGTestbaseUrl + "public/cart/item"
    static var selectLab = OneMGTestbaseUrl + "public/v5/inventory?page_size=10&page_number=0&city="
    static var labCart = OneMGTestbaseUrl + "public/cart?city="
    static var getTimeslot = OneMGTestbaseUrl + "public/v6/date_time_slots?city="
    static var bookLab =  OneMGTestbaseUrl + "public/v2/bookings"
    static var labOrder = OneMGTestbaseUrl + "public/v4/bookings?page_number=0&page_size=30"
    static var cancelLaborder = OneMGTestbaseUrl +  "v4/bookings/"
    static var getLabInfo = OneMGTestbaseUrl  + "public/v4/lab/"
                                                    
}


