//
//  OrdersView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

enum OrderTab: String, CaseIterable {
    case new = "NEW"
    case inHouse = "In House"
    case completed = "Completed"
}

enum HeaderSubTab: String {
    case reservations = "RESERVATIONS"
    case eventEnquiry = "EVENT ENQUIRY"
}

// MARK: - Order Item Model
struct OrderItemModel: Identifiable, Sendable {
    var id: String
    var customerName: String
    var phone: String
    var orderType: String // "DELIVERY" or "PICKUP"
    var isPaid: Bool = true
    var dateTime: String // e.g. "May 14, 2026, 07:49 PM"
    var amount: String // e.g. "$53.14"
    var items: String = "1x Chicken Tikka, 2x Garlic Naan"
    var status: String = "Confirmed"
    var hold: String? = nil
}

struct OrdersView: View {
    var onBack: () -> Void
    
    @State private var selectedTab: OrderTab = .new
    @State private var selectedSubTab: HeaderSubTab? = nil
    @State private var isRefreshing: Bool = false
    @State private var refreshAngle: Double = 0
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var selectedOrderDetail: OrderItemModel? = nil
    @State private var showReservationsScreen: Bool = false
    
    // MARK: - Orders Lists
    @State private var newOrders: [OrderItemModel] = []
    @State private var inHouseOrders: [OrderItemModel] = []
    @State private var completedOrders: [OrderItemModel] = []
    
    // MARK: - Loading States
    @State private var isLoadingNew: Bool = false
    @State private var isLoadingInHouse: Bool = false
    @State private var isFetchingCompletedOrders: Bool = false
    
