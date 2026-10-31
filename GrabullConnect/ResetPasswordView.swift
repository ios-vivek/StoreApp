//
//  ResetPasswordView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct ResetPasswordView: View {
    var onBack: () -> Void
    
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let backgroundColor = Color(red: 238/255, green: 238/255, blue: 238/255)
    private let placeholderColor = Color(red: 40/255, green: 40/255, blue: 40/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack(spacing: 18) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(brandRed)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                
                Text("RESET PASSWORD")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(brandRed)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 14)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(Color(red: 220/255, green: 220/255, blue: 220/255))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Body Content
            ScrollView {
                VStack(spacing: 16) {
                    // 1. New Password Field (White card with centered placeholder)
                    ZStack {
                        if newPassword.isEmpty {
                            Text("New Password")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(placeholderColor)
                        }
                        SecureField("", text: $newPassword)
                            .font(.system(size: 17))
                            .foregroundStyle(Color.black)
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1.5)
                    
                    // 2. Confirm Password Field (White card with centered placeholder)
                    ZStack {
                        if confirmPassword.isEmpty {
                            Text("Confirm Password")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundStyle(placeholderColor)
                        }
                        SecureField("", text: $confirmPassword)
                            .font(.system(size: 17))
                            .foregroundStyle(Color.black)
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1.5)
                    
                    // 3. SUBMIT Button (Pill Capsule with white border)
                    Button(action: handleSubmit) {
                        Text("SUBMIT")
                            .font(.system(size: 17, weight: .heavy))
                            .tracking(0.5)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(brandRed)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.9), lineWidth: 1.8)
                            )
                            .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(backgroundColor.ignoresSafeArea())
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertTitle == "Success" {
                    onBack()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func handleSubmit() {
        if newPassword.isEmpty {
            alertTitle = "Required"
            alertMessage = "Please enter your new password."
            showAlert = true
            return
        }
        
        if confirmPassword.isEmpty {
            alertTitle = "Required"
            alertMessage = "Please confirm your new password."
            showAlert = true
            return
        }
        
        if newPassword != confirmPassword {
            alertTitle = "Mismatch"
            alertMessage = "New password and Confirm password do not match."
            showAlert = true
            return
        }
        
        alertTitle = "Success"
        alertMessage = "Your password has been successfully reset."
        showAlert = true
    }
}

#Preview("Reset Password Screen") {
    ResetPasswordView(onBack: {})
}
