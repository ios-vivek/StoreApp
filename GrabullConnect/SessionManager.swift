//
//  SessionManager.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import Foundation
import Combine
#if canImport(UIKit)
import UIKit
#endif

@MainActor
final class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    // Published states
    @Published var isLoggedIn: Bool = false
    @Published var currentRestaurant: RestaurantData? = nil
    @Published var savedUsername: String = ""
    @Published var savedPassword: String = ""
    @Published var rememberMe: Bool = true
    @Published var isAutoLoggingIn: Bool = false
    
    // UserDefaults Keys
    private let keyIsLoggedIn = "gb_is_logged_in"
    private let keyRestaurantData = "gb_restaurant_data"
    private let keyUsername = "gb_saved_username"
    private let keyPassword = "gb_saved_password"
    private let keyRememberMe = "gb_remember_me"
    private let keyDeviceToken = "deviceToken"
    
    // Default fallback DeviceToken
    let defaultDeviceToken = "fTn_0hN5QnWhlIK6d4XlOd:APA91bGevRQrVwNIElZ8GP0YwkkYQl97nCKgWu9gbdURMpStagp441Tr94Hd70TJ9gvuCEWaTBWZD7NClpFGbHEUQbY-mhT_GTY_Fukwpt9wQvPh1qmXIlU"
    
    var deviceToken: String {
        UserDefaults.standard.string(forKey: keyDeviceToken) ?? defaultDeviceToken
    }
    
    // MARK: - Sanitized Device Version
    nonisolated static var sanitizedDeviceVersion: String {
        #if canImport(UIKit)
        let raw = UIDevice.current.systemVersion
        let parts = raw.split(separator: ".")
        if parts.count >= 2 {
            return "\(parts[0]).\(parts[1])"
        } else if let first = parts.first {
            return "\(first).0"
        }
        return raw
        #else
        return "18.0"
        #endif
    }
    
    var sanitizedDeviceVersion: String {
        Self.sanitizedDeviceVersion
    }
    
    private init() {
        let defaults = UserDefaults.standard
        self.rememberMe = defaults.object(forKey: keyRememberMe) as? Bool ?? true
        self.savedUsername = defaults.string(forKey: keyUsername) ?? ""
        self.savedPassword = defaults.string(forKey: keyPassword) ?? ""
        
        // Ensure device token exists
        if defaults.string(forKey: keyDeviceToken) == nil {
            defaults.set(defaultDeviceToken, forKey: keyDeviceToken)
        }
        
        // Restore active user data if saved
        if let data = defaults.data(forKey: keyRestaurantData),
           let restaurant = try? JSONDecoder().decode(RestaurantData.self, from: data) {
            self.currentRestaurant = restaurant
        }
        
        let previouslyLoggedIn = defaults.bool(forKey: keyIsLoggedIn)
        if previouslyLoggedIn && rememberMe && !savedUsername.isEmpty && !savedPassword.isEmpty {
            self.isLoggedIn = true
            // Run background sync
            Task {
                await self.performBackgroundSync()
            }
        }
    }
    
    // MARK: - Auto Login Background Sync
    func performBackgroundSync() async {
        guard rememberMe, !savedUsername.isEmpty, !savedPassword.isEmpty else { return }
        
        isAutoLoggingIn = true
        defer { isAutoLoggingIn = false }
        
        let token = UserDefaults.standard.string(forKey: keyDeviceToken) ?? defaultDeviceToken
        let request = RsLoginRq(
            login_id: savedUsername,
            login_pw: savedPassword,
            DeviceToken: token,
            devicetype: "iOS"
        )
        
        do {
            let response = try await NetworkManager.shared.login(with: request)
            if let data = response.data {
                self.currentRestaurant = data
                saveRestaurantData(data)
                self.isLoggedIn = true
            }
        } catch {
            print("⚠️ [SessionManager] Background auto-login sync failed: \(error.localizedDescription)")
            // Keep local cached session active so offline/quick launch continues to work
        }
    }
    
    // MARK: - Explicit User Login
    func login(username: String, password: String, remember: Bool) async throws {
        let token = UserDefaults.standard.string(forKey: keyDeviceToken) ?? defaultDeviceToken
        let request = RsLoginRq(
            login_id: username.trimmingCharacters(in: .whitespacesAndNewlines),
            login_pw: password.trimmingCharacters(in: .whitespacesAndNewlines),
            DeviceToken: token,
            devicetype: "iOS"
        )
        
        let response = try await NetworkManager.shared.login(with: request)
        
        guard let restaurant = response.data else {
            throw NetworkError.apiError(message: response.result ?? "No restaurant data received.")
        }
        
        // Save Session
        self.currentRestaurant = restaurant
        self.isLoggedIn = true
        self.rememberMe = remember
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: keyIsLoggedIn)
        defaults.set(remember, forKey: keyRememberMe)
        
        if remember {
            defaults.set(username, forKey: keyUsername)
            defaults.set(password, forKey: keyPassword)
            self.savedUsername = username
            self.savedPassword = password
        } else {
            defaults.removeObject(forKey: keyUsername)
            defaults.removeObject(forKey: keyPassword)
            self.savedUsername = ""
            self.savedPassword = ""
        }
        
        saveRestaurantData(restaurant)
    }
    
    // MARK: - Logout
    func logout() {
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: keyIsLoggedIn)
        defaults.removeObject(forKey: keyRestaurantData)
        
        if !rememberMe {
            defaults.removeObject(forKey: keyUsername)
            defaults.removeObject(forKey: keyPassword)
            self.savedUsername = ""
            self.savedPassword = ""
        }
        
        self.currentRestaurant = nil
        self.isLoggedIn = false
    }
    
    // MARK: - Update Settings Cache
    func updateRestaurantSettings(
        pickup: Int? = nil,
        delivery: Int? = nil,
        miles: String? = nil,
        mindelivery: String? = nil,
        dcharge: String? = nil,
        dchargetype: String? = nil,
        gbdelivery: String? = nil
    ) {
        guard let current = currentRestaurant else { return }
        let updated = current.copyWithUpdatedSettings(
            pickup: pickup,
            delivery: delivery,
            miles: miles,
            mindelivery: mindelivery,
            dcharge: dcharge,
            dchargetype: dchargetype,
            gbdelivery: gbdelivery
        )
        self.currentRestaurant = updated
        saveRestaurantData(updated)
    }
    
    // MARK: - Persistence Helper
    private func saveRestaurantData(_ restaurant: RestaurantData) {
        if let encoded = try? JSONEncoder().encode(restaurant) {
            UserDefaults.standard.set(encoded, forKey: keyRestaurantData)
        }
    }
}
