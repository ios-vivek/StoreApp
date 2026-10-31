//
//  RsOrdersModels.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Orders Request Model
struct RsOrdersRq: Codable, Sendable {
    var api_id: String = Constant.WEBSERVICE.API_ID
    var api_key: String = Constant.WEBSERVICE.API_KEY
    var service_type: String
    var restaurant_id: String
    var DeviceToken: String
    var devicetype: String = "iOS"
    var deviceversion: String = {
        #if canImport(UIKit)
        let rawVersion = UIDevice.current.systemVersion
        let parts = rawVersion.split(separator: ".")
        if parts.count >= 2 {
            return "\(parts[0]).\(parts[1])"
        } else if let first = parts.first {
            return "\(first).0"
        }
        return rawVersion
        #else
        return "18.0"
        #endif
    }()
    var month: String?
    var year: String?
    
    enum CodingKeys: String, CodingKey {
        case api_id
        case api_key
        case service_type
        case restaurant_id
        case DeviceToken
        case devicetype
        case deviceversion
        case month
        case year
    }
}

// MARK: - Orders Notification Data
struct NotiData: Codable, Sendable {
    var rid: String?
    var alarm: String?
    var neword: String?
    var holdord: String?
    var inhouse: String?
    var livedel: String?
    var today: String?
    var dinein: String?
    var media: String?
    var dinealram: String?
    var gbdelivery: String?
    var gbadelivery: String?
    var infoupdate: String?
}

// MARK: - Orders Response Model
struct RsOrdersResponse: Codable, Sendable {
    var status: String?
    var result: String?
    var data: [ApiOrderItem]?
    var notiData: NotiData?
    
    var isSuccess: Bool {
        status?.lowercased() == "success"
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case result
        case data
        case notiData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.status = try container.decodeIfPresent(String.self, forKey: .status)
        self.result = try container.decodeIfPresent(String.self, forKey: .result)
        self.data = try container.decodeIfPresent([ApiOrderItem].self, forKey: .data)
        
        // notiData can be null, dict, or empty list
        if let noti = try? container.decodeIfPresent(NotiData.self, forKey: .notiData) {
            self.notiData = noti
        } else {
            self.notiData = nil
        }
    }
    
    init(status: String?, result: String?, data: [ApiOrderItem]?, notiData: NotiData? = nil) {
        self.status = status
        self.result = result
        self.data = data
        self.notiData = notiData
    }
}

// MARK: - API Order Item
struct ApiOrderItem: Codable, Identifiable, Sendable {
    var tabletype: String?
    var id: String?
    var orderid: String?
    var date: String?
    var date2: String?
    var holddate: String?
    var holddate2: String?
    var hold: String?
    var type: String?
    var payment: FlexibleAmount?
    var paybycard: String?
    var payby: FlexibleAmount?
    var tips: FlexibleAmount?
    var tips2: FlexibleAmount?
    var status: String?
    var name: String?
    var mobile: String?
    var pickup_address: String?
    var delivery: String?
    var landmark: String?
    var orderat: String?
}

// MARK: - Flexible Amount Decoder (Handles String, Double, Int, null)
enum FlexibleAmount: Codable, Sendable {
    case string(String)
    case double(Double)
    case int(Int)
    case null
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let doubleVal = try? container.decode(Double.self) {
            self = .double(doubleVal)
        } else if let intVal = try? container.decode(Int.self) {
            self = .int(intVal)
        } else if let stringVal = try? container.decode(String.self) {
            self = .string(stringVal)
        } else {
            self = .null
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let str):
            try container.encode(str)
        case .double(let dbl):
            try container.encode(dbl)
        case .int(let num):
            try container.encode(num)
        case .null:
            try container.encodeNil()
        }
    }
    
    var formattedString: String {
        switch self {
        case .string(let val):
            if val.hasPrefix("$") { return val }
            if let num = Double(val) { return String(format: "$%.2f", num) }
            return "$\(val)"
        case .double(let val):
            return String(format: "$%.2f", val)
        case .int(let val):
            return String(format: "$%d.00", val)
        case .null:
            return "$0.00"
        }
    }
}

// MARK: - Order Status Request (Confirm / Cancel Order)
struct OrderStatusRequest: Codable, Sendable {
    var api_id: String = Constant.WEBSERVICE.API_ID
    var api_key: String = Constant.WEBSERVICE.API_KEY
    var restaurant_id: String
    var order_id: String
    var service_type: String = Constant.SERVICE_TYPE.CONFIRM_ORDER
    var status: String = Constant.ORDER_STATUS.CONFIRMED
    var readytime: String = ""
    var details: String = ""
    var refund: String = ""
    var DeviceToken: String
    var deviceversion: String
    var devicetype: String = "iOS"
    var reason: String = ""
    var printCopy: Int = 1
}

// MARK: - Order Status Response
struct OrderStatusResponse: Codable, Sendable {
    let status: String?
    let result: String?
    let data: OrderStatusResponseData?
    
