//
//  DashboardView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject private var session = SessionManager.shared
    var onLogout: (() -> Void)? = nil
    
    @State private var selectedFeature: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showSideMenu: Bool
    @State private var showNotifications: Bool = false
    
    // Screens navigation
    @State private var showOrdersScreen: Bool = false
    @State private var showResetPasswordScreen: Bool = false
    @State private var showSupportScreen: Bool = false
    @State private var showSettingsScreen: Bool = false
    @State private var showReportsScreen: Bool = false
    @State private var showMarketingCouponsScreen: Bool = false
    
    private let darkTextColor = Color(red: 24/255, green: 24/255, blue: 24/255)
    private let iconBlue = Color(red: 66/255, green: 133/255, blue: 244/255)
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    
    init(onLogout: (() -> Void)? = nil, initialShowSideMenu: Bool = false) {
        self.onLogout = onLogout
        _showSideMenu = State(initialValue: initialShowSideMenu)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let drawerWidth = min(max(geometry.size.width * 0.65, 250), 320)
            
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top Wavy Header Banner (stays visible across the top)
                    DashboardHeaderWaveView(
                        isMenuOpen: showSideMenu,
                        onMenuTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showSideMenu.toggle()
                            }
                        },
                        onNotificationTap: {
                            showNotifications = true
                        }
                    )
                    
                    // Main Content Area with Sliding Drawer
                    ZStack(alignment: .leading) {
                        // Dashboard Cards Grid
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                // 1. ORDERS Card
                                DashboardCard(action: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showOrdersScreen = true
                                    }
                                }) {
                                    HStack {
                                        Text("ORDERS")
                                            .font(.system(size: 24, weight: .heavy))
                                            .foregroundStyle(darkTextColor)
                                        
                                        Spacer()
                                        
                                        OrdersDocumentIcon()
                                    }
                                    .padding(.horizontal, 22)
                                    .frame(height: 105)
                                }
                                
                                // 2. SUPPORT & SETTINGS (2-Column Row)
                                HStack(spacing: 16) {
                                    // SUPPORT Card
                                    DashboardCard(action: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            showSupportScreen = true
                                        }
                                    }) {
                                        VStack(spacing: 12) {
                                            Text("SUPPORT")
                                                .font(.system(size: 19, weight: .heavy))
                                                .foregroundStyle(darkTextColor)
                                            
                                            SupportHeadsetIcon()
                                        }
                                        .padding(.vertical, 18)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 125)
                                    }
                                    
                                    // SETTINGS Card
                                    DashboardCard(action: {
                                        withAnimation(.easeInOut(duration: 0.25)) {
                                            showSettingsScreen = true
                                        }
                                    }) {
                                        VStack(spacing: 12) {
                                            Text("SETTINGS")
                                                .font(.system(size: 19, weight: .heavy))
                                                .foregroundStyle(darkTextColor)
                                            
                                            Image(systemName: "gearshape.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 48, height: 48)
                                                .foregroundStyle(iconBlue)
                                        }
                                        .padding(.vertical, 18)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 125)
                                    }
                                }
                                
                                // 3. REPORTS Card
                                DashboardCard(action: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showReportsScreen = true
                                    }
                                }) {
                                    HStack(alignment: .center) {
                                        Text("REPORTS")
                                            .font(.system(size: 24, weight: .heavy))
                                            .foregroundStyle(darkTextColor)
                                        
                                        Spacer()
                                        
                                        ReportsTrendIcon()
                                    }
                                    .padding(.horizontal, 22)
                                    .frame(height: 110)
                                }
                                
                                // 4. MARKETING & COUPONS Card
                                DashboardCard(action: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showMarketingCouponsScreen = true
                                    }
                                }) {
                                    HStack {
                                        Text("MARKETING & COUPONS")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(darkTextColor)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                        
                                        Spacer()
                                        
                                        MarketingCouponsIcon()
                                    }
                                    .padding(.horizontal, 22)
                                    .frame(height: 110)
                                }
                            }
                            .padding(.horizontal, 18)
                            .padding(.top, 20)
                            .padding(.bottom, 32)
                        }
                        .disabled(showSideMenu)
                        
                        // Dimmed Background Scrim
                        if showSideMenu {
                            Color.black.opacity(0.48)
                                .ignoresSafeArea(edges: .bottom)
                                .transition(.opacity)
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSideMenu = false
                                    }
                                }
                            
                            // Left-to-Right Slide-in Drawer Panel
                            SideDrawerPanel(
                                width: drawerWidth,
                                onResetPassword: {
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showSideMenu = false
                                        showResetPasswordScreen = true
                                    }
                                },
                                onLogout: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showSideMenu = false
                                        session.logout()
                                        onLogout?()
                                    }
                                }
                            )
                            .transition(.move(edge: .leading))
                            .gesture(
                                DragGesture()
                                    .onEnded { value in
                                        if value.translation.width < -40 {
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                showSideMenu = false
                                            }
                                        }
                                    }
                            )
                        }
                    }
                }
                
                // Fullscreen Orders Screen Navigation
                if showOrdersScreen {
                    OrdersView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showOrdersScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
                
                // Fullscreen Reset Password Screen Navigation
                if showResetPasswordScreen {
                    ResetPasswordView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showResetPasswordScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
                
                // Fullscreen Support Screen Navigation
                if showSupportScreen {
                    SupportHelpView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showSupportScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
                
                // Fullscreen Settings Screen Navigation
                if showSettingsScreen {
                    SettingsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showSettingsScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
                
                // Fullscreen Reports Screen Navigation
                if showReportsScreen {
                    ReportsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showReportsScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
                
                // Fullscreen Marketing & Coupons Screen Navigation
                if showMarketingCouponsScreen {
                    MarketingCouponsView(onBack: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showMarketingCouponsScreen = false
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .trailing)
                    ))
                    .zIndex(10)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showSideMenu)
        .animation(.easeInOut(duration: 0.25), value: showOrdersScreen)
        .animation(.easeInOut(duration: 0.25), value: showResetPasswordScreen)
        .animation(.easeInOut(duration: 0.25), value: showSupportScreen)
        .animation(.easeInOut(duration: 0.25), value: showSettingsScreen)
        .animation(.easeInOut(duration: 0.25), value: showReportsScreen)
        .animation(.easeInOut(duration: 0.25), value: showMarketingCouponsScreen)
        .alert(selectedFeature, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Notifications", isPresented: $showNotifications) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You have no new notifications.")
        }
    }
    
    private func openFeature(_ name: String) {
        selectedFeature = name
        alertMessage = "\(name) module will connect to the live API."
        showAlert = true
    }
}

