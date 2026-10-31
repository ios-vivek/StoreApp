//
//  ReservationsView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

enum ReservationTab: String, CaseIterable {
    case today = "Today"
    case pending = "Pending"
    case search = "Search"
}

// MARK: - Reservation Item Model
struct ReservationItemModel: Identifiable, Sendable {
    var id: String
    var dateString: String // "Sep 29, 2026"
    var timeString: String // "02:30PM"
    var guestCount: Int // 2
    var customerName: String // "kumar mk"
    var phone: String // "9598880988"
    var status: String = "Pending"
}

struct ReservationsView: View {
    var onBack: () -> Void
    
    @State private var selectedTab: ReservationTab = .pending
    @State private var selectedMonth: String = "Sep"
    @State private var selectedYear: String = "2026"
    @State private var searchQuery: String = ""
    @State private var isLoading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    @State private var selectedReservation: ReservationItemModel? = nil
    
    // 3-Letter Months
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
    
    // Sample Pending Reservations matching the user screenshot
    @State private var pendingReservations: [ReservationItemModel] = [
        ReservationItemModel(
            id: "r1",
            dateString: "Sep 29, 2026",
            timeString: "02:30PM",
            guestCount: 2,
            customerName: "kumar mk",
            phone: "9598880988"
        ),
        ReservationItemModel(
            id: "r2",
            dateString: "Sep 30, 2026",
            timeString: "07:00PM",
            guestCount: 4,
            customerName: "David Miller",
            phone: "5087654321"
        )
    ]
    
    // Sample Today Reservations
    @State private var todayReservations: [ReservationItemModel] = [
        ReservationItemModel(
            id: "r3",
            dateString: "Today",
            timeString: "08:00PM",
            guestCount: 6,
            customerName: "Alex Brown",
            phone: "6175550143",
            status: "Confirmed"
        )
    ]
    
