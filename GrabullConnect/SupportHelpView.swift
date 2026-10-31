//
//  SupportHelpView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct SupportHelpView: View {
    var onBack: () -> Void
    
    @State private var selectedTopic: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let darkTextColor = Color(red: 25/255, green: 25/255, blue: 25/255)
    private let dividerColor = Color(red: 215/255, green: 215/255, blue: 215/255)
    private let chevronColor = Color(red: 80/255, green: 80/255, blue: 80/255)
    
    // Help Topics matching screenshot
    private let helpTopics = [
        "Help With adding Tips",
        "Help with adding extra Item in Order",
        "Help Cancel or Refund Order to customer",
        "Update of Menu",
        "Add New store with Grabull",
        "Free website Upgrade and Marketing Help",
        "Reviews on Google (Reputation management)",
        "Marketing Packages",
        "Payment & Bank Account Query"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar: Red Back Chevron + "Help"
            HStack(spacing: 18) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(brandRed)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                
                Text("Help")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(brandRed)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 14)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .fill(dividerColor)
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Scrollable List of Help Items
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Array(helpTopics.enumerated()), id: \.offset) { index, topic in
                        Button {
                            selectedTopic = topic
                            alertMessage = "Grabull 24/7 Support Team is available to assist you with '\(topic)'. Support contact: support@grabull.com"
                            showAlert = true
                        } label: {
                            VStack(spacing: 0) {
                                HStack {
                                    Text(topic)
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundStyle(darkTextColor)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    // Row 1 in screenshot does not show chevron, rows 2-9 do
                                    if index > 0 {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(chevronColor)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 15)
                                
                                // Row separator line
                                Rectangle()
                                    .fill(dividerColor)
                                    .frame(height: 1)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert(selectedTopic, isPresented: $showAlert) {
            Button("Call Support") {
                if let url = URL(string: "tel://18005550199") {
                    #if os(iOS)
                    UIApplication.shared.open(url)
                    #endif
                }
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview("Help Screen") {
    SupportHelpView(onBack: {})
}
