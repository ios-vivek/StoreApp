//
//  Constants.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation

struct Constant {
    // MARK: - Base URLs
    static let GB_URL = "https://www.webapi.grabull.com/"
    static let GD_URL = "https://www.webapi.grabulldirect.com/"
    static let GS_URL = "https://www.webapi.grabull.shop/"
    
    // Current Active Base URL
    static var currentBaseURL: String = GB_URL
    
    // MARK: - WEBSERVICE Credentials
    struct WEBSERVICE {
        static let API_ID = "GB19AP01"
        static let API_KEY = "ba6ee13256e5f0d75eacbf87de167541"
    }
    
    // MARK: - SERVICE_API Endpoints
    struct SERVICE_API {
        static let RESTAURANT_LOGIN = "restaurant-connect/api.php"
        static let GET_ALL_ORDER = "restaurant-connect/api.php"
        static let COMMON_URL = "restaurant-connect/api.php"
        static let ORDER_STATUS = "restaurant-connect/order-status.php"
        static let ADD_ORDER_TIPS = "restaurant-connect/api.php"
        static let ADD_ORDER_ITEMS = "restaurant-connect/api.php"
        static let RESERVATION_STATUS = "restaurant-connect/reservation-status.php"
        static let ENQUIRY_STATUS = "restaurant-connect/enquiry-status.php"
        static let APP_VERSION = "restaurant-connect/api.php"
    }
    
    // MARK: - API_TYPE
    struct API_TYPE {
        static let GB = "GB"
        static let GD = "GD"
        static let GS = "GS"
    }
    
    // MARK: - SERVICE_TYPE
    struct SERVICE_TYPE {
        static let GET_NEW_ORDER = "GetNewOrder"
        static let GET_HOLD_ORDER = "GetHoldOrder"
        static let GET_ACTIVE_ORDER = "GetActiveOrder"
        static let GET_ALL_ORDER = "GetAllOrder"
        static let GET_REOPRT = "GetReport"
        static let GET_CALLBACK = "GetCallback"
        static let GET_STOP_TODAY = "GetStoptoday"
        static let GET_OPEN_TODAY = "GetOpentoday"
        static let GET_UPDATE_SETTING = "UpdateSetting"
        static let GET_ORDER_DETAILS = "GetOrderDetails"
        static let RESETPASSWORD = "ResetPassword"
        static let GET_RESERVATION = "GetReservation"
        static let GET_RESERVATION_STOP = "GetReservationStop"
        static let GET_ENQUIRY = "GetEnquiry"
        static let GET_RESERVATION_STATUS = "GetReservationStatus"
        static let ENQUIRY_STATUS = "EnquiryStatus"
        static let CONFIRM_ORDER = "ConfirmOrder"
        static let ADD_ORDER_ITEMS = "AddOrderItems"
        static let ADD_ORDER_TIPS = "AddOrderTips"
        static let REGISTER = "RegisterRestaurant"
        static let GET_REPORT_WEEK = "GetReportWeeks"
        static let GET_ACTIVE_ORDER_LIST = "GetActiveOrderList"
        static let GET_ORDER_SEARCH = "GetOrderSearch"
        static let GET_DAILY_SUMMERY = "GetDailySummary"
        static let ADD_GB_USER = "AddGBUser"
        static let GET_GB_USER = "GetGBUser"
        static let REMOVE_GB_USER = "removeGBUser"
        static let EDIT_GB_USER = "EditGBUser"
        static let GET_DISCOUNTS = "getDiscounts"
        static let ADD_DISCOUNTS = "addDiscounts"
        static let EDIT_DISCOUNTS = "editDiscounts"
        static let RESET_DISCOUNTS = "resetDiscounts"
        static let LOGOUT = "GetLogout"
        static let FORGOT_PASSWORD = "ForgotPassword"
        static let GET_BANK_DETAIL = "GetBankDetails"
        static let ADD_BANK_DETAIL = "AddBankDetails"
        static let GETSTATUSTODAY = "GetStatustoday"
        static let CheckAppVersion = "CheckAppVersion"
    }
    
    // MARK: - STATUS
    struct STATUS {
        static let FAIL = "fail"
        static let SUCCESS = "success"
    }
    
    // MARK: - ORDER_STATUS
    struct ORDER_STATUS {
        static let CONFIRMED = "Confirmed"
        static let CANCEL = "Cancel"
        static let PICKEDUP = "Picked Up"
        static let DELIVERED = "Delivered"
        static let CLOSED = "Closed"
        static let REFUND = "Refund"
        static let PARTIAL_REFUND = "Partial Refund"
    }
    
    // MARK: - RESERVATION_STOP
    struct RESERVATION_STOP {
        static let TODAY = "Today"
        static let DAY = "Day"
        static let BETWEEN = "Between"
    }
    
    // MARK: - TAB
    struct TAB {
        static let NEW = 0
        static let ACTIVE = 1
        static let COMPLETED = 2
    }
    
    // MARK: - GB_DELIVERY
    struct GB_DELIVERY {
        static let GB = "Yes"
        static let SELF = "No"
    }
    
    // MARK: - DEVICE
    struct DEVICE {
        #if os(iOS)
        static let DEVICE_TYPE: String = "iOS"
        #else
        static let DEVICE_TYPE: String = "Android"
        #endif
    }
    
    // MARK: - BANK
    struct BANK {
        static let ROUTING_LENGTH: Int = 9
        static let ACCOUNT_MIN_LENGTH: Int = 3
        static let ACCOUNT_MAX_LENGTH: Int = 14
    }
    
    // MARK: - Helper Methods
    /// Returns the full endpoint URL for a given relative path using the current base URL.
    static func endpointURL(for path: String, baseURL: String = currentBaseURL) -> URL? {
        let base = baseURL.hasSuffix("/") ? baseURL : "\(baseURL)/"
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        return URL(string: "\(base)\(cleanPath)")
    }
}