// MARK: - Slide Drawer Panel (Store Info, Packages, Links)
struct SideDrawerPanel: View {
    @ObservedObject private var session = SessionManager.shared
    var width: CGFloat
    var onResetPassword: () -> Void
    var onLogout: () -> Void
    
    private let darkTitle = Color(red: 17/255, green: 17/255, blue: 17/255)
    private let bodyText = Color(red: 34/255, green: 34/255, blue: 34/255)
    private let linkBlue = Color(red: 0/255, green: 130/255, blue: 220/255)
    
    var restaurantName: String {
        session.currentRestaurant?.name ?? "Test Store GB Pay Monthly"
    }
    
    var restaurantAddress: String {
        session.currentRestaurant?.address ?? "36 Commerce Way, Woburn, MA 01801"
    }
    
    var deliveryPackage: String {
        let pkg = session.currentRestaurant?.del_pckg ?? "%"
        return "Delivery Orders - \(pkg)"
    }
    
    var pickupPackage: String {
        let pkg = session.currentRestaurant?.pick_pckg ?? "100.00%"
        return "Pickup Orders - \(pkg)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Store Title (Live data from API)
            Text(restaurantName)
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(darkTitle)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 28)
            
            // Store Address (Live data from API)
            Text(restaurantAddress)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(bodyText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
            
            // Your Packages Section
            Text("Your Packages")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(darkTitle)
                .padding(.top, 26)
            
            // Package Details (Live data from API)
            VStack(alignment: .leading, spacing: 8) {
                Text(deliveryPackage)
                Text(pickupPackage)
            }
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(bodyText)
            .padding(.top, 10)
            
            // Reset Password Link
            Button(action: onResetPassword) {
                Text("Reset Password")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(linkBlue)
                    .underline()
            }
            .buttonStyle(.plain)
            .padding(.top, 32)
            
            // LogOut Link
            Button(action: onLogout) {
                Text("LogOut")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(linkBlue)
                    .underline()
            }
            .buttonStyle(.plain)
            .padding(.top, 22)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(width: width, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Dashboard Card Wrapper
struct DashboardCard<Content: View>: View {
    var action: () -> Void
    var content: () -> Content
    
    init(action: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.action = action
        self.content = content
    }
    
    var body: some View {
        Button(action: action) {
            content()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Wavy Top Header Banner
struct DashboardHeaderWaveView: View {
    var isMenuOpen: Bool
    var onMenuTap: () -> Void
    var onNotificationTap: () -> Void
    
    private let navBlue = Color(red: 0/255, green: 130/255, blue: 225/255)
    
    var body: some View {
        ZStack(alignment: .top) {
            // Layer 1: Gray underlay wave
            HeaderGrayWave()
                .fill(Color(white: 0.90))
                .frame(height: 180)
                .offset(y: 8)
            
            // Layer 2: White mid-accent wave
            HeaderWhiteWave()
                .fill(Color.white)
                .frame(height: 180)
                .offset(y: 4)
                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
            
            // Layer 3: Vibrant 3D Red Ribbon
            HeaderRedRibbon()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 232/255, green: 24/255, blue: 34/255),
                            Color(red: 195/255, green: 15/255, blue: 25/255),
                            Color(red: 235/255, green: 40/255, blue: 48/255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 175)
                .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 5)
            
            // Navigation Controls: Hamburger/Back Arrow & Notification Bell
            HStack(alignment: .top) {
                Button(action: onMenuTap) {
                    Group {
                        if isMenuOpen {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 22, weight: .bold))
                        } else {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24, weight: .bold))
                        }
                    }
                    .foregroundStyle(navBlue)
                    .contentTransition(.symbolEffect(.replace))
                    .padding(12)
                }
                
                Spacer()
                
                Button(action: onNotificationTap) {
                    ZStack {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(navBlue)
                        
                        // Radiating sparkle
                        Image(systemName: "sparkle")
                            .font(.system(size: 10))
                            .foregroundStyle(navBlue)
                            .offset(x: 12, y: -8)
                    }
                    .padding(12)
                }
                .offset(y: 50)
            }
            .padding(.horizontal, 12)
            .padding(.top, 40)
        }
        .frame(height: 185)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Wave Curves
struct HeaderRedRibbon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.40))
        
        path.addCurve(
            to: CGPoint(x: rect.width * 0.42, y: rect.height * 0.88),
            control1: CGPoint(x: rect.width * 0.80, y: rect.height * 0.20),
            control2: CGPoint(x: rect.width * 0.65, y: rect.height * 0.92)
        )
        
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.50),
            control1: CGPoint(x: rect.width * 0.22, y: rect.height * 0.86),
            control2: CGPoint(x: 0, y: rect.height * 0.72)
        )
        
        path.closeSubpath()
        return path
    }
}

