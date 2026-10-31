//
//  SettingsView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct SettingsView: View {
    var onBack: () -> Void
    
    // MARK: - State Variables
    // Today Order Status (from API GetStatustoday / GetStoptoday / GetOpentoday)
    @State private var isOrderOpenToday: Bool = true
    @State private var isUpdatingTodayStatus: Bool = false
    @State private var showConfirmStopToday: Bool = false
    
    // Grabull on Demand Delivery Switch
    @State private var isGBDelivery: Bool = true
    
    // Estimates
    @State private var pickupMinutes: Int
    @State private var deliveryMinutes: Int
    @State private var defaultMiles: Int
    @State private var minDeliveryAmount: Int
    
    // Baseline saved values to track individual changes
    @State private var savedPickupMinutes: Int
    @State private var savedDeliveryMinutes: Int
    @State private var savedDefaultMiles: Int
    @State private var savedMinDeliveryAmount: Int
    @State private var savedChargeTypeIsDollar: Bool
    @State private var savedDeliveryCharge: Double
    @State private var savedIsGBDelivery: Bool
    
    enum SettingTarget: String {
        case pickup
        case delivery
        case miles
        case minDelivery
        case deliveryCharge
    }
    @State private var activeSavingTarget: SettingTarget? = nil
    
    private var isPickupModified: Bool { pickupMinutes != savedPickupMinutes }
    private var isDeliveryModified: Bool { deliveryMinutes != savedDeliveryMinutes }
    private var isMilesModified: Bool { defaultMiles != savedDefaultMiles }
    private var isMinDeliveryModified: Bool { minDeliveryAmount != savedMinDeliveryAmount }
    private var isDeliveryChargeModified: Bool {
        deliveryCharge != savedDeliveryCharge || chargeTypeIsDollar != savedChargeTypeIsDollar
    }
    
    // Delivery Charge
    @State private var chargeTypeIsDollar: Bool
    @State private var deliveryCharge: Double
    
    // Print Copies
    @State private var printCopies: Int = 2
    @State private var showCopiesPicker: Bool = false
    
    // Printer
    @State private var currentPrinter: String = "Bluetooth\n04:7F:0E:4A:90:21"
    @State private var showPrinterSheet: Bool = false
    
    // Alerts
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // Colors matching exact Grabull Connect theme from screenshot
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let titleBlue = Color(red: 0/255, green: 130/255, blue: 225/255)
    private let navyStepper = Color(red: 20/255, green: 56/255, blue: 91/255)
    private let dividerGray = Color(red: 238/255, green: 240/255, blue: 242/255)
    private let borderGray = Color(red: 200/255, green: 205/255, blue: 210/255)
    private let orangeBorder = Color(red: 245/255, green: 145/255, blue: 35/255)
    private let infoBlue = Color(red: 59/255, green: 153/255, blue: 252/255)
    private let trackPink = Color(red: 248/255, green: 187/255, blue: 195/255)
    
    init(onBack: @escaping () -> Void) {
        self.onBack = onBack
        let r = SessionManager.shared.currentRestaurant
        let p = r?.pickupMinutes ?? 0
        let d = r?.deliveryMinutes ?? 0
        let m = r?.milesValue ?? 0
        let minD = r?.minimumDeliveryValue ?? 30
        let isDollar = (r?.dchargetype ?? "$") == "$"
        let dCharge = r?.deliveryChargeValue ?? 0
        let gbDel = (r?.gbdelivery?.lowercased() ?? "yes") == "yes"
        let openToday = (r?.stoptoday?.lowercased() ?? "") != "stop"
        
        _pickupMinutes = State(initialValue: p)
        _savedPickupMinutes = State(initialValue: p)
        
        _deliveryMinutes = State(initialValue: d)
        _savedDeliveryMinutes = State(initialValue: d)
        
        _defaultMiles = State(initialValue: m)
        _savedDefaultMiles = State(initialValue: m)
        
        _minDeliveryAmount = State(initialValue: minD)
        _savedMinDeliveryAmount = State(initialValue: minD)
        
        _chargeTypeIsDollar = State(initialValue: isDollar)
        _savedChargeTypeIsDollar = State(initialValue: isDollar)
        
        _deliveryCharge = State(initialValue: dCharge)
        _savedDeliveryCharge = State(initialValue: dCharge)
        
        _isGBDelivery = State(initialValue: gbDel)
        _savedIsGBDelivery = State(initialValue: gbDel)
        
        _isOrderOpenToday = State(initialValue: openToday)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            ZStack {
                // Centered Title
                Text("Settings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                // Back Button on Leading edge
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                            
                            Text("BACK")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .foregroundStyle(brandRed)
                        .padding(.vertical, 8)
                        .padding(.trailing, 12)
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            // Header divider line
            Rectangle()
                .fill(Color(white: 0.88))
                .frame(height: 1)
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: - Top Section (STOP ORDER FOR TODAY & Grabull Delivery Switch)
                    topOrderControlsSection
                    
                    // Divider Band
                    Rectangle()
                        .fill(dividerGray)
                        .frame(height: 14)
                    
                    // MARK: - Estimates Section (Pickup, Delivery, Miles, Min Delivery)
                    estimatesSection
                    
                    // Divider Band
                    Rectangle()
                        .fill(dividerGray)
                        .frame(height: 14)
                    
                    // MARK: - Delivery Charge Section
                    deliveryChargeSection
                    
                    // Divider Band
                    Rectangle()
                        .fill(dividerGray)
                        .frame(height: 14)
                    
                    // MARK: - Select Print Copies
                    printCopiesSection
                    
                    // Divider Band
                    Rectangle()
                        .fill(dividerGray)
                        .frame(height: 14)
                    
                    // MARK: - Printer Section
                    printerSection
                    
                    Spacer()
                        .frame(height: 36)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            fetchTodayOrderStatus()
        }
        .confirmationDialog(
            "Change Order Status for Today?",
            isPresented: $showConfirmStopToday,
            titleVisibility: .visible
        ) {
            Button(isOrderOpenToday ? "Stop Orders for Today" : "Open Orders for Today", role: isOrderOpenToday ? .destructive : .none) {
                toggleTodayOrderStatus()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(isOrderOpenToday
                 ? "Are you sure you want to stop receiving new orders for the rest of today?"
                 : "Are you sure you want to resume receiving orders for today?")
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(isPresented: $showCopiesPicker) {
            copiesPickerSheet
        }
        .sheet(isPresented: $showPrinterSheet) {
            printerSelectionSheet
        }
    }
    
    // MARK: - Top Section (STOP ORDER FOR TODAY + Delivery Switch + View Terms)
    private var topOrderControlsSection: some View {
        VStack(spacing: 14) {
            // "STOP ORDER FOR TODAY" / "OPEN ORDER FOR TODAY" Red Button
            Button {
                showConfirmStopToday = true
            } label: {
                HStack(spacing: 8) {
                    if isUpdatingTodayStatus {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    Text(isOrderOpenToday ? "STOP ORDER FOR TODAY" : "OPEN ORDER FOR TODAY")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(isOrderOpenToday ? brandRed : Color(red: 40/255, green: 160/255, blue: 60/255))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .disabled(isUpdatingTodayStatus)
            .padding(.horizontal, 32)
            .padding(.top, 16)
            
            // "Grabull on Demand Delivery" Label
            Text("Grabull on Demand Delivery")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color(red: 120/255, green: 120/255, blue: 120/255))
            
            // Custom Switch: Self Delivery <---> GB Delivery
            HStack(spacing: 16) {
                Text("Self Delivery")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                // Custom Slider Switch
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isGBDelivery.toggle()
                    }
                } label: {
                    ZStack(alignment: isGBDelivery ? .trailing : .leading) {
                        Capsule()
                            .fill(trackPink)
                            .frame(width: 58, height: 26)
                        
                        Circle()
                            .fill(titleBlue)
                            .frame(width: 22, height: 22)
                            .padding(.horizontal, 2)
                            .shadow(color: Color.black.opacity(0.18), radius: 2, x: 0, y: 1)
                    }
                }
                .buttonStyle(.plain)
                
                Text("GB Delivery")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
            }
            
            // "View Terms" Blue Link
            Button {
                alertTitle = "Terms & Conditions"
                alertMessage = "Grabull On-Demand Delivery terms and merchant service agreement."
                showAlert = true
            } label: {
                Text("View Terms")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(titleBlue)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 16)
        }
    }
    
    // MARK: - Estimates Section
    private var estimatesSection: some View {
        VStack(spacing: 24) {
            // 1. Default Pickup Estimate
            SettingStepperRow(
                title: "Default Pickup Estimate",
                valueDisplay: "\(pickupMinutes) Minutes",
                isEnabled: isPickupModified,
                isLoading: activeSavingTarget == .pickup,
                onDecrement: {
                    if pickupMinutes > 0 { pickupMinutes -= 1 }
                },
                onIncrement: {
                    pickupMinutes += 1
                },
                onSave: {
                    callUpdateSettingAPI(target: .pickup)
                }
            )
            
            // 2. Default Delivery Estimate
            SettingStepperRow(
                title: "Default Delivery Estimate",
                valueDisplay: "\(deliveryMinutes) Minutes",
                isEnabled: isDeliveryModified,
                isLoading: activeSavingTarget == .delivery,
                onDecrement: {
                    if deliveryMinutes > 0 { deliveryMinutes -= 1 }
                },
                onIncrement: {
                    deliveryMinutes += 1
                },
                onSave: {
                    callUpdateSettingAPI(target: .delivery)
                }
            )
            
            // 3. Default Miles
            SettingStepperRow(
                title: "Default Miles",
                valueDisplay: "\(defaultMiles) Miles",
                isEnabled: isMilesModified,
                isLoading: activeSavingTarget == .miles,
                onDecrement: {
                    if defaultMiles > 0 { defaultMiles -= 1 }
                },
                onIncrement: {
                    defaultMiles += 1
                },
                onSave: {
                    callUpdateSettingAPI(target: .miles)
                }
            )
            
            // 4. MINIMUM DELIVERY $
            SettingStepperRow(
                title: "MINIMUM DELIVERY $",
                valueDisplay: "\(minDeliveryAmount)",
                isEnabled: isMinDeliveryModified,
                isLoading: activeSavingTarget == .minDelivery,
                onDecrement: {
                    if minDeliveryAmount > 0 { minDeliveryAmount -= 1 }
                },
                onIncrement: {
                    minDeliveryAmount += 1
                },
                onSave: {
                    callUpdateSettingAPI(target: .minDelivery)
                }
            )
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Delivery Charge Section
    private var deliveryChargeSection: some View {
        VStack(spacing: 16) {
            // Section Header Title (Bright Blue)
            Text("Delivery Charge $")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(titleBlue)
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Radio Buttons: Charge type $ and Charge type %
            HStack(spacing: 28) {
                // Option 1: Charge type $
                Button {
                    chargeTypeIsDollar = true
                } label: {
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .stroke(chargeTypeIsDollar ? brandRed : borderGray, lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            if chargeTypeIsDollar {
                                Circle()
                                    .fill(brandRed)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        
                        Text("Charge type $")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(darkTextColor)
                        
                        // Blue info circle !
                        Button {
                            showChargeInfo(isDollar: true)
                        } label: {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(infoBlue)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Option 2: Charge type %
                Button {
                    chargeTypeIsDollar = false
                } label: {
                    HStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .stroke(!chargeTypeIsDollar ? brandRed : borderGray, lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            if !chargeTypeIsDollar {
                                Circle()
                                    .fill(brandRed)
                                    .frame(width: 10, height: 10)
                            }
                        }
                        
                        Text("Charge type %")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(darkTextColor)
                        
                        // Blue info circle !
                        Button {
                            showChargeInfo(isDollar: false)
                        } label: {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(infoBlue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Stepper Row for Delivery Charge Value
            HStack(spacing: 12) {
                // Stepper [-] [Value] [+]
                HStack(spacing: 0) {
                    // Decrement Button
                    Button {
                        if deliveryCharge > 0.5 {
                            deliveryCharge = max(0, (deliveryCharge - 0.5) * 100).rounded() / 100
                        }
                    } label: {
                        Rectangle()
                            .fill(navyStepper)
                            .frame(width: 44, height: 42)
                            .overlay(
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    // Value Box
                    Text(String(format: "%.2f", deliveryCharge))
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(darkTextColor)
                        .frame(width: 110, height: 42)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .stroke(titleBlue, lineWidth: 1.5)
                        )
                    
                    // Increment Button
                    Button {
                        deliveryCharge = ((deliveryCharge + 0.5) * 100).rounded() / 100
                    } label: {
                        Rectangle()
                            .fill(navyStepper)
                            .frame(width: 44, height: 42)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                // Save Button (Rounded blue when enabled, gray outline when disabled)
                Button {
                    callUpdateSettingAPI(target: .deliveryCharge)
                } label: {
                    ZStack {
                        if activeSavingTarget == .deliveryCharge {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isDeliveryChargeModified ? "Save" : "save")
                                .font(.system(size: 14, weight: isDeliveryChargeModified ? .bold : .regular))
                                .foregroundStyle(isDeliveryChargeModified ? Color.white : Color(red: 140/255, green: 145/255, blue: 150/255))
                        }
                    }
                    .frame(width: 78, height: 42)
                    .background(isDeliveryChargeModified ? titleBlue : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isDeliveryChargeModified ? Color.clear : Color(red: 180/255, green: 185/255, blue: 190/255), lineWidth: 1)
                    )
                    .shadow(color: isDeliveryChargeModified ? titleBlue.opacity(0.35) : Color.clear, radius: 4, x: 0, y: 2)
                    .animation(.easeInOut(duration: 0.2), value: isDeliveryChargeModified)
                }
                .buttonStyle(.plain)
                .disabled(!isDeliveryChargeModified || activeSavingTarget != nil)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Print Copies Section
    private var printCopiesSection: some View {
        HStack {
            Text("Select Print Copies")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(titleBlue)
            
            Spacer()
            
            Button {
                showCopiesPicker = true
            } label: {
                Text("\(printCopies)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(brandRed)
                    .frame(width: 86, height: 40)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(orangeBorder, lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }
    
    // MARK: - Printer Section
    private var printerSection: some View {
        HStack {
            Text("Printer")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(titleBlue)
            
            Spacer()
            
            Button {
                showPrinterSheet = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "printer.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(titleBlue)
                    
                    Text(currentPrinter)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(darkTextColor)
                        .multilineTextAlignment(.leading)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(white: 0.95))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
    }
    
    // MARK: - API Actions
    private func fetchTodayOrderStatus() {
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let status = try await NetworkManager.shared.fetchTodayOrderStatus(
                    restaurantId: restaurantId,
                    token: token
                )
                await MainActor.run {
                    self.isOrderOpenToday = status.isOpen
                }
            } catch {
                print("⚠️ [SettingsView] Failed to fetch today order status: \(error)")
            }
        }
    }
    
    private func toggleTodayOrderStatus() {
        isUpdatingTodayStatus = true
        let newStatus = !isOrderOpenToday
        
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let resultMsg = try await NetworkManager.shared.setTodayOrderStatus(
                    isOpen: newStatus,
                    restaurantId: restaurantId,
                    token: token
                )
                await MainActor.run {
                    self.isUpdatingTodayStatus = false
                    self.isOrderOpenToday = newStatus
                    self.alertTitle = newStatus ? "Orders Opened" : "Orders Stopped"
                    self.alertMessage = resultMsg
                    self.showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isUpdatingTodayStatus = false
                    self.alertTitle = "Status Update Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    // MARK: - API Action: Update Settings
    private func callUpdateSettingAPI(target: SettingTarget) {
        guard activeSavingTarget == nil else { return }
        activeSavingTarget = target
        
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        let pickupStr = "\(pickupMinutes)"
        let deliveryStr = "\(deliveryMinutes)"
        let milesStr = "\(defaultMiles)"
        let minDeliveryStr = "\(minDeliveryAmount)"
        let chargeStr = String(format: "%.1f", deliveryCharge)
        let chargeTypeStr = chargeTypeIsDollar ? "$" : "%"
        let gbDeliveryStr = isGBDelivery ? "Yes" : "No"
        
        Task {
            do {
                let response = try await NetworkManager.shared.updateSettings(
                    restaurantId: restaurantId,
                    pickup: pickupStr,
                    delivery: deliveryStr,
                    miles: milesStr,
                    mindelivery: minDeliveryStr,
                    deliverycharge: chargeStr,
                    deliverychargetype: chargeTypeStr,
                    gbdelivery: gbDeliveryStr,
                    token: token
                )
                
                await MainActor.run {
                    self.activeSavingTarget = nil
                    
                    if response.isSuccess {
                        // Sync baseline with successfully saved values
                        if let d = response.data {
                            if let p = d.pickup, let pInt = Int(p) {
                                self.pickupMinutes = pInt
                                self.savedPickupMinutes = pInt
                            } else {
                                self.savedPickupMinutes = self.pickupMinutes
                            }
                            
                            if let del = d.delvry, let dInt = Int(del) {
                                self.deliveryMinutes = dInt
                                self.savedDeliveryMinutes = dInt
                            } else {
                                self.savedDeliveryMinutes = self.deliveryMinutes
                            }
                            
                            if let m = d.mind, let mInt = Int(m) {
                                self.minDeliveryAmount = mInt
                                self.savedMinDeliveryAmount = mInt
                            } else {
                                self.savedMinDeliveryAmount = self.minDeliveryAmount
                            }
                            
                            if let mil = d.miles, let milInt = Int(mil) {
                                self.defaultMiles = milInt
                                self.savedDefaultMiles = milInt
                            } else {
                                self.savedDefaultMiles = self.defaultMiles
                            }
                        } else {
                            self.savedPickupMinutes = self.pickupMinutes
                            self.savedDeliveryMinutes = self.deliveryMinutes
                            self.savedDefaultMiles = self.defaultMiles
                            self.savedMinDeliveryAmount = self.minDeliveryAmount
                        }
                        
                        self.savedDeliveryCharge = self.deliveryCharge
                        self.savedChargeTypeIsDollar = self.chargeTypeIsDollar
                        self.savedIsGBDelivery = self.isGBDelivery
                        
                        // Persist updated settings to SessionManager & UserDefaults
                        SessionManager.shared.updateRestaurantSettings(
                            pickup: self.pickupMinutes,
                            delivery: self.deliveryMinutes,
                            miles: "\(self.defaultMiles)",
                            mindelivery: "\(self.minDeliveryAmount)",
                            dcharge: chargeStr,
                            dchargetype: chargeTypeStr,
                            gbdelivery: gbDeliveryStr
                        )
                        
                        self.alertTitle = "Success"
                        self.alertMessage = response.result ?? "Settings Updated Successfully"
                        self.showAlert = true
                    } else {
                        self.alertTitle = "Error"
                        self.alertMessage = response.result ?? "Failed to update settings."
                        self.showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.activeSavingTarget = nil
                    self.alertTitle = "Error"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    private func showChargeInfo(isDollar: Bool) {
        alertTitle = isDollar ? "Flat Delivery Charge ($)" : "Percentage Delivery Charge (%)"
        alertMessage = isDollar
            ? "A fixed dollar amount will be applied to every delivery order."
            : "A percentage of the subtotal will be applied to delivery orders."
        showAlert = true
    }
    
    // MARK: - Copies Picker Sheet
    private var copiesPickerSheet: some View {
        NavigationStack {
            List(1...5, id: \.self) { count in
                Button {
                    printCopies = count
                    showCopiesPicker = false
                } label: {
                    HStack {
                        Text("\(count) Copies")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(darkTextColor)
                        
                        Spacer()
                        
                        if printCopies == count {
                            Image(systemName: "checkmark")
                                .foregroundStyle(brandRed)
                        }
                    }
                }
            }
            .navigationTitle("Select Print Copies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showCopiesPicker = false
                    }
                    .foregroundStyle(titleBlue)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
    
    // MARK: - Printer Selection Sheet
    private var printerSelectionSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "printer.filled.and.paper")
                    .font(.system(size: 50))
                    .foregroundStyle(titleBlue)
                    .padding(.top, 30)
                
                Text("Bluetooth Receipt Printer")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                Text(currentPrinter)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
                
                Button("Test Print") {
                    showPrinterSheet = false
                    alertTitle = "Printer Test"
                    alertMessage = "Sent test receipt print command."
                    showAlert = true
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(titleBlue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .navigationTitle("Receipt Printer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        showPrinterSheet = false
                    }
                    .foregroundStyle(titleBlue)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Setting Stepper Row Component (Pixel Perfect to Design)
struct SettingStepperRow: View {
    var title: String
    var valueDisplay: String
    var isEnabled: Bool = false
    var isLoading: Bool = false
    var onDecrement: () -> Void
    var onIncrement: () -> Void
    var onSave: () -> Void
    
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let navyStepper = Color(red: 20/255, green: 56/255, blue: 91/255)
    private let borderBlue = Color(red: 0/255, green: 130/255, blue: 225/255)
    private let titleBlue = Color(red: 0/255, green: 130/255, blue: 225/255)
    
    var body: some View {
        VStack(spacing: 8) {
            // Centered Title
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(darkTextColor)
            
            // Stepper and Save Button Row
            HStack(spacing: 12) {
                // Stepper [-] [Value] [+]
                HStack(spacing: 0) {
                    // Decrement Button
                    Button(action: onDecrement) {
                        Rectangle()
                            .fill(navyStepper)
                            .frame(width: 44, height: 42)
                            .overlay(
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    // Value Box
                    Text(valueDisplay)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(darkTextColor)
                        .frame(width: 110, height: 42)
                        .background(Color.white)
                        .overlay(
                            Rectangle()
                                .stroke(borderBlue, lineWidth: 1.5)
                        )
                    
                    // Increment Button
                    Button(action: onIncrement) {
                        Rectangle()
                            .fill(navyStepper)
                            .frame(width: 44, height: 42)
                            .overlay(
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                // Save Button (Rounded blue when enabled, gray outline when disabled)
                Button(action: {
                    if isEnabled && !isLoading {
                        onSave()
                    }
                }) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isEnabled ? "Save" : "save")
                                .font(.system(size: 14, weight: isEnabled ? .bold : .regular))
                                .foregroundStyle(isEnabled ? Color.white : Color(red: 140/255, green: 145/255, blue: 150/255))
                        }
                    }
                    .frame(width: 78, height: 42)
                    .background(isEnabled ? titleBlue : Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isEnabled ? Color.clear : Color(red: 180/255, green: 185/255, blue: 190/255), lineWidth: 1)
                    )
                    .shadow(color: isEnabled ? titleBlue.opacity(0.35) : Color.clear, radius: 4, x: 0, y: 2)
                    .animation(.easeInOut(duration: 0.2), value: isEnabled)
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled || isLoading)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

#Preview("Settings Screen") {
    SettingsView(onBack: {})
}

#Preview("Stepper Rows (Default vs Enabled)") {
    VStack(spacing: 24) {
        SettingStepperRow(
            title: "Default Pickup Estimate (Unchanged)",
            valueDisplay: "25 Minutes",
            isEnabled: false,
            isLoading: false,
            onDecrement: {},
            onIncrement: {},
            onSave: {}
        )
        
        SettingStepperRow(
            title: "Default Delivery Estimate (Modified - Blue Save)",
            valueDisplay: "51 Minutes",
            isEnabled: true,
            isLoading: false,
            onDecrement: {},
            onIncrement: {},
            onSave: {}
        )
        
        SettingStepperRow(
            title: "Default Miles (Saving State)",
            valueDisplay: "8 Miles",
            isEnabled: true,
            isLoading: true,
            onDecrement: {},
            onIncrement: {},
            onSave: {}
        )
    }
    .padding()
}