    var isSuccess: Bool {
        status?.lowercased() == Constant.STATUS.SUCCESS
    }
}

struct OrderStatusResponseData: Codable, Sendable {
    let id: String?
    let status: String?
    let readytime: String?
    let ordertype: String?
}

// MARK: - Add Order Item Models
struct OrderItemPayload: Codable, Sendable {
    var items: String
    var price: String
}

struct AddOrderItemRequest: Codable, Sendable {
    var api_id: String = Constant.WEBSERVICE.API_ID
    var api_key: String = Constant.WEBSERVICE.API_KEY
    var restaurant_id: String = ""
    var order_id: String = ""
    var card: String = ""
    var cvv: String = ""
    var expiry: String = ""
    var billingzip: String = ""
    var cardholder: String = ""
    var service_type: String = Constant.SERVICE_TYPE.ADD_ORDER_ITEMS
    var itemslist: [OrderItemPayload] = []
    var newcard: String = "No"
    var DeviceToken: String
    var deviceversion: String
    var devicetype: String = Constant.DEVICE.DEVICE_TYPE
}

struct AddOrderItemData: Codable, Sendable {
    let subtotal: Double?
    let tax: Double?
    let total: Double?
    
    enum CodingKeys: String, CodingKey {
        case subtotal, tax, total
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.subtotal = Self.decodeFlexibleDouble(container, key: .subtotal)
        self.tax = Self.decodeFlexibleDouble(container, key: .tax)
        self.total = Self.decodeFlexibleDouble(container, key: .total)
    }
    
    private static func decodeFlexibleDouble(_ container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> Double? {
        if let val = try? container.decode(Double.self, forKey: key) {
            return val
        }
        if let intVal = try? container.decode(Int.self, forKey: key) {
            return Double(intVal)
        }
        if let strVal = try? container.decode(String.self, forKey: key) {
            let clean = strVal.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            return Double(clean)
        }
        return nil
    }
}

struct AddOrderItemResponse: Codable, Sendable {
    let status: String?
    let result: String?
    let message: String?
    let data: AddOrderItemData?
    
    var isSuccess: Bool {
        status?.lowercased() == Constant.STATUS.SUCCESS
    }
    
    var displayMessage: String {
        result ?? message ?? "Items added successfully"
    }
}

// MARK: - Update Setting Models
struct UpdateSettingRequest: Codable, Sendable {
    let DeviceToken: String
    let api_id: String
    let api_key: String
    let delivery: String
    let deliverycharge: String
    let deliverychargetype: String
    let devicetype: String
    let deviceversion: String
    let gbdelivery: String
    let miles: String
    let mindelivery: String
    let pickup: String
    let restaurant_id: String
    let service_type: String
}

struct UpdateSettingData: Codable, Sendable {
    let pickup: String?
    let delvry: String?
    let mind: String?
    let miles: String?
    let deliverycharge: String?
    let deliverychargetype: String?
    let gbdelivery: String?
    
    enum CodingKeys: String, CodingKey {
        case pickup
        case delvry
        case delivery
        case mind
        case mindelivery
        case miles
        case deliverycharge
        case deliverychargetype
        case gbdelivery
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.pickup = Self.decodeFlexibleString(container, keys: [.pickup])
        self.delvry = Self.decodeFlexibleString(container, keys: [.delvry, .delivery])
        self.mind = Self.decodeFlexibleString(container, keys: [.mind, .mindelivery])
        self.miles = Self.decodeFlexibleString(container, keys: [.miles])
        self.deliverycharge = Self.decodeFlexibleString(container, keys: [.deliverycharge])
        self.deliverychargetype = Self.decodeFlexibleString(container, keys: [.deliverychargetype])
        self.gbdelivery = Self.decodeFlexibleString(container, keys: [.gbdelivery])
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(pickup, forKey: .pickup)
        try container.encodeIfPresent(delvry, forKey: .delvry)
        try container.encodeIfPresent(mind, forKey: .mind)
        try container.encodeIfPresent(miles, forKey: .miles)
        try container.encodeIfPresent(deliverycharge, forKey: .deliverycharge)
        try container.encodeIfPresent(deliverychargetype, forKey: .deliverychargetype)
        try container.encodeIfPresent(gbdelivery, forKey: .gbdelivery)
    }
    
    private static func decodeFlexibleString(_ container: KeyedDecodingContainer<CodingKeys>, keys: [CodingKeys]) -> String? {
        for key in keys {
            if let str = try? container.decodeIfPresent(String.self, forKey: key) {
                return str
            }
            if let intVal = try? container.decodeIfPresent(Int.self, forKey: key) {
                return String(intVal)
            }
            if let dblVal = try? container.decodeIfPresent(Double.self, forKey: key) {
                return String(dblVal)
            }
        }
        return nil
    }
}

struct UpdateSettingResponse: Codable, Sendable {
    let status: String?
    let result: String?
    let data: UpdateSettingData?
    
    var isSuccess: Bool {
        status?.lowercased() == Constant.STATUS.SUCCESS
    }
}


