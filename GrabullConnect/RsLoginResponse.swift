//
//  RsLoginResponse.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation

// MARK: - Root Response
struct RsLoginResponse: Codable, Sendable {
    let status: String
    let result: String?
    let apitype: String?
    let data: RestaurantData?
    
    var isSuccess: Bool {
        status.lowercased() == Constant.STATUS.SUCCESS
    }
}

// MARK: - Restaurant Data
struct RestaurantData: Codable, Sendable, Identifiable {
    var id: String { restaurant_id }
    
    let restaurant_id: String
    let gbtype: String?
    let loginId: String?
    let phone: String?
    let name: String?
    let pickup: FlexibleInt?
    let delivery: FlexibleInt?
    let mindelivery: String?
    let miles: String?
    let dcharge: String?
    let dchargetype: String?
    let gbdelivery: String?
    let token: String?
    let dversion: String?
    let type: String?
    let version: String?
    let stoptoday: String?
    let address: String?
    let addressArr: RestaurantAddress?
    let lati: String?
    let longi: String?
    let timezone: String?
    let del_pckg: String?
    let pick_pckg: String?
    let pickuptime: [Int]?
    let deliverytime: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case restaurant_id
        case gbtype
        case loginId
        case phone
        case name
        case pickup
        case delivery
        case mindelivery
        case miles
        case dcharge
        case dchargetype
        case gbdelivery
        case token
        case dversion
        case type
        case version
        case stoptoday
        case address
        case addressArr
        case lati
        case longi
        case timezone
        case del_pckg
        case pick_pckg
        case pickuptime
        case deliverytime
    }
    
    init(
        restaurant_id: String,
        gbtype: String? = nil,
        loginId: String? = nil,
        phone: String? = nil,
        name: String? = nil,
        pickup: FlexibleInt? = nil,
        delivery: FlexibleInt? = nil,
        mindelivery: String? = nil,
        miles: String? = nil,
        dcharge: String? = nil,
        dchargetype: String? = nil,
        gbdelivery: String? = nil,
        token: String? = nil,
        dversion: String? = nil,
        type: String? = nil,
        version: String? = nil,
        stoptoday: String? = nil,
        address: String? = nil,
        addressArr: RestaurantAddress? = nil,
        lati: String? = nil,
        longi: String? = nil,
        timezone: String? = nil,
        del_pckg: String? = nil,
        pick_pckg: String? = nil,
        pickuptime: [Int]? = nil,
        deliverytime: [Int]? = nil
    ) {
        self.restaurant_id = restaurant_id
        self.gbtype = gbtype
        self.loginId = loginId
        self.phone = phone
        self.name = name
        self.pickup = pickup
        self.delivery = delivery
        self.mindelivery = mindelivery
        self.miles = miles
        self.dcharge = dcharge
        self.dchargetype = dchargetype
        self.gbdelivery = gbdelivery
        self.token = token
        self.dversion = dversion
        self.type = type
        self.version = version
        self.stoptoday = stoptoday
        self.address = address
        self.addressArr = addressArr
        self.lati = lati
        self.longi = longi
        self.timezone = timezone
        self.del_pckg = del_pckg
        self.pick_pckg = pick_pckg
        self.pickuptime = pickuptime
        self.deliverytime = deliverytime
    }
    
    func copyWithUpdatedSettings(
        pickup: Int? = nil,
        delivery: Int? = nil,
        miles: String? = nil,
        mindelivery: String? = nil,
        dcharge: String? = nil,
        dchargetype: String? = nil,
        gbdelivery: String? = nil
    ) -> RestaurantData {
        RestaurantData(
            restaurant_id: self.restaurant_id,
            gbtype: self.gbtype,
            loginId: self.loginId,
            phone: self.phone,
            name: self.name,
            pickup: pickup.map { FlexibleInt(value: $0) } ?? self.pickup,
            delivery: delivery.map { FlexibleInt(value: $0) } ?? self.delivery,
            mindelivery: mindelivery ?? self.mindelivery,
            miles: miles ?? self.miles,
            dcharge: dcharge ?? self.dcharge,
            dchargetype: dchargetype ?? self.dchargetype,
            gbdelivery: gbdelivery ?? self.gbdelivery,
            token: self.token,
            dversion: self.dversion,
            type: self.type,
            version: self.version,
            stoptoday: self.stoptoday,
            address: self.address,
            addressArr: self.addressArr,
            lati: self.lati,
            longi: self.longi,
            timezone: self.timezone,
            del_pckg: self.del_pckg,
            pick_pckg: self.pick_pckg,
            pickuptime: self.pickuptime,
            deliverytime: self.deliverytime
        )
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.restaurant_id = Self.decodeFlexibleString(c, .restaurant_id) ?? ""
        self.gbtype = Self.decodeFlexibleString(c, .gbtype)
        self.loginId = Self.decodeFlexibleString(c, .loginId)
        self.phone = Self.decodeFlexibleString(c, .phone)
        self.name = Self.decodeFlexibleString(c, .name)
        self.pickup = Self.decodeFlexibleInt(c, .pickup)
        self.delivery = Self.decodeFlexibleInt(c, .delivery)
        self.mindelivery = Self.decodeFlexibleString(c, .mindelivery)
        self.miles = Self.decodeFlexibleString(c, .miles)
        self.dcharge = Self.decodeFlexibleString(c, .dcharge)
        self.dchargetype = Self.decodeFlexibleString(c, .dchargetype)
        self.gbdelivery = Self.decodeFlexibleString(c, .gbdelivery)
        self.token = Self.decodeFlexibleString(c, .token)
        self.dversion = Self.decodeFlexibleString(c, .dversion)
        self.type = Self.decodeFlexibleString(c, .type)
        self.version = Self.decodeFlexibleString(c, .version)
        self.stoptoday = Self.decodeFlexibleString(c, .stoptoday)
        self.address = Self.decodeFlexibleString(c, .address)
        self.addressArr = try? c.decodeIfPresent(RestaurantAddress.self, forKey: .addressArr)
        self.lati = Self.decodeFlexibleString(c, .lati)
        self.longi = Self.decodeFlexibleString(c, .longi)
        self.timezone = Self.decodeFlexibleString(c, .timezone)
        self.del_pckg = Self.decodeFlexibleString(c, .del_pckg)
        self.pick_pckg = Self.decodeFlexibleString(c, .pick_pckg)
        self.pickuptime = Self.decodeFlexibleIntArray(c, .pickuptime)
        self.deliverytime = Self.decodeFlexibleIntArray(c, .deliverytime)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(restaurant_id, forKey: .restaurant_id)
        try c.encodeIfPresent(gbtype, forKey: .gbtype)
        try c.encodeIfPresent(loginId, forKey: .loginId)
        try c.encodeIfPresent(phone, forKey: .phone)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encodeIfPresent(pickup, forKey: .pickup)
        try c.encodeIfPresent(delivery, forKey: .delivery)
        try c.encodeIfPresent(mindelivery, forKey: .mindelivery)
        try c.encodeIfPresent(miles, forKey: .miles)
        try c.encodeIfPresent(dcharge, forKey: .dcharge)
        try c.encodeIfPresent(dchargetype, forKey: .dchargetype)
        try c.encodeIfPresent(gbdelivery, forKey: .gbdelivery)
        try c.encodeIfPresent(token, forKey: .token)
        try c.encodeIfPresent(dversion, forKey: .dversion)
        try c.encodeIfPresent(type, forKey: .type)
        try c.encodeIfPresent(version, forKey: .version)
        try c.encodeIfPresent(stoptoday, forKey: .stoptoday)
        try c.encodeIfPresent(address, forKey: .address)
        try c.encodeIfPresent(addressArr, forKey: .addressArr)
        try c.encodeIfPresent(lati, forKey: .lati)
        try c.encodeIfPresent(longi, forKey: .longi)
        try c.encodeIfPresent(timezone, forKey: .timezone)
        try c.encodeIfPresent(del_pckg, forKey: .del_pckg)
        try c.encodeIfPresent(pick_pckg, forKey: .pick_pckg)
        try c.encodeIfPresent(pickuptime, forKey: .pickuptime)
        try c.encodeIfPresent(deliverytime, forKey: .deliverytime)
    }
    
    private static func decodeFlexibleString(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> String? {
        if let str = try? c.decodeIfPresent(String.self, forKey: key) {
            return str
        }
        if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) {
            return String(intVal)
        }
        if let dblVal = try? c.decodeIfPresent(Double.self, forKey: key) {
            return String(dblVal)
        }
        return nil
    }
    
    private static func decodeFlexibleInt(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> FlexibleInt? {
        if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) {
            return FlexibleInt(value: intVal)
        }
        if let strVal = try? c.decodeIfPresent(String.self, forKey: key), let intVal = Int(strVal) {
            return FlexibleInt(value: intVal)
        }
        return nil
    }
    
    private static func decodeFlexibleIntArray(_ c: KeyedDecodingContainer<CodingKeys>, _ key: CodingKeys) -> [Int]? {
        if let intArr = try? c.decodeIfPresent([Int].self, forKey: key) {
            return intArr
        }
        if let strArr = try? c.decodeIfPresent([String].self, forKey: key) {
            return strArr.compactMap { Int($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
        }
        return nil
    }
    
    var pickupMinutes: Int {
        pickup?.value ?? 25
    }
    
    var deliveryMinutes: Int {
        delivery?.value ?? 50
    }
    
    var minimumDeliveryValue: Int {
        if let mindelivery, let intVal = Int(mindelivery) {
            return intVal
        }
        return 30
    }
    
    var milesValue: Int {
        if let miles, let intVal = Int(miles) {
            return intVal
        }
        return 0
    }
    
    var deliveryChargeValue: Double {
        if let dcharge, let dblVal = Double(dcharge) {
            return dblVal
        }
        return 0.0
    }
}

// MARK: - Restaurant Address
struct RestaurantAddress: Codable, Sendable {
    let street: String?
    let address: String?
    let city: String?
    let state: String?
    let zip: String?
    
    var formattedFullAddress: String {
        let parts = [street, address, city, state, zip].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Flexible Int Decoder (Handles both integer 25 and string "25")
struct FlexibleInt: Codable, Sendable {
    let value: Int
    
    init(value: Int) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self.value = intVal
        } else if let strVal = try? container.decode(String.self), let intVal = Int(strVal) {
            self.value = intVal
        } else {
            self.value = 0
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
