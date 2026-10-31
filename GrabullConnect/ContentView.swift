//
//  ContentView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var session = SessionManager.shared
    
    // Navigation States
    @State private var hasSelectedRestaurant: Bool
    @State private var isLoggedIn: Bool
    @State private var showRequestSignUpScreen: Bool = false
    
    // Login Form State
    @State private var username: String
    @State private var password: String
    @State private var isPasswordVisible: Bool = false
    @State private var rememberMe: Bool
    @State private var isLoggingIn: Bool = false
    
    // Forgot Password Dialog State
    @State private var showForgotPasswordDialog: Bool
    @State private var userId: String = ""
    
    // Alert State
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // Grabull Theme Colors
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let linkBlue = Color(red: 0/255, green: 130/255, blue: 200/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let subtitleColor = Color(red: 60/255, green: 60/255, blue: 60/255)
    private let inputLineColor = Color(red: 160/255, green: 160/255, blue: 160/255)
    private let placeholderColor = Color(red: 90/255, green: 90/255, blue: 90/255)
    private let iconColor = Color(red: 110/255, green: 110/255, blue: 110/255)
    private let watermarkColor = Color(red: 225/255, green: 225/255, blue: 225/255)
    
    init(
        hasSelectedRestaurant: Bool? = nil,
        showForgotPasswordDialog: Bool = false,
        isLoggedIn: Bool? = nil,
        showRequestSignUpScreen: Bool = false
    ) {
        let initialLoggedIn = isLoggedIn ?? SessionManager.shared.isLoggedIn
        let initialSelected = hasSelectedRestaurant ?? initialLoggedIn
        
        _hasSelectedRestaurant = State(initialValue: initialSelected)
        _isLoggedIn = State(initialValue: initialLoggedIn)
        _showForgotPasswordDialog = State(initialValue: showForgotPasswordDialog)
        _showRequestSignUpScreen = State(initialValue: showRequestSignUpScreen)
        
        // Populate saved username/password or provide active test defaults
        let savedUser = SessionManager.shared.savedUsername
        let savedPass = SessionManager.shared.savedPassword
        _username = State(initialValue: savedUser.isEmpty ? "testgbpm@gb.com" : savedUser)
        _password = State(initialValue: savedPass.isEmpty ? "123456" : savedPass)
        _rememberMe = State(initialValue: SessionManager.shared.rememberMe)
    }
    
    var body: some View {
        ZStack {
            if session.isLoggedIn || isLoggedIn {
                // Logged in Merchant Dashboard
                DashboardView(onLogout: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isLoggedIn = false
                        hasSelectedRestaurant = false
                        session.logout()
                    }
                })
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.98)),
                    removal: .opacity
                ))
            } else if !hasSelectedRestaurant {
                // Initial Splash / Landing Screen with RESTAURANT button
                RestaurantSelectLandingView(onSelectRestaurant: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasSelectedRestaurant = true
                    }
                })
                .transition(.asymmetric(
                    insertion: .opacity,
                    removal: .opacity.combined(with: .scale(scale: 0.98))
                ))
            } else {
                // Merchant Sign In / Login Screen
                loginScreen
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            }
            
            // Fullscreen Request Sign Up Web View
            if showRequestSignUpScreen {
                RequestSignUpWebView(onBack: {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showRequestSignUpScreen = false
                    }
                })
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .move(edge: .trailing)
                ))
                .zIndex(20)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: hasSelectedRestaurant)
        .animation(.easeInOut(duration: 0.3), value: isLoggedIn || session.isLoggedIn)
        .animation(.easeInOut(duration: 0.25), value: showRequestSignUpScreen)
        .onAppear {
            // Auto Login Check on launch
            if session.isLoggedIn {
                isLoggedIn = true
                hasSelectedRestaurant = true
            }
        }
    }
    
    // MARK: - Login Screen
    private var loginScreen: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top Bar with Back Arrow to return to Restaurant Landing
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                hasSelectedRestaurant = false
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundStyle(brandRed)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Top Logo & Subtitle Section
                    VStack(spacing: 14) {
                        Image("GrabullLogo")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(brandRed)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 85)
                        
                        Text("View Orders & Admin Account")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(subtitleColor)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 36)
                    
                    // Form Container
                    VStack(alignment: .leading, spacing: 24) {
                        // Header: Login & Forgot Password
                        HStack(alignment: .firstTextBaseline) {
                            Text("Login")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(darkTextColor)
                            
                            Spacer()
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showForgotPasswordDialog = true
                                }
                            } label: {
                                Text("Forgot Password")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(linkBlue)
                                    .underline()
                            }
                        }
                        .padding(.bottom, 6)
                        
                        // Username Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                ZStack(alignment: .leading) {
                                    if username.isEmpty {
                                        Text("Username")
                                            .font(.system(size: 17))
                                            .foregroundStyle(placeholderColor)
                                    }
                                    TextField("", text: $username)
                                        .font(.system(size: 17))
                                        .foregroundStyle(darkTextColor)
                                        .autocorrectionDisabled(true)
                                        .textInputAutocapitalization(.never)
                                }
                                
                                Image(systemName: "person")
                                    .font(.system(size: 17))
                                    .foregroundStyle(iconColor)
                            }
                            .padding(.vertical, 4)
                            
                            Rectangle()
                                .fill(inputLineColor)
                                .frame(height: 1)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                ZStack(alignment: .leading) {
                                    if password.isEmpty {
                                        Text("Password")
                                            .font(.system(size: 17))
                                            .foregroundStyle(placeholderColor)
                                    }
                                    if isPasswordVisible {
                                        TextField("", text: $password)
                                            .font(.system(size: 17))
                                            .foregroundStyle(darkTextColor)
                                            .autocorrectionDisabled(true)
                                            .textInputAutocapitalization(.never)
                                    } else {
                                        SecureField("", text: $password)
                                            .font(.system(size: 17))
                                            .foregroundStyle(darkTextColor)
                                    }
                                }
                                
                                Button {
                                    isPasswordVisible.toggle()
                                } label: {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .font(.system(size: 16))
                                        .foregroundStyle(iconColor)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                            
                            Rectangle()
                                .fill(inputLineColor)
                                .frame(height: 1)
                        }
                        
                        // Remember Me Checkbox (Auto Login)
                        Button {
                            rememberMe.toggle()
                        } label: {
                            HStack(spacing: 10) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(brandRed, lineWidth: 1.5)
                                        .frame(width: 18, height: 18)
                                    
                                    if rememberMe {
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(brandRed)
                                            .frame(width: 18, height: 18)
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                
                                Text("Remember Me (Auto Login)")
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(darkTextColor)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 2)
                        
                        // GET ORDERS Button with Live API Integration & Loading Spinner
                        Button {
                            handleGetOrders()
                        } label: {
                            HStack(spacing: 10) {
                                if isLoggingIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                }
                                
                                Text(isLoggingIn ? "LOGGING IN..." : "GET ORDERS")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(brandRed)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .disabled(isLoggingIn)
                        .opacity(isLoggingIn ? 0.85 : 1.0)
                        .padding(.top, 14)
                    }
                    .padding(.horizontal, 28)
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Full-width Red Separator Line
                    Rectangle()
                        .fill(brandRed)
                        .frame(height: 1.5)
                    
                    // Bottom Watermark Section with Request Signup Link
                    HStack(spacing: 12) {
                        Text("?")
                            .font(.system(size: 38, weight: .heavy))
                            .foregroundStyle(watermarkColor)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("New to Grabull")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color(red: 100/255, green: 100/255, blue: 100/255))
                            
                            Button {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showRequestSignUpScreen = true
                                }
                            } label: {
                                Text("Request Signup")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(linkBlue)
                                    .underline()
                            }
                        }
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 36)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.white.ignoresSafeArea())
            
            // Dimmed Scrim and Forgot Password Modal Dialog
            if showForgotPasswordDialog {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showForgotPasswordDialog = false
                        }
                    }
                
                forgotPasswordDialog
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Forgot Password Dialog View
    private var forgotPasswordDialog: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("GB RESTAURANT")
                .font(.system(size: 19, weight: .bold))
                .foregroundStyle(darkTextColor)
                .padding(.top, 24)
                .padding(.horizontal, 24)
            
            Text("Forgot Password")
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(subtitleColor)
                .padding(.top, 6)
                .padding(.horizontal, 24)
            
            // User ID Input Field
            VStack(alignment: .leading, spacing: 6) {
                ZStack(alignment: .leading) {
                    if userId.isEmpty {
                        Text("User ID")
                            .font(.system(size: 16))
                            .foregroundStyle(placeholderColor)
                    }
                    TextField("", text: $userId)
                        .font(.system(size: 16))
                        .foregroundStyle(darkTextColor)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                .padding(.vertical, 4)
                
                Rectangle()
                    .fill(inputLineColor)
                    .frame(height: 1)
            }
            .padding(.top, 20)
            .padding(.horizontal, 24)
            
            // CANCEL & OK Buttons
            HStack(spacing: 20) {
                Spacer()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showForgotPasswordDialog = false
                        userId = ""
                    }
                } label: {
                    Text("CANCEL")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(brandRed)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(.plain)
                
                Button {
                    let enteredId = userId.trimmingCharacters(in: .whitespacesAndNewlines)
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showForgotPasswordDialog = false
                    }
                    if enteredId.isEmpty {
                        alertTitle = "Error"
                        alertMessage = "Please enter a valid User ID."
                    } else {
                        alertTitle = "Success"
                        alertMessage = "Password reset instructions sent for User ID: \(enteredId)."
                    }
                    showAlert = true
                    userId = ""
                } label: {
                    Text("OK")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(brandRed)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 22)
            .padding(.trailing, 16)
            .padding(.bottom, 18)
        }
        .frame(maxWidth: 320)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Handlers
    private func handleGetOrders() {
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanUsername.isEmpty else {
            alertTitle = "Required"
            alertMessage = "Please enter your Username."
            showAlert = true
            return
        }
        
        guard !cleanPassword.isEmpty else {
            alertTitle = "Required"
            alertMessage = "Please enter your Password."
            showAlert = true
            return
        }
        
        isLoggingIn = true
        
        Task {
            do {
                try await session.login(username: cleanUsername, password: cleanPassword, remember: rememberMe)
                await MainActor.run {
                    self.isLoggingIn = false
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.isLoggedIn = true
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoggingIn = false
                    self.alertTitle = "Login Failed"
                    self.alertMessage = error.localizedDescription
                    self.showAlert = true
                }
            }
        }
    }
}

#Preview("Restaurant Landing") {
    ContentView(hasSelectedRestaurant: false, isLoggedIn: false)
}

#Preview("Login Screen") {
    ContentView(hasSelectedRestaurant: true, isLoggedIn: false)
}

#Preview("Request Sign Up") {
    ContentView(hasSelectedRestaurant: true, isLoggedIn: false, showRequestSignUpScreen: true)
}

#Preview("Forgot Password Modal") {
    ContentView(hasSelectedRestaurant: true, showForgotPasswordDialog: true, isLoggedIn: false)
}
