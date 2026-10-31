//
//  OrderDetailView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 31/10/26.
//

import SwiftUI

// MARK: - Order Detail Item Model
struct OrderDetailItem: Identifiable, Sendable {
    var id: String = UUID().uuidString
    var quantity: Int
    var heading: String
    var instruction: String? = nil
    var price: String
}

// MARK: - Pending Add Item Model
struct PendingAddItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var price: String
}

struct OrderDetailView: View {
    var order: OrderItemModel?
    var mode: OrderTab = .new
    var onBack: () -> Void
    var onOrderUpdated: (() -> Void)? = nil
    
    // Alert & Sheet states
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var shouldDismissOnAlertOK: Bool = false
    @State private var isConfirmed: Bool = false
    @State private var isPrinting: Bool = false
    @State private var showUpdateStatusModal: Bool = false
    @State private var currentStatusText: String = "Update Order status"
    
    // Add Items Modal states (In-House Order)
    @State private var showAddItemsModal: Bool = false
    @State private var newEntryItemName: String = ""
    @State private var newEntryItemPrice: String = ""
    @State private var pendingAddedItems: [PendingAddItem] = []
    @State private var serverUpdatedSubtotal: String? = nil
    @State private var serverUpdatedTax: String? = nil
    @State private var serverUpdatedTotal: String? = nil
    
    // Confirmation & Cancel Modal states (New Order)
    @State private var showConfirmModal: Bool = false
    @State private var showCancelReasonDropdown: Bool = false
    @State private var selectedCancelReason: String = "Choose cancel reason"
    @State private var isSubmittingStatus: Bool = false
    
    init(
        order: OrderItemModel? = nil,
        mode: OrderTab = .new,
        showConfirmModal: Bool = false,
        showUpdateStatusModal: Bool = false,
        showAddItemsModal: Bool = false,
        onBack: @escaping () -> Void,
        onOrderUpdated: (() -> Void)? = nil
    ) {
        self.order = order
        self.mode = mode
        self.onBack = onBack
        self.onOrderUpdated = onOrderUpdated
        self._showConfirmModal = State(initialValue: showConfirmModal)
        self._showUpdateStatusModal = State(initialValue: showUpdateStatusModal)
        self._showAddItemsModal = State(initialValue: showAddItemsModal)
    }
    
    // Dynamic items list
    @State private var itemsList: [OrderDetailItem] = []
    
    // MARK: - Cancellation Reasons (Pickup vs Delivery)
    private let cancelReasonListPickup: [String] = [
        "Choose cancel reason",
        "Ordered twice",
        "Changed Mind",
        "Food Complaint compensating",
        "Wrong Location Order",
        "Store was close",
        "Out of Items",
        "Temporary Outage",
        "Did not Receive order at store"
    ]
    
    private let cancelReasonListDelivery: [String] = [
        "Choose cancel reason",
        "Ordered twice",
        "Changed Mind",
        "Food Complaint compensating",
        "Late Delivery compensating",
        "Driver Not available",
        "Wrong Location Order",
        "Store was close",
        "Out of Items",
        "Temporary Outage",
        "Did not Receive order at store"
    ]
    
    private var cancelReasons: [String] {
        let isDelivery = orderType.caseInsensitiveCompare("Delivery") == .orderedSame
        return isDelivery ? cancelReasonListDelivery : cancelReasonListPickup
    }
    
    // Exact theme colors matching the screenshot
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let paidGreen = Color(red: 40/255, green: 150/255, blue: 60/255)
    private let confirmBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    private let printNavy = Color(red: 22/255, green: 46/255, blue: 77/255)
    private let lightGrayBtn = Color(red: 238/255, green: 240/255, blue: 242/255)
    private let borderGray = Color(red: 210/255, green: 215/255, blue: 220/255)
    private let headerBg = Color(red: 242/255, green: 242/255, blue: 242/255)
    private let primaryBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    
    // Mode helpers
    private var isNew: Bool { mode == .new }
    private var isInHouse: Bool { mode == .inHouse }
    private var isCompleted: Bool { mode == .completed }
    