    // MARK: - Month & Year Filters for Completed Orders
    // Month formatted as 3-letter string (e.g. "Oct", "May") as expected by the API
    @State private var selectedMonth: String = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: Date())
    }()
    @State private var selectedYear: String = {
        let calendar = Calendar.current
        return String(calendar.component(.year, from: Date()))
    }()
    
    private func updateToCurrentMonthAndYear() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        self.selectedMonth = formatter.string(from: now)
        let curYear = Calendar.current.component(.year, from: now)
        self.selectedYear = String(curYear)
    }
    
    private let months: [String] = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ]
    
    // "year me current and last year aayega only"
    private var availableYears: [String] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let cur = max(currentYear, 2026)
        return ["\(cur)", "\(cur - 1)"]
    }
    
    private let primaryBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let tabBgGray = Color(red: 242/255, green: 244/255, blue: 246/255)
    private let borderGray = Color(red: 215/255, green: 220/255, blue: 225/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let subtitleGray = Color(red: 120/255, green: 120/255, blue: 120/255)
    private let filterBorderOrange = Color(red: 245/255, green: 145/255, blue: 35/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section with Back Button, Red Wave Crest, and Refresh Action
            ZStack(alignment: .top) {
                // Top Right Red Wave Graphic
                HStack {
                    Spacer()
                    OrdersWaveCrest()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 232/255, green: 24/255, blue: 34/255),
                                    Color(red: 195/255, green: 15/255, blue: 25/255)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 78)
                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                }
                .ignoresSafeArea(edges: .top)
                
                // Back Button (Blue Square Box with White Curved Arrow)
                HStack(alignment: .top) {
                    Button(action: onBack) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(primaryBlue)
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 16)
                    .padding(.top, 14)
                    
                    Spacer()
                }
                
                // Refresh Action Button (Blue circle with white circular arrow)
                HStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.6)) {
                            refreshAngle += 360
                            isRefreshing = true
                        }
                        // Refresh both New Orders (GetNewOrder) and In-House Orders (GetActiveOrder)
                        fetchNewOrdersFromAPI(silent: true)
                        fetchInHouseOrdersFromAPI(silent: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                isRefreshing = false
                            }
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(primaryBlue)
                                .frame(width: 52, height: 52)
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundStyle(.white)
                                .rotationEffect(.degrees(refreshAngle))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 22)
                    .padding(.top, 48)
                }
            }
            .frame(height: 105)
            
            // Sub-tabs: RESERVATIONS & EVENT ENQUIRY
            HStack(spacing: 0) {
                // RESERVATIONS Button -> Navigates to ReservationsView
                Button {
                    showReservationsScreen = true
                } label: {
                    Text("RESERVATIONS")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(tabBgGray)
                        .overlay(
                            Rectangle()
                                .stroke(borderGray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                
                // EVENT ENQUIRY Button
                Button {
                    selectedSubTab = .eventEnquiry
                    alertTitle = "Event Enquiry"
                    alertMessage = "Loading catering and event inquiries..."
                    showAlert = true
                } label: {
                    Text("EVENT ENQUIRY")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(primaryBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(tabBgGray)
                        .overlay(
                            Rectangle()
                                .stroke(borderGray, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 4)
            
            // Order Status Segment Tabs (NEW, In House, Completed)
            HStack(spacing: 0) {
                ForEach(OrderTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                        switch tab {
                        case .new:
                            if newOrders.isEmpty { fetchNewOrdersFromAPI(silent: true) }
                        case .inHouse:
                            if inHouseOrders.isEmpty { fetchInHouseOrdersFromAPI(silent: true) }
                        case .completed:
                            updateToCurrentMonthAndYear()
                            fetchCompletedOrdersFromAPI(silent: true)
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(selectedTab == tab ? .white : primaryBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(selectedTab == tab ? primaryBlue : tabBgGray)
                    }
                    .buttonStyle(.plain)
                    
                    if tab != OrderTab.allCases.last {
                        Rectangle()
                            .fill(borderGray)
                            .frame(width: 1, height: 44)
                    }
                }
            }
            .overlay(
                Rectangle()
                    .stroke(borderGray, lineWidth: 1)
            )
            
            // Content Area based on selected tab
            ZStack {
                Color.white.ignoresSafeArea()
                
                switch selectedTab {
                case .new:
                    newOrdersContentView
                    
                case .inHouse:
                    inHouseOrdersContentView
                    
                case .completed:
                    completedOrdersView
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            fetchNewOrdersFromAPI(silent: true)
            fetchInHouseOrdersFromAPI(silent: true)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .fullScreenCover(item: $selectedOrderDetail) { order in
            OrderDetailView(
                order: order,
                mode: selectedTab,
                onBack: {
                    selectedOrderDetail = nil
                },
                onOrderUpdated: {
                    selectedOrderDetail = nil
                    fetchNewOrdersFromAPI(silent: true)
                    fetchInHouseOrdersFromAPI(silent: true)
                    fetchCompletedOrdersFromAPI(silent: true)
                }
            )
        }
        .fullScreenCover(isPresented: $showReservationsScreen) {
            ReservationsView(onBack: {
                showReservationsScreen = false
            })
        }
    }
    
    // MARK: - NEW Orders Content View
    private var newOrdersContentView: some View {
        Group {
            if isLoadingNew && newOrders.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Fetching new orders...")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
            } else if newOrders.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        Spacer()
                            .frame(height: 120)
                        
                        Text("You don't have any new orders right now.")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(darkTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Text("Upcoming new orders will show up here before becoming complete.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(subtitleGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                            .frame(height: 80)
                        
                        Rectangle()
                            .fill(Color(white: 0.88))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                }
                .refreshable {
                    fetchNewOrdersFromAPI(silent: true)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(newOrders) { order in
                            OrderCardView(order: order) {
                                selectedOrderDetail = order
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    fetchNewOrdersFromAPI(silent: true)
                }
            }
        }
    }
    
    // MARK: - In House Orders Content View
    private var inHouseOrdersContentView: some View {
        Group {
            if isLoadingInHouse && inHouseOrders.isEmpty {
                VStack {
                    Spacer()
                    ProgressView("Fetching in-house orders...")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.gray)
                    Spacer()
                }
            } else if inHouseOrders.isEmpty {
                ScrollView {
                    VStack(spacing: 12) {
                        Spacer()
                            .frame(height: 120)
                        
                        Text("You don't have any in-house orders right now.")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(darkTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Text("Active in-house orders currently being prepared will show up here.")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundStyle(subtitleGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Spacer()
                            .frame(height: 80)
                        
                        Rectangle()
                            .fill(Color(white: 0.88))
                            .frame(height: 1)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                }
                .refreshable {
                    fetchInHouseOrdersFromAPI(silent: true)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(inHouseOrders) { order in
                            OrderCardView(order: order) {
                                selectedOrderDetail = order
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .refreshable {
                    fetchInHouseOrdersFromAPI(silent: true)
                }
            }
        }
    }
    
    // MARK: - Completed Orders View with Month/Year Dropdown & Sticky Bottom Button
    private var completedOrdersView: some View {
        VStack(spacing: 0) {
            // Dropdown Selectors Row: MONTH and YEAR
            HStack(spacing: 12) {
                // Month Dropdown Card
                Menu {
                    ForEach(months, id: \.self) { month in
                        Button(month) {
                            selectedMonth = month
                        }
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text("MONTH")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                        
                        HStack(spacing: 8) {
                            Text(selectedMonth)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(darkTextColor)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 90/255, green: 90/255, blue: 90/255))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(filterBorderOrange, lineWidth: 1.5)
                    )
                }
                
                // Year Dropdown Card (current and last year only)
                Menu {
                    ForEach(availableYears, id: \.self) { year in
                        Button(year) {
                            selectedYear = year
                        }
                    }
                } label: {
                    VStack(spacing: 3) {
                        Text("YEAR")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                        
                        HStack(spacing: 8) {
                            Text(selectedYear)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(darkTextColor)
                            
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 90/255, green: 90/255, blue: 90/255))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(filterBorderOrange, lineWidth: 1.5)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 12)
            
            // Scrollable List of Completed Orders
            ScrollView(showsIndicators: false) {
                if isFetchingCompletedOrders && completedOrders.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                            .frame(height: 80)
                        
                        ProgressView("Loading completed orders...")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.gray)
                    }
                    .frame(maxWidth: .infinity)
                } else if completedOrders.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                            .frame(height: 80)
                        
                        Text("No completed orders found for \(selectedMonth) \(selectedYear).")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(subtitleGray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                        
                        Text("Tap 'GET ORDERS' below to fetch records from server.")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 16) {
                        ForEach(completedOrders) { order in
                            OrderCardView(order: order) {
                                selectedOrderDetail = order
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
            
            // Sticky Bottom "GET ORDERS" Red Button
            Button {
                fetchCompletedOrdersFromAPI(silent: false)
            } label: {
                HStack(spacing: 10) {
                    if isFetchingCompletedOrders {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    Text(isFetchingCompletedOrders ? "LOADING ORDERS..." : "GET ORDERS")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(brandRed)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isFetchingCompletedOrders)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: -2))
        }
    }
    
    // MARK: - Refresh Helper
    private func refreshCurrentTab() {
        switch selectedTab {
        case .new:
            fetchNewOrdersFromAPI(silent: false)
        case .inHouse:
            fetchInHouseOrdersFromAPI(silent: false)
        case .completed:
            fetchCompletedOrdersFromAPI(silent: false)
        }
    }
    
    // MARK: - API Action: Fetch New Orders (GetNewOrder)
    private func fetchNewOrdersFromAPI(silent: Bool = false) {
        isLoadingNew = true
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchNewOrders(
                    restaurantId: restaurantId,
                    token: token
                )
                await MainActor.run {
                    self.isLoadingNew = false
                    if let orders = response.data {
                        self.newOrders = self.mapApiOrders(orders)
                    } else {
                        self.newOrders = []
                    }
                    if !silent {
                        let count = self.newOrders.count
                        self.alertTitle = "New Orders Synced"
                        self.alertMessage = count > 0 ? "Fetched \(count) new orders." : "No new orders right now."
                        self.showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingNew = false
                    if !silent {
                        self.alertTitle = "New Orders Failed"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - API Action: Fetch In House Orders (GetActiveOrder)
    private func fetchInHouseOrdersFromAPI(silent: Bool = false) {
        isLoadingInHouse = true
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchInHouseOrders(
                    restaurantId: restaurantId,
                    token: token
                )
                await MainActor.run {
                    self.isLoadingInHouse = false
                    if let orders = response.data {
                        self.inHouseOrders = self.mapApiOrders(orders)
                    } else {
                        self.inHouseOrders = []
                    }
                    if !silent {
                        let count = self.inHouseOrders.count
                        self.alertTitle = "In-House Orders Synced"
                        self.alertMessage = count > 0 ? "Fetched \(count) active in-house orders." : "No active in-house orders right now."
                        self.showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingInHouse = false
                    if !silent {
                        self.alertTitle = "In-House Orders Failed"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - API Action: Fetch Completed Orders (GetAllOrder)
    private func fetchCompletedOrdersFromAPI(silent: Bool = false) {
        isFetchingCompletedOrders = true
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let response = try await NetworkManager.shared.fetchCompletedOrders(
                    restaurantId: restaurantId,
                    token: token,
                    month: selectedMonth,
                    year: selectedYear
                )
                await MainActor.run {
                    self.isFetchingCompletedOrders = false
                    if let apiOrders = response.data {
                        self.completedOrders = self.mapApiOrders(apiOrders)
                    } else {
                        self.completedOrders = []
                    }
                    if !silent {
                        if !self.completedOrders.isEmpty {
                            self.alertTitle = "Orders Loaded"
                            self.alertMessage = "Loaded \(self.completedOrders.count) orders for \(selectedMonth) \(selectedYear)."
                            self.showAlert = true
                        } else {
                            let msg = response.result ?? "No orders found for \(selectedMonth) \(selectedYear)."
                            self.alertTitle = "Orders Status"
                            self.alertMessage = msg
                            self.showAlert = true
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isFetchingCompletedOrders = false
                    if !silent {
                        self.alertTitle = "Network Error"
                        self.alertMessage = error.localizedDescription
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    // MARK: - Model Mapper
    private func mapApiOrders(_ apiOrders: [ApiOrderItem]) -> [OrderItemModel] {
        return apiOrders.map { item in
            let amountStr = item.payment?.formattedString ?? "$0.00"
            let typeStr = (item.type?.uppercased().contains("PICKUP") == true) ? "PICKUP" : "DELIVERY"
            let isPaid = (item.paybycard?.lowercased() == "yes" || item.status?.lowercased() == "confirmed")
            return OrderItemModel(
                id: item.id ?? item.orderid ?? UUID().uuidString,
                customerName: item.name ?? "Customer",
                phone: item.mobile ?? "",
                orderType: typeStr,
                isPaid: isPaid,
                dateTime: item.date2 ?? item.date ?? "N/A",
                amount: amountStr,
                items: "Order Items",
                status: item.status ?? "Confirmed",
                hold: item.hold
            )
        }
    }
}

// MARK: - Order Card View (Exact Match to Provided Screenshot)
struct OrderCardView: View {
    var order: OrderItemModel
    var onViewDetails: () -> Void
    
    // Theme colors extracted directly from design
    private let paidGreen = Color(red: 34/255, green: 145/255, blue: 50/255)
    private let dateBlue = Color(red: 25/255, green: 118/255, blue: 210/255)
    private let topBarGray = Color(red: 228/255, green: 230/255, blue: 232/255)
    private let darkNavy = Color(red: 45/255, green: 56/255, blue: 86/255)
    private let buttonBlue = Color(red: 0/255, green: 130/255, blue: 235/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. Top Header Bar (Light Gray with DELIVERY/PICKUP PAID and Date)
            HStack {
                Text("\(order.orderType.uppercased()) \(order.isPaid ? "PAID" : "UNPAID")")
                    .font(.system(size: 17, weight: .heavy))
                    .foregroundStyle(paidGreen)
                
                Spacer()
                
                Text(order.dateTime)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(dateBlue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(topBarGray)
            
            // 2. Dark Navy Body Section
            VStack(spacing: 16) {
                HStack(alignment: .top) {
                    // Left Column: Customer Name & Phone
                    VStack(alignment: .leading, spacing: 5) {
                        Text(order.customerName)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        
                        Text(order.phone)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white.opacity(0.95))
                    }
                    
                    Spacer()
                    
                    // Right Column: Order Amount
                    Text(order.amount)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                // View Details Action Button
                Button(action: onViewDetails) {
                    Text("View Details")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(buttonBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 18)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 16)
            .background(darkNavy)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 3)
    }
}

// MARK: - Wave Crest Shape for Top Right
struct OrdersWaveCrest: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.9))
        
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.1),
            control1: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95),
            control2: CGPoint(x: rect.width * 0.2, y: rect.height * 0.4)
        )
        
        path.closeSubpath()
        return path
    }
}

#Preview("Orders Screen") {
    OrdersView(onBack: {})
}
