//
//  RsLoginRq.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Restaurant Login Request Model matching Android's `RsLoginRq` data class
struct RsLoginRq: Codable, Equatable, Sendable {
    var api_id: String
    var api_key: String
    var login_id: String
    var login_pw: String
    var service_type: String
    var DeviceToken: String
    var deviceversion: String
    var devicetype: String
    
    init(
        api_id: String = Constant.WEBSERVICE.API_ID,
        api_key: String = Constant.WEBSERVICE.API_KEY,
        login_id: String = "",
        login_pw: String = "",
        service_type: String = "GetLogin",
        DeviceToken: String = UserDefaults.standard.string(forKey: "deviceToken") ?? "",
        deviceversion: String = {
            #if canImport(UIKit)
            let rawVersion = UIDevice.current.systemVersion
            // Server PHP crashes with HTTP 500 if systemVersion contains multiple dots (e.g. 26.6.2).
            // Sanitize to major.minor (e.g. 26.6 or 18.0)
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
        }(),
        devicetype: String = "iOS"
    ) {
        self.api_id = api_id
        self.api_key = api_key
        self.login_id = login_id
        self.login_pw = login_pw
        self.service_type = service_type
        self.DeviceToken = DeviceToken
        self.deviceversion = deviceversion
        self.devicetype = devicetype
    }
    
    enum CodingKeys: String, CodingKey {
        case api_id
        case api_key
        case login_id
        case login_pw
        case service_type
        case DeviceToken
        case deviceversion
        case devicetype
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "api_id": api_id,
            "api_key": api_key,
            "login_id": login_id,
            "login_pw": login_pw,
            "service_type": service_type,
            "DeviceToken": DeviceToken,
            "deviceversion": deviceversion,
            "devicetype": devicetype
        ]
    }
    
    func toJSONData() -> Data? {
        try? JSONEncoder().encode(self)
    }
}
