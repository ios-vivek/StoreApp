//
//  NetworkManager.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String?)
    case apiError(message: String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "Received an invalid response from the server."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return message ?? "Server returned error code \(code)."
        case .apiError(let message):
            return message
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

actor NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
    }
    
    // MARK: - Login API
    func login(with requestModel: RsLoginRq) async throws -> RsLoginResponse {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(requestModel)
        
        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("🚀 [NetworkManager] POST \(url.absoluteString)")
            print("📦 [Request Body]: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        let responseString = String(data: data, encoding: .utf8) ?? "N/A"
        print("📥 [Status Code]: \(httpResponse.statusCode)")
        print("📄 [Response Body]: \(responseString)")
        #endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Attempt to decode error response if available
            if let errorResponse = try? jsonDecoder.decode(RsLoginResponse.self, from: data) {
                throw NetworkError.apiError(message: errorResponse.result ?? "Server error (\(httpResponse.statusCode))")
            }
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        do {
            let loginResponse = try jsonDecoder.decode(RsLoginResponse.self, from: data)
            
            // Check application-level status
            guard loginResponse.isSuccess else {
                let errorMessage = loginResponse.result ?? "Login failed. Please check your credentials."
                throw NetworkError.apiError(message: errorMessage)
            }
            
            return loginResponse
        } catch let decodingError as DecodingError {
            #if DEBUG
            print("❌ [NetworkManager] Decoding failed: \(decodingError)")
            #endif
            throw NetworkError.decodingError(decodingError)
        } catch {
            throw NetworkError.unknown(error)
        }
    }
    
    // MARK: - New Orders API (GetNewOrder)
    func fetchNewOrders(
        restaurantId: String,
        token: String
    ) async throws -> RsOrdersResponse {
        let requestModel = RsOrdersRq(
            service_type: Constant.SERVICE_TYPE.GET_NEW_ORDER,
            restaurant_id: restaurantId,
            DeviceToken: token
        )
        return try await executeOrdersRequest(requestModel)
    }
    
    // MARK: - In-House Active Orders API (GetActiveOrder)
    func fetchInHouseOrders(
        restaurantId: String,
        token: String
    ) async throws -> RsOrdersResponse {
        let requestModel = RsOrdersRq(
            service_type: Constant.SERVICE_TYPE.GET_ACTIVE_ORDER,
            restaurant_id: restaurantId,
            DeviceToken: token
        )
        return try await executeOrdersRequest(requestModel)
    }
    
    // MARK: - Completed Orders API (GetAllOrder)
    func fetchCompletedOrders(
        restaurantId: String,
        token: String,
        month: String,
        year: String
    ) async throws -> RsOrdersResponse {
        let requestModel = RsOrdersRq(
            service_type: Constant.SERVICE_TYPE.GET_ALL_ORDER,
            restaurant_id: restaurantId,
            DeviceToken: token,
            month: month,
            year: year
        )
        return try await executeOrdersRequest(requestModel)
    }
    
    // MARK: - Common Orders Request Executor
    private func executeOrdersRequest(_ requestModel: RsOrdersRq) async throws -> RsOrdersResponse {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(requestModel)
        
        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("🚀 [NetworkManager] POST \(requestModel.service_type) \(url.absoluteString)")
            print("📦 [Request Body]: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        let responseString = String(data: data, encoding: .utf8) ?? "N/A"
        print("📥 [Status Code]: \(httpResponse.statusCode)")
        print("📄 [\(requestModel.service_type) Response]: \(responseString)")
        #endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        return try jsonDecoder.decode(RsOrdersResponse.self, from: data)
    }
    
    // MARK: - Today Order Status (Open / Stop)
    func fetchTodayOrderStatus(restaurantId: String, token: String) async throws -> (isOpen: Bool, message: String) {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "api_id": Constant.WEBSERVICE.API_ID,
            "api_key": Constant.WEBSERVICE.API_KEY,
            "service_type": Constant.SERVICE_TYPE.GETSTATUSTODAY,
            "restaurant_id": restaurantId,
            "token": token
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: 500, message: "Server error")
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let result = (json["result"] as? String)?.lowercased() ?? "open"
            let msg = (json["data"] as? [String: Any])?["message"] as? String ?? result
            let isOpen = result.contains("open")
            return (isOpen, msg)
        }
        return (true, "Open")
    }
    
    func setTodayOrderStatus(isOpen: Bool, restaurantId: String, token: String) async throws -> String {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let serviceType = isOpen ? Constant.SERVICE_TYPE.GET_OPEN_TODAY : Constant.SERVICE_TYPE.GET_STOP_TODAY
        let body: [String: Any] = [
            "api_id": Constant.WEBSERVICE.API_ID,
            "api_key": Constant.WEBSERVICE.API_KEY,
            "service_type": serviceType,
            "restaurant_id": restaurantId,
            "token": token
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: 500, message: "Server error")
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let resultMsg = json["result"] as? String ?? ((json["data"] as? [String: Any])?["message"] as? String ?? "Updated")
            return resultMsg
        }
        return "Updated"
    }
    
    // MARK: - Confirm / Cancel Order (ConfirmOrder API)
    func confirmOrUpdateOrderStatus(
        restaurantId: String,
        orderId: String,
        status: String = Constant.ORDER_STATUS.CONFIRMED,
        readytime: String = "",
        reason: String = "",
        token: String
    ) async throws -> OrderStatusResponse {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        
        let cleanVersion = SessionManager.sanitizedDeviceVersion
        let req = OrderStatusRequest(
            restaurant_id: restaurantId,
            order_id: orderId,
            service_type: Constant.SERVICE_TYPE.CONFIRM_ORDER,
            status: status,
            readytime: readytime,
            details: "",
            refund: "",
            DeviceToken: token,
            deviceversion: cleanVersion,
            devicetype: Constant.DEVICE.DEVICE_TYPE,
            reason: reason,
            printCopy: 1
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(req)
        
        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("🚀 [NetworkManager] POST ConfirmOrder: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        let responseString = String(data: data, encoding: .utf8) ?? "N/A"
        print("📥 [Status Code]: \(httpResponse.statusCode)")
        print("📄 [ConfirmOrder Response]: \(responseString)")
        #endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        return try jsonDecoder.decode(OrderStatusResponse.self, from: data)
    }
    
    // MARK: - Add Order Items API
    func addOrderItems(
        restaurantId: String,
        orderId: String,
        items: [OrderItemPayload],
        token: String
    ) async throws -> AddOrderItemResponse {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.ADD_ORDER_ITEMS) else {
            throw NetworkError.invalidURL
        }
        
        let cleanVersion = SessionManager.sanitizedDeviceVersion
        let req = AddOrderItemRequest(
            restaurant_id: restaurantId,
            order_id: orderId,
            card: "",
            cvv: "",
            expiry: "",
            billingzip: "",
            cardholder: "",
            service_type: Constant.SERVICE_TYPE.ADD_ORDER_ITEMS,
            itemslist: items,
            newcard: "No",
            DeviceToken: token,
            deviceversion: cleanVersion,
            devicetype: Constant.DEVICE.DEVICE_TYPE
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(req)
        
        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("🚀 [NetworkManager] POST AddOrderItems: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        let responseString = String(data: data, encoding: .utf8) ?? "N/A"
        print("📥 [Status Code]: \(httpResponse.statusCode)")
        print("📄 [AddOrderItems Response]: \(responseString)")
        #endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        return try jsonDecoder.decode(AddOrderItemResponse.self, from: data)
    }
    
    // MARK: - Update Settings API
    func updateSettings(
        restaurantId: String,
        pickup: String,
        delivery: String,
        miles: String,
        mindelivery: String,
        deliverycharge: String,
        deliverychargetype: String,
        gbdelivery: String,
        token: String
    ) async throws -> UpdateSettingResponse {
        guard let url = Constant.endpointURL(for: Constant.SERVICE_API.COMMON_URL) else {
            throw NetworkError.invalidURL
        }
        
        let cleanVersion = SessionManager.sanitizedDeviceVersion
        let req = UpdateSettingRequest(
            DeviceToken: token,
            api_id: Constant.WEBSERVICE.API_ID,
            api_key: Constant.WEBSERVICE.API_KEY,
            delivery: delivery,
            deliverycharge: deliverycharge,
            deliverychargetype: deliverychargetype,
            devicetype: Constant.DEVICE.DEVICE_TYPE,
            deviceversion: cleanVersion,
            gbdelivery: gbdelivery,
            miles: miles,
            mindelivery: mindelivery,
            pickup: pickup,
            restaurant_id: restaurantId,
            service_type: Constant.SERVICE_TYPE.GET_UPDATE_SETTING
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try jsonEncoder.encode(req)
        
        #if DEBUG
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("🚀 [NetworkManager] POST UpdateSetting: \(bodyString)")
        }
        #endif
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        #if DEBUG
        let responseString = String(data: data, encoding: .utf8) ?? "N/A"
        print("📥 [Status Code]: \(httpResponse.statusCode)")
        print("📄 [UpdateSetting Response]: \(responseString)")
        #endif
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: nil)
        }
        
        return try jsonDecoder.decode(UpdateSettingResponse.self, from: data)
    }
}