    // Colors matching Grabull Connect theme
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let primaryBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    private let tabBgGray = Color(red: 242/255, green: 244/255, blue: 246/255)
    private let borderGray = Color(red: 215/255, green: 220/255, blue: 225/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let filterBorderOrange = Color(red: 245/255, green: 145/255, blue: 35/255)
    private let cellBgGray = Color(red: 235/255, green: 237/255, blue: 240/255)
    private let iconOrange = Color(red: 255/255, green: 140/255, blue: 0/255)
    private let chevronBlue = Color(red: 0/255, green: 150/255, blue: 255/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar with < BACK and RESERVATIONS title
            ZStack {
                // Centered Title
                Text("RESERVATIONS")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(darkTextColor)
                
                // Back Button on Leading edge
                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 19, weight: .bold))
                            
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
            .padding(.bottom, 12)
            
            // Thin divider below header
            Rectangle()
                .fill(Color(white: 0.88))
                .frame(height: 1)
            
            // Segment Tabs: Today | Pending | Search
            HStack(spacing: 0) {
                ForEach(ReservationTab.allCases, id: \.self) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
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
                    
                    if tab != ReservationTab.allCases.last {
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
                case .pending:
                    pendingContentView
                    
                case .today:
                    todayContentView
                    
                case .search:
                    searchContentView
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .sheet(item: $selectedReservation) { item in
            ReservationDetailSheet(reservation: item)
        }
    }
    
    // MARK: - Pending Tab (with Month & Year Dropdown and GET RESERVATION Button)
    private var pendingContentView: some View {
        VStack(spacing: 0) {
            // "and pending tab me hi month and year ka option rahega"
            HStack(spacing: 14) {
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
            
            // List of Pending Reservations
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(pendingReservations) { item in
                        ReservationRowView(reservation: item) {
                            selectedReservation = item
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
            }
            
            // Bottom Sticky "GET RESERVATION" Button
            Button {
                fetchReservationsFromAPI()
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    
                    Text(isLoading ? "LOADING RESERVATIONS..." : "GET RESERVATION")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(brandRed)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .disabled(isLoading)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.white.shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: -2))
        }
    }
    
    // MARK: - Today Tab
    private var todayContentView: some View {
        VStack(spacing: 0) {
            if todayReservations.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.gray)
                    Text("No reservations scheduled for today.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.secondary)
                    Spacer()
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(todayReservations) { item in
                            ReservationRowView(reservation: item) {
                                selectedReservation = item
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
    // MARK: - Search Tab
    private var searchContentView: some View {
        VStack(spacing: 14) {
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                
                TextField("Search by name or phone...", text: $searchQuery)
                    .font(.system(size: 16))
                    .autocorrectionDisabled(true)
                
                if !searchQuery.isEmpty {
                    Button {
                        searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(white: 0.94))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.top, 14)
            
            // Search Results
            let filtered = pendingReservations + todayReservations
            let results = searchQuery.isEmpty ? filtered : filtered.filter {
                $0.customerName.localizedCaseInsensitiveContains(searchQuery) ||
                $0.phone.contains(searchQuery)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(results) { item in
                        ReservationRowView(reservation: item) {
                            selectedReservation = item
                        }
                    }
                }
                .padding(.bottom, 16)
            }
        }
    }
    
    // MARK: - API Action
    private func fetchReservationsFromAPI() {
        isLoading = true
        
        let restaurant = SessionManager.shared.currentRestaurant
        let restaurantId = restaurant?.restaurant_id ?? "240701164800373"
        let token = restaurant?.token ?? SessionManager.shared.defaultDeviceToken
        
        Task {
            do {
                let endpoint = "\(Constant.GD_URL)\(Constant.SERVICE_API.COMMON_URL)"
                guard let url = URL(string: endpoint) else { throw NetworkError.invalidURL }
                
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                
                let body: [String: Any] = [
                    "api_id": Constant.WEBSERVICE.API_ID,
                    "api_key": Constant.WEBSERVICE.API_KEY,
                    "service_type": Constant.SERVICE_TYPE.GET_RESERVATION,
                    "restaurant_id": restaurantId,
                    "month": selectedMonth,
                    "year": selectedYear,
                    "token": token
                ]
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw NetworkError.serverError(statusCode: 500, message: "Server error")
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    let resultMsg = json["result"] as? String ?? "Reservations loaded."
                    await MainActor.run {
                        self.isLoading = false
                        self.alertTitle = "Reservations Status"
                        self.alertMessage = resultMsg
                        self.showAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.alertTitle = "Network Error"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

// MARK: - Reservation Row View (Exact Match to User Screenshot)
struct ReservationRowView: View {
    var reservation: ReservationItemModel
    var onTap: () -> Void
    
    private let primaryBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    private let cellBg = Color(red: 238/255, green: 240/255, blue: 242/255)
    private let iconOrange = Color(red: 255/255, green: 140/255, blue: 0/255)
    private let chevronBlue = Color(red: 0/255, green: 155/255, blue: 245/255)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 0) {
                // 1. Black Box: Date and Time
                VStack(spacing: 2) {
                    Text(reservation.dateString)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text("at \(reservation.timeString)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .lineLimit(1)
                }
                .frame(width: 100, height: 56)
                .background(Color.black)
                
                // 2. Bright Blue Box: Guest / Party Count
                VStack {
                    Text("\(reservation.guestCount)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 48, height: 56)
                .background(primaryBlue)
                
                // 3. Customer Info (Name and Phone)
                VStack(alignment: .leading, spacing: 3) {
                    Text(reservation.customerName)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color(red: 20/255, green: 20/255, blue: 20/255))
                        .lineLimit(1)
                    
                    Text(reservation.phone)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(primaryBlue)
                        .lineLimit(1)
                }
                .padding(.leading, 14)
                
                Spacer()
                
                // 4. Action Icons: Orange Clock History & Light Blue Double Chevron
                HStack(spacing: 12) {
                    // Clock circle history icon
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(iconOrange)
                    
                    // Double chevron icon
                    Image(systemName: "chevron.right.2")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(chevronBlue)
                }
                .padding(.trailing, 14)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(cellBg)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Reservation Detail Sheet
struct ReservationDetailSheet: View {
    var reservation: ReservationItemModel
    @Environment(\.dismiss) private var dismiss
    
    private let primaryBlue = Color(red: 0/255, green: 130/255, blue: 230/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Header badge
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(reservation.customerName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(darkTextColor)
                        
                        Text(reservation.phone)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(primaryBlue)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("\(reservation.guestCount)")
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(.white)
                        Text("GUESTS")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    .frame(width: 64, height: 56)
                    .background(primaryBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding()
                .background(Color(white: 0.96))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
                // Reservation Schedule
                VStack(alignment: .leading, spacing: 10) {
                    Text("Schedule")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(darkTextColor)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(primaryBlue)
                        Text("Date: \(reservation.dateString)")
                            .font(.system(size: 15))
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(primaryBlue)
                        Text("Time: \(reservation.timeString)")
                            .font(.system(size: 15))
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(primaryBlue)
                        Text("Status: \(reservation.status)")
                            .font(.system(size: 15))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reservation Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(primaryBlue)
                }
            }
        }
    }
}

#Preview("Reservations Pending Screen") {
    ReservationsView(onBack: {})
}