struct HeaderWhiteWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.50))
        
        path.addCurve(
            to: CGPoint(x: rect.width * 0.46, y: rect.height * 0.93),
            control1: CGPoint(x: rect.width * 0.78, y: rect.height * 0.32),
            control2: CGPoint(x: rect.width * 0.68, y: rect.height * 0.96)
        )
        
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.60),
            control1: CGPoint(x: rect.width * 0.24, y: rect.height * 0.90),
            control2: CGPoint(x: 0, y: rect.height * 0.78)
        )
        
        path.closeSubpath()
        return path
    }
}

struct HeaderGrayWave: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.58))
        
        path.addCurve(
            to: CGPoint(x: rect.width * 0.50, y: rect.height * 0.98),
            control1: CGPoint(x: rect.width * 0.78, y: rect.height * 0.38),
            control2: CGPoint(x: rect.width * 0.70, y: rect.height * 1.0)
        )
        
        path.addCurve(
            to: CGPoint(x: 0, y: rect.height * 0.68),
            control1: CGPoint(x: rect.width * 0.26, y: rect.height * 0.94),
            control2: CGPoint(x: 0, y: rect.height * 0.84)
        )
        
        path.closeSubpath()
        return path
    }
}

// MARK: - Custom Vector Icons

// 1. ORDERS Document Icon
struct OrdersDocumentIcon: View {
    private let iconBlue = Color(red: 66/255, green: 133/255, blue: 244/255)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(iconBlue)
                .frame(width: 48, height: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(0..<3) { _ in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 4, height: 4)
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(Color.white)
                            .frame(width: 22, height: 4)
                    }
                }
            }
        }
        .rotationEffect(.degrees(-8))
    }
}