    // MARK: - Dynamic Ready Times from Login API (Android Equivalent Logic)
    private var readyTimeValues: [Int] {
        let hold = order?.hold ?? ""
        let isHold = hold.caseInsensitiveCompare("Yes") == .orderedSame
        
        if !isHold {
            let isDelivery = orderType.caseInsensitiveCompare("Delivery") == .orderedSame
            let restaurant = SessionManager.shared.currentRestaurant
            
            if isDelivery {
                if let deliveryTimes = restaurant?.deliverytime, !deliveryTimes.isEmpty {
                    return deliveryTimes
                }
            } else {
                if let pickupTimes = restaurant?.pickuptime, !pickupTimes.isEmpty {
                    return pickupTimes
                }
            }
        }
        
        let isDelivery = orderType.caseInsensitiveCompare("Delivery") == .orderedSame
        return isDelivery ? [22, 27, 32, 37, 42, 47] : [15, 20, 25, 30, 35, 40]
    }
    
    // MARK: - API Call: Confirm Order (ConfirmOrder WebService)
    private func callConfirmOrderAPI(readytimeMinutes: Int) {
        guard let restaurant = SessionManager.shared.currentRestaurant else {
            alertTitle = "Error"
            alertMessage = "Restaurant information not found."
            showAlert = true
            return
        }
        
        let rawOrderId = order?.id ?? orderNumber
        let readytimeStr = "\(readytimeMinutes) minutes"
        let token = restaurant.token ?? SessionManager.shared.deviceToken
        let restaurantId = restaurant.restaurant_id
        
        isSubmittingStatus = true
        
        Task {
            do {
                let response = try await NetworkManager.shared.confirmOrUpdateOrderStatus(
                    restaurantId: restaurantId,
                    orderId: rawOrderId,
                    status: Constant.ORDER_STATUS.CONFIRMED,
                    readytime: readytimeStr,
                    reason: "",
                    token: token
                )
                
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.showConfirmModal = false
                    self.isConfirmed = true
                    self.shouldDismissOnAlertOK = true
                    
                    let msg = response.result ?? "Order confirmed successfully!"
                    self.alertTitle = "Order Confirmed"
                    self.alertMessage = "Order #\(orderNumber) confirmed!\nEstimated ready: \(readytimeStr)\n\(msg)"
                    self.showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.alertTitle = "Failed to Confirm"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    // MARK: - API Call: Cancel Order (ConfirmOrder WebService)
    private func callCancelOrderAPI(reason: String) {
        guard let restaurant = SessionManager.shared.currentRestaurant else {
            alertTitle = "Error"
            alertMessage = "Restaurant information not found."
            showAlert = true
            return
        }
        
        let rawOrderId = order?.id ?? orderNumber
        let token = restaurant.token ?? SessionManager.shared.deviceToken
        let restaurantId = restaurant.restaurant_id
        
        isSubmittingStatus = true
        
        Task {
            do {
                let response = try await NetworkManager.shared.confirmOrUpdateOrderStatus(
                    restaurantId: restaurantId,
                    orderId: rawOrderId,
                    status: Constant.ORDER_STATUS.CANCEL,
                    readytime: "",
                    reason: reason,
                    token: token
                )
                
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.showConfirmModal = false
                    self.showCancelReasonDropdown = false
                    self.shouldDismissOnAlertOK = true
                    
                    let msg = response.result ?? "Order has been cancelled."
                    self.alertTitle = "Order Cancelled"
                    self.alertMessage = "Order #\(orderNumber) has been cancelled.\nReason: \(reason)\n\(msg)"
                    self.showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.alertTitle = "Failed to Cancel"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    // MARK: - API Call: Complete In-House Order (Picked Up / Delivered)
    private func callUpdateOrderStatusAPI(status: String) {
        guard let restaurant = SessionManager.shared.currentRestaurant else {
            alertTitle = "Error"
            alertMessage = "Restaurant information not found."
            showAlert = true
            return
        }
        
        let rawOrderId = order?.id ?? orderNumber
        let token = restaurant.token ?? SessionManager.shared.deviceToken
        let restaurantId = restaurant.restaurant_id
        
        isSubmittingStatus = true
        
        Task {
            do {
                let response = try await NetworkManager.shared.confirmOrUpdateOrderStatus(
                    restaurantId: restaurantId,
                    orderId: rawOrderId,
                    status: status,
                    readytime: "",
                    reason: "",
                    token: token
                )
                
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.showUpdateStatusModal = false
                    self.currentStatusText = status
                    self.shouldDismissOnAlertOK = true
                    
                    let msg = response.result ?? "Order status saved successfully"
                    self.alertTitle = "Order Status Updated"
                    self.alertMessage = "Order #\(orderNumber) marked as \(status).\n\(msg)"
                    self.showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.alertTitle = "Failed to Update"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    // MARK: - API Call: Add Order Items (AddOrderItems)
    private func callAddOrderItemsAPI(items: [PendingAddItem]) {
        // Validation from Android:
        // if (myAdapter.getPriceCount() <= 500) { ... } else { Util.alertDialog("Item(s) price should be maximum $500") }
        let totalItemsPrice = items.reduce(0.0) { sum, item in
            let clean = item.price.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            return sum + (Double(clean) ?? 0.0)
        }
        
        if totalItemsPrice > 500.0 {
            alertTitle = "Price Exceeded"
            alertMessage = "Item(s) price should be maximum $500"
            showAlert = true
            return
        }
        
        guard let restaurant = SessionManager.shared.currentRestaurant else {
            alertTitle = "Error"
            alertMessage = "Restaurant information not found."
            showAlert = true
            return
        }
        
        let rawOrderId = order?.id ?? orderNumber
        let token = restaurant.token ?? SessionManager.shared.deviceToken
        let restaurantId = restaurant.restaurant_id
        let payloadItems = items.map {
            let clean = $0.price.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            return OrderItemPayload(items: $0.name, price: clean)
        }
        
        isSubmittingStatus = true
        
        Task {
            do {
                let response = try await NetworkManager.shared.addOrderItems(
                    restaurantId: restaurantId,
                    orderId: rawOrderId,
                    items: payloadItems,
                    token: token
                )
                
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.showAddItemsModal = false
                    self.newEntryItemName = ""
                    self.newEntryItemPrice = ""
                    self.pendingAddedItems = []
                    
                    // Add items locally to the view
                    for item in items {
                        let clean = item.price.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
                        let formattedPrice = String(format: "$%.2f", Double(clean) ?? 0.0)
                        self.itemsList.append(
                            OrderDetailItem(
                                quantity: 1,
                                heading: item.name,
                                instruction: nil,
                                price: formattedPrice
                            )
                        )
                    }
                    
                    // Update totals from server response
                    if let data = response.data {
                        if let sub = data.subtotal {
                            self.serverUpdatedSubtotal = String(format: "$%.2f", sub)
                        }
                        if let tx = data.tax {
                            self.serverUpdatedTax = String(format: "$%.2f", tx)
                        }
                        if let tot = data.total {
                            self.serverUpdatedTotal = String(format: "$%.2f", tot)
                        }
                    }
                    
                    // Trigger silent refresh of parent orders
                    self.onOrderUpdated?()
                    
                    self.alertTitle = "Items Added"
                    self.alertMessage = response.displayMessage
                    self.showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.isSubmittingStatus = false
                    self.alertTitle = "Failed to Add Items"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
    
    // Computed helper properties
    private var orderNumber: String {
        if let id = order?.id, !id.isEmpty {
            return id.hasPrefix("GD") ? id : "GD\(id)"
        }
        return isCompleted ? "GD2610292350392" : "GD261031721706"
    }
    
    private var customerName: String {
        order?.customerName.isEmpty == false ? (order?.customerName ?? "Test Order") : "Test Order"
    }
    
    private var customerPhone: String {
        let phone = order?.phone ?? "7891234560"
        return phone.isEmpty ? "7891234560" : phone
    }
    
    private var orderTimeText: String {
        if let dt = order?.dateTime, !dt.isEmpty {
            return "ORDER TIME: \(dt)"
        }
        if isCompleted {
            return "ORDER TIME: Oct 29, 2026, 11:50 PM"
        } else if isInHouse {
            return "ORDER TIME: Oct 31, 2026, 07:21 AM"
        } else {
            return "ORDER TIME: Oct 31 at 07:21 AM"
        }
    }
    
    private var orderType: String {
        order?.orderType.uppercased() ?? "PICKUP"
    }
    
    private var subTotalValue: Double {
        itemsList.reduce(0.0) { sum, item in
            let clean = item.price.replacingOccurrences(of: "$", with: "").trimmingCharacters(in: .whitespaces)
            return sum + (Double(clean) ?? 0.0) * Double(item.quantity)
        }
    }
    
    private var subTotalAmount: String {
        if let serverSubtotal = serverUpdatedSubtotal {
            return serverSubtotal
        }
        if itemsList.count > 2 {
            return String(format: "$%.2f", subTotalValue)
        }
        return isCompleted ? "$5.96" : "$42.93"
    }
    
    private var discountText: String {
        isInHouse ? "Discount-$0.00" : "Discount-$0"
    }
    
    private var taxAmount: String {
        if let serverTax = serverUpdatedTax {
            return serverTax
        }
        if itemsList.count > 2 {
            return String(format: "$%.2f", subTotalValue * 0.0624)
        }
        return isCompleted ? "$0.37" : "$2.68"
    }
    
    private var tipAmount: String {
        "$0.00"
    }
    
    private var totalAmount: String {
        if let serverTotal = serverUpdatedTotal {
            return serverTotal
        }
        if itemsList.count > 2 {
            let tax = subTotalValue * 0.0624
            return String(format: "$%.2f", subTotalValue + tax)
        }
        if let amount = order?.amount, !amount.isEmpty {
            return amount
        }
        return isCompleted ? "$6.33" : "$45.61"
    }
    
    private var completedButtonTitle: String {
        orderType.contains("DELIVERY") ? "Delivered" : "Picked Up"
    }
    
    var body: some View {
        ZStack {
            // Main Screen Content
            mainContentView
            
            // Confirm Ready Time & Cancel Modal Overlay (When CONFIRM is tapped in New Order)
            if showConfirmModal {
                confirmTimeAndCancelModal
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(100)
            }
            
            // In-House Update Status Modal Overlay (When Update Order status is tapped)
            if showUpdateStatusModal {
                inHouseUpdateStatusModal
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(101)
            }
            
            // In-House Add Items Modal Overlay (When ADD ITEM is tapped)
            if showAddItemsModal {
                inHouseAddItemsModal
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    .zIndex(102)
            }
        }
        .animation(.easeInOut(duration: 0.22), value: showConfirmModal)
        .animation(.easeInOut(duration: 0.22), value: showUpdateStatusModal)
        .animation(.easeInOut(duration: 0.22), value: showAddItemsModal)
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            setupInitialItems()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if shouldDismissOnAlertOK {
                    shouldDismissOnAlertOK = false
                    if let onOrderUpdated = onOrderUpdated {
                        onOrderUpdated()
                    } else {
                        onBack()
                    }
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Main Content View
    private var mainContentView: some View {
        VStack(spacing: 0) {
            // Header Bar
            ZStack {
                // Centered Title
                Text("Order Details")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                // Leading Back Button (< BACK in red)
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .bold))
                            
                            Text("BACK")
                                .font(.system(size: 16, weight: .bold))
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
            .background(headerBg)
            
            Rectangle()
                .fill(Color(white: 0.82))
                .frame(height: 1)
            
            // In-House Exclusive: ADD ITEM Blue Strip
            if isInHouse {
                ZStack {
                    primaryBlue
                    
                    Button {
                        withAnimation {
                            showAddItemsModal = true
                        }
                    } label: {
                        Text("ADD ITEM")
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(darkTextColor)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 52)
            }
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Top Section (Dollar icon, Pickup/Delivery info, PREPAID, Action button, PRINT)
                    topInfoCard
                    
                    // 2. Customer Phone Bar with green borders
                    customerPhoneBar
                    
                    // 3. Black Order Time Bar
                    orderTimeBar
                    
                    // 4. Order Items Section
                    orderItemsSection
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                    
                    // 5. Bill Summary (Subtotal, Discount, Tax, Tip, Boxed Total)
                    billSummarySection
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                    
                    // 6. Action Icons (Re-fax & Re-Email)
                    actionsRow
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                    
                    // 7. Note Section
                    noteSection
                        .padding(.horizontal, 16)
                        .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 40)
                }
            }
        }
    }
    
    // MARK: - Setup Initial Items
    private func setupInitialItems() {
        if isCompleted {
            itemsList = [
                OrderDetailItem(
                    quantity: 1,
                    heading: "Item Heading 1 (MD) (Regular)",
                    instruction: nil,
                    price: "$2.95"
                ),
                OrderDetailItem(
                    quantity: 1,
                    heading: "Item Heading 2 (MD) (Regular)",
                    instruction: "This is a test order",
                    price: "$3.01"
                )
            ]
        } else {
            itemsList = [
                OrderDetailItem(
                    quantity: 1,
                    heading: "Item Heading 1 (MD) (Regular)",
                    instruction: nil,
                    price: "$21.37"
                ),
                OrderDetailItem(
                    quantity: 1,
                    heading: "Item Heading 2 (MD) (Regular)",
                    instruction: "This is a test order",
                    price: "$21.56"
                )
            ]
        }
    }
    
    // MARK: - 1. Top Info Card
    private var topInfoCard: some View {
        HStack(alignment: .top, spacing: 14) {
            // Dollar Sign Icon in Black Circle
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 42, height: 42)
                
                Image(systemName: "dollarsign")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
            }
            .padding(.top, 4)
            
            // Middle: Order Type, Do not charge, Customer Name
            VStack(alignment: .leading, spacing: 4) {
                Text(orderType)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(paidGreen)
                
                Text("Do not charge the customer")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color(red: 60/255, green: 60/255, blue: 60/255))
                
                Text(customerName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .padding(.top, 6)
            }
            
            Spacer()
            
            // Right Column: PREPAID badge, Action button, PRINT button
            VStack(alignment: .trailing, spacing: 8) {
                // PREPAID Green Badge
                Text("PREPAID")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(paidGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                
                // Contextual Button based on Mode
                if isCompleted {
                    // Completed Mode: "Picked Up" or "Delivered"
                    Button {
                        alertTitle = "Order Status"
                        alertMessage = "This order was completed and \(completedButtonTitle.lowercased())."
                        showAlert = true
                    } label: {
                        Text(completedButtonTitle)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(confirmBlue)
                            .frame(width: 125, height: 32)
                            .background(lightGrayBtn)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(borderGray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                } else if isInHouse {
                    // In-House Mode: "Update Order status"
                    Button {
                        withAnimation {
                            showUpdateStatusModal = true
                        }
                    } label: {
                        Text(currentStatusText)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(confirmBlue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                            .padding(.horizontal, 6)
                            .frame(width: 125, height: 32)
                            .background(lightGrayBtn)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(borderGray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                } else {
                    // New Order Mode: "CONFIRM"
                    Button {
                        withAnimation {
                            showConfirmModal = true
                        }
                    } label: {
                        Text(isConfirmed ? "CONFIRMED" : "CONFIRM")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(isConfirmed ? Color.gray : confirmBlue)
                            .frame(width: 110, height: 32)
                            .background(lightGrayBtn)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(borderGray, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isConfirmed)
                }
                
                // PRINT Button
                Button {
                    isPrinting = true
                    alertTitle = "Receipt Printed"
                    alertMessage = "Print order command sent to printer."
                    showAlert = true
                } label: {
                    Text("PRINT")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: isNew ? 110 : 125, height: 32)
                        .background(printNavy)
                        .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
    
    // MARK: - 2. Customer Phone Bar
    private var customerPhoneBar: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(paidGreen)
                .frame(height: 2)
            
            Text(isNew ? "Ph: \(customerPhone)" : "Customer Ph: \(customerPhone)")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(darkTextColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 7)
                .background(Color.white)
            
            Rectangle()
                .fill(paidGreen)
                .frame(height: 2)
        }
    }
    
    // MARK: - 3. Black Order Time Bar
    private var orderTimeBar: some View {
        Text(orderTimeText)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.black)
    }
    
    // MARK: - 4. Order Items Section
    private var orderItemsSection: some View {
        VStack(spacing: 0) {
            // Header Row: ORDER # and Order(count items)
            HStack {
                Text("ORDER # \(orderNumber)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                Spacer()
                
                Text("Order(\(itemsList.count) items)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(darkTextColor)
            }
            .padding(.bottom, 8)
            
            Rectangle()
                .fill(Color.black)
                .frame(height: 1)
            
            // List of Items
            ForEach(itemsList) { item in
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(item.quantity)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(darkTextColor)
                            .frame(width: 18, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.heading)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(darkTextColor)
                            
                            if let instruction = item.instruction {
                                Text(instruction)
                                    .font(.system(size: 12, weight: .regular))
                                    .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                            }
                        }
                        
                        Spacer()
                        
                        Text(item.price)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(darkTextColor)
                    }
                    .padding(.vertical, 8)
                    
                    Rectangle()
                        .fill(Color(white: 0.85))
                        .frame(height: 1)
                }
            }
        }
    }
    
    // MARK: - 5. Bill Summary Section
    private var billSummarySection: some View {
        VStack(alignment: .trailing, spacing: 8) {
            // Sub Total
            HStack {
                Spacer()
                Text("Sub Total")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 120, alignment: .trailing)
                
                Text(subTotalAmount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 80, alignment: .trailing)
            }
            
            // Discount
            HStack {
                Spacer()
                Text(discountText)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 140, alignment: .trailing)
            }
            
            // Tax
            HStack {
                Spacer()
                Text("Tax")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 120, alignment: .trailing)
                
                Text(taxAmount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 80, alignment: .trailing)
            }
            
            // Tip
            HStack {
                Spacer()
                Text("Tip")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 120, alignment: .trailing)
                
                Text(tipAmount)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .frame(width: 80, alignment: .trailing)
            }
            
            // Boxed Total
            HStack {
                Spacer()
                Text("Total \(totalAmount)")
                    .font(.system(size: 19, weight: .heavy))
                    .foregroundStyle(darkTextColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 2)
                    )
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: - 6. Action Circular Icons (Re-fax & Re-Email)
    private var actionsRow: some View {
        HStack(spacing: 36) {
            // Re-fax Button
            Button {
                alertTitle = "Re-Fax"
                alertMessage = "Re-faxing order receipt to restaurant fax number..."
                showAlert = true
            } label: {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(brandRed, lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "printer.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(brandRed)
                            
                            Text("FAX")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(brandRed)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                    
                    Text("Re-fax")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(darkTextColor)
                }
            }
            .buttonStyle(.plain)
            
            // Re-Email Button
            Button {
                alertTitle = "Re-Email"
                alertMessage = "Sending receipt email to store manager..."
                showAlert = true
            } label: {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(brandRed, lineWidth: 2)
                            .frame(width: 50, height: 50)
                        
                        VStack(spacing: 2) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(brandRed)
                            
                            Text("FAX")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(brandRed)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                    
                    Text("Re-Email")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(darkTextColor)
                }
            }
            .buttonStyle(.plain)
            
            Spacer()
        }
    }
    
    // MARK: - 7. Note Section
    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Note:-")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(darkTextColor)
            
            Text("**This is a test order. Do not prepare the food.")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(darkTextColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 8. Confirm Time & Cancel Modal (Screenshot 1 & 2 Exact Match)
    private var confirmTimeAndCancelModal: some View {
        ZStack {
            // Semi-transparent dark background
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showConfirmModal = false
                        showCancelReasonDropdown = false
                    }
                }
            
            // White Dialog Card Container
            VStack(spacing: 0) {
                // Top-Right Close "X" Button
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            showConfirmModal = false
                            showCancelReasonDropdown = false
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(red: 45/255, green: 45/255, blue: 45/255))
                                .frame(width: 26, height: 26)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                
                // Prompt Header
                Text("Click on Button To Confirm Time When it\nwill be Ready")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(darkTextColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
                    .padding(.bottom, 14)
                
                // Stack of Ready In X Min Black Buttons (Dynamic from readyTimeValues)
                VStack(spacing: 6) {
                    ForEach(readyTimeValues, id: \.self) { minutes in
                        Button {
                            callConfirmOrderAPI(readytimeMinutes: minutes)
                        } label: {
                            HStack(spacing: 8) {
                                if isSubmittingStatus {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text("READY IN \(minutes) MIN")
                                    .font(.system(size: 15, weight: .heavy))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(Color.black)
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        .buttonStyle(.plain)
                        .disabled(isSubmittingStatus)
                    }
                }
                .padding(.horizontal, 14)
                
                // "OR" Divider
                Text("OR")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(darkTextColor)
                    .padding(.vertical, 10)
                
                // Cancel Reason Dropdown
                VStack(spacing: 0) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showCancelReasonDropdown.toggle()
                        }
                    } label: {
                        HStack {
                            Text(selectedCancelReason)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(brandRed)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(darkTextColor)
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            LinearGradient(
                                colors: [Color(white: 0.98), Color(white: 0.88)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(white: 0.72), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    // Dropdown Options List (Screenshot 2)
                    if showCancelReasonDropdown {
                        ScrollView(showsIndicators: true) {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(cancelReasons, id: \.self) { reason in
                                    Button {
                                        selectedCancelReason = reason
                                        withAnimation {
                                            showCancelReasonDropdown = false
                                        }
                                    } label: {
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(reason)
                                                .font(.system(size: 15, weight: .regular))
                                                .foregroundStyle(brandRed)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 10)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            
                                            Rectangle()
                                                .fill(Color(white: 0.90))
                                                .frame(height: 1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 220)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color(white: 0.72), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 14)
                
                // Red CANCEL Button
                Button {
                    if selectedCancelReason == "Choose cancel reason" {
                        alertTitle = "Select Reason"
                        alertMessage = "Please select a cancellation reason from the dropdown first."
                        showAlert = true
                    } else {
                        callCancelOrderAPI(reason: selectedCancelReason)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isSubmittingStatus {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("CANCEL")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(brandRed)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }
                .buttonStyle(.plain)
                .disabled(isSubmittingStatus)
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 16)
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 6)
            .padding(.horizontal, 18)
        }
    }
    
    // MARK: - 9. In-House Update Order Status Modal (Screenshot Match)
    private var inHouseUpdateStatusModal: some View {
        let isDelivery = orderType.caseInsensitiveCompare("Delivery") == .orderedSame
        let completeTitle = isDelivery ? "DELIVERED" : "PICKED UP"
        let completeStatus = isDelivery ? Constant.ORDER_STATUS.DELIVERED : Constant.ORDER_STATUS.PICKEDUP
        
        return ZStack {
            // Dark Semi-Transparent Backdrop
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showUpdateStatusModal = false
                        showCancelReasonDropdown = false
                    }
                }
            
            // Dialog Card Container
            VStack(spacing: 0) {
                // Header Bar (Solid Blue with orderNumber and X mark)
                ZStack {
                    confirmBlue
                    
                    Text(orderNumber)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                showUpdateStatusModal = false
                                showCancelReasonDropdown = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.trailing, 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 56)
                
                // Body Content
                VStack(spacing: 20) {
                    // 1. Green Complete Order Button (PICKED UP / DELIVERED)
                    Button {
                        callUpdateOrderStatusAPI(status: completeStatus)
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmittingStatus {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(completeTitle)
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 40/255, green: 167/255, blue: 69/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmittingStatus)
                    .padding(.top, 4)
                    
                    // 2. Cancel Reason Dropdown
                    VStack(spacing: 0) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCancelReasonDropdown.toggle()
                            }
                        } label: {
                            HStack {
                                Text(selectedCancelReason)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(brandRed)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Image(systemName: "arrowtriangle.down.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(Color(white: 0.4))
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 44)
                        }
                        .buttonStyle(.plain)
                        
                        Rectangle()
                            .fill(Color(white: 0.85))
                            .frame(height: 1)
                        
                        // Expanded Dropdown List
                        if showCancelReasonDropdown {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(cancelReasons, id: \.self) { reason in
                                        Button {
                                            selectedCancelReason = reason
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                showCancelReasonDropdown = false
                                            }
                                        } label: {
                                            VStack(alignment: .leading, spacing: 0) {
                                                Text(reason)
                                                    .font(.system(size: 15, weight: .regular))
                                                    .foregroundStyle(brandRed)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 10)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                
                                                Rectangle()
                                                    .fill(Color(white: 0.92))
                                                    .frame(height: 1)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color(white: 0.8), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                            .padding(.top, 4)
                        }
                    }
                    
                    // 3. Orange CANCEL Button (Exact Screenshot Match)
                    Button {
                        if selectedCancelReason == "Choose cancel reason" {
                            alertTitle = "Select Reason"
                            alertMessage = "Please select a cancellation reason from the dropdown first."
                            showAlert = true
                        } else {
                            callCancelOrderAPI(reason: selectedCancelReason)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmittingStatus {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("CANCEL")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 255/255, green: 130/255, blue: 0/255))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmittingStatus)
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.32), radius: 18, x: 0, y: 8)
            .padding(.horizontal, 22)
        }
    }
    
    // MARK: - 10. In-House Add Item Modal (Screenshot Match)
    private var inHouseAddItemsModal: some View {
        ZStack {
            // Dark Semi-Transparent Backdrop
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showAddItemsModal = false
                    }
                }
            
            // Dialog Card Container
            VStack(spacing: 0) {
                // Header Bar (Solid Blue with orderNumber and X mark)
                ZStack {
                    confirmBlue
                    
                    Text(orderNumber)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                    
                    HStack {
                        Spacer()
                        Button {
                            withAnimation {
                                showAddItemsModal = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 19, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.trailing, 16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(height: 56)
                
                // Body Content
                VStack(spacing: 12) {
                    // Instruction text 1 (Black/Dark bold)
                    Text("To enter more than 1 item use plus icon")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(darkTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.top, 6)
                    
                    // Instruction text 2 & 3 (Blue regular)
                    VStack(spacing: 2) {
                        Text("Taxes will be automatically applicable,")
                        Text("Please only enter the item price")
                    }
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(confirmBlue)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 6)
                    
                    // Input Row (Enter item name..., $, and Green Plus Button)
                    HStack(spacing: 8) {
                        // Name textfield
                        TextField("Enter item name...", text: $newEntryItemName)
                            .font(.system(size: 14))
                            .padding(.horizontal, 10)
                            .frame(height: 42)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color(white: 0.85), lineWidth: 1)
                            )
                        
                        // Price textfield with leading $
                        HStack(spacing: 2) {
                            Text("$")
                                .font(.system(size: 14))
                                .foregroundStyle(Color(white: 0.5))
                            
                            TextField("", text: $newEntryItemPrice)
                                .font(.system(size: 14))
                                .keyboardType(.decimalPad)
                        }
                        .padding(.horizontal, 8)
                        .frame(width: 72, height: 42)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color(white: 0.85), lineWidth: 1)
                        )
                        
                        // Green Plus Button
                        Button {
                            let trimmedName = newEntryItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                            let trimmedPrice = newEntryItemPrice.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "$", with: "")
                            
                            guard !trimmedName.isEmpty else {
                                alertTitle = "Item Name Required"
                                alertMessage = "Please enter an item name."
                                showAlert = true
                                return
                            }
                            guard !trimmedPrice.isEmpty, Double(trimmedPrice) != nil else {
                                alertTitle = "Valid Price Required"
                                alertMessage = "Please enter a valid item price."
                                showAlert = true
                                return
                            }
                            
                            withAnimation(.easeInOut(duration: 0.2)) {
                                pendingAddedItems.append(PendingAddItem(name: trimmedName, price: trimmedPrice))
                                newEntryItemName = ""
                                newEntryItemPrice = ""
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 44, height: 42)
                                .background(Color(red: 40/255, green: 167/255, blue: 69/255))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Added Items List (Each row with Name, Price, and Red Cross Button)
                    if !pendingAddedItems.isEmpty {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(pendingAddedItems) { item in
                                    HStack(spacing: 8) {
                                        // Name box
                                        Text(item.name)
                                            .font(.system(size: 14))
                                            .foregroundStyle(darkTextColor)
                                            .padding(.horizontal, 10)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .frame(height: 42)
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(Color(white: 0.85), lineWidth: 1)
                                            )
                                        
                                        // Price box
                                        Text("$\(item.price)")
                                            .font(.system(size: 14))
                                            .foregroundStyle(darkTextColor)
                                            .padding(.horizontal, 8)
                                            .frame(width: 72, height: 42, alignment: .leading)
                                            .background(Color.white)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(Color(white: 0.85), lineWidth: 1)
                                            )
                                        
                                        // Red Cross Button
                                        Button {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                pendingAddedItems.removeAll { $0.id == item.id }
                                            }
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundStyle(.white)
                                                .frame(width: 44, height: 42)
                                                .background(brandRed)
                                                .clipShape(RoundedRectangle(cornerRadius: 3))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 180)
                    }
                    
                    // Modify now Blue Button
                    Button {
                        // If user currently typed something in input row without clicking plus, auto include it
                        let currentName = newEntryItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let currentPrice = newEntryItemPrice.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "$", with: "")
                        var allItems = pendingAddedItems
                        if !currentName.isEmpty && !currentPrice.isEmpty, Double(currentPrice) != nil {
                            allItems.append(PendingAddItem(name: currentName, price: currentPrice))
                        }
                        
                        guard !allItems.isEmpty else {
                            alertTitle = "No Items"
                            alertMessage = "Please add at least 1 item name and price."
                            showAlert = true
                            return
                        }
                        
                        callAddOrderItemsAPI(items: allItems)
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmittingStatus {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text("Modify now")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(confirmBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(isSubmittingStatus)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.black.opacity(0.32), radius: 18, x: 0, y: 8)
            .padding(.horizontal, 20)
        }
    }
}

#Preview("In-House Order Details with Add Items Modal") {
    OrderDetailView(
        order: OrderItemModel(
            id: "GD261031721706",
            customerName: "Test Order",
            phone: "7891234560",
            orderType: "PICKUP",
            isPaid: true,
            dateTime: "Oct 31 at 07:21 AM",
            amount: "$45.61"
        ),
        mode: .inHouse,
        showAddItemsModal: true,
        onBack: {}
    )
}

#Preview("In-House Order Details with Update Status Modal") {
    OrderDetailView(
        order: OrderItemModel(
            id: "GD261031721706",
            customerName: "Test Order",
            phone: "7891234560",
            orderType: "PICKUP",
            isPaid: true,
            dateTime: "Oct 31 at 07:21 AM",
            amount: "$45.61"
        ),
        mode: .inHouse,
        showUpdateStatusModal: true,
        onBack: {}
    )
}

#Preview("New Order Details with Confirm Modal") {
    OrderDetailView(
        order: OrderItemModel(
            id: "GD261031721706",
            customerName: "Test Order",
            phone: "7891234560",
            orderType: "PICKUP",
            isPaid: true,
            dateTime: "Oct 31 at 07:21 AM",
            amount: "$45.61"
        ),
        mode: .new,
        showConfirmModal: true,
        onBack: {}
    )
}