// 2. SUPPORT Headset Icon
struct SupportHeadsetIcon: View {
    private let iconBlue = Color(red: 66/255, green: 133/255, blue: 244/255)
    
    var body: some View {
        ZStack {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundStyle(iconBlue)
            
            Path { path in
                path.addArc(
                    center: CGPoint(x: 22, y: 15),
                    radius: 12,
                    startAngle: .degrees(185),
                    endAngle: .degrees(0),
                    clockwise: false
                )
                path.addLine(to: CGPoint(x: 34, y: 25))
                path.addLine(to: CGPoint(x: 27, y: 27))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
            .frame(width: 44, height: 44)
            
            Circle()
                .fill(Color.white)
                .frame(width: 4.5, height: 4.5)
                .offset(x: 5, y: 5)
        }
        .frame(width: 48, height: 48)
    }
}

// 3. REPORTS Trend Icon
struct ReportsTrendIcon: View {
    private let iconBlue = Color(red: 66/255, green: 133/255, blue: 244/255)
    private let areaGray = Color(red: 222/255, green: 222/255, blue: 222/255)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Path { path in
                path.move(to: CGPoint(x: 10, y: 58))
                path.addLine(to: CGPoint(x: 10, y: 52))
                path.addLine(to: CGPoint(x: 38, y: 44))
                path.addLine(to: CGPoint(x: 52, y: 54))
                path.addLine(to: CGPoint(x: 90, y: 12))
                path.addLine(to: CGPoint(x: 145, y: 32))
                path.addLine(to: CGPoint(x: 145, y: 58))
                path.closeSubpath()
            }
            .fill(areaGray)
            
            Path { path in
                path.move(to: CGPoint(x: 5, y: 50))
                path.addLine(to: CGPoint(x: 38, y: 40))
                path.addLine(to: CGPoint(x: 52, y: 50))
                path.addLine(to: CGPoint(x: 88, y: 14))
            }
            .stroke(iconBlue, style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round))
            
            Path { path in
                path.move(to: CGPoint(x: 74, y: 12))
                path.addLine(to: CGPoint(x: 92, y: 11))
                path.addLine(to: CGPoint(x: 90, y: 28))
            }
            .stroke(iconBlue, style: StrokeStyle(lineWidth: 5.5, lineCap: .round, lineJoin: .round))
        }
        .frame(width: 150, height: 60)
    }
}

// 4. MARKETING & COUPONS Icon
struct MarketingCouponsIcon: View {
    private let tagBlue = Color(red: 0/255, green: 145/255, blue: 240/255)
    private let tagDark = Color(red: 45/255, green: 45/255, blue: 45/255)
    
    var body: some View {
        ZStack {
            Image(systemName: "tag.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 46)
                .foregroundStyle(tagDark)
                .rotationEffect(.degrees(45))
                .offset(x: 8, y: 6)
            
            ZStack {
                Image(systemName: "tag.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 46, height: 46)
                    .foregroundStyle(tagBlue)
                    .rotationEffect(.degrees(45))
                
                Text("%")
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .offset(x: -3, y: 3)
            }
        }
        .frame(width: 58, height: 58)
    }
}

#Preview("Dashboard View") {
    DashboardView()
}

#Preview("Side Drawer Open") {
    DashboardView(initialShowSideMenu: true)
}
