//
//  ReportsView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct ReportsView: View {
    var onBack: () -> Void
    
    @State private var selectedReport: String = ""
    @State private var showAlert: Bool = false
    
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let darkTextColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let cardGray = Color(red: 228/255, green: 228/255, blue: 228/255)
    private let chevronColor = Color(red: 50/255, green: 50/255, blue: 50/255)
    
    private let reportItems = [
        "Daily Summary",
        "Monthly Meal Tax & Other Charges",
        "Monthly & Weekly Invoices",
        "Orders by Weekly",
        "How to Grow More Sales ?"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section with < BACK on left and Red Wave Crest on top-right
            ZStack(alignment: .top) {
                // Top Right Wave Graphic
                HStack {
                    Spacer()
                    ReportsWaveCrest()
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
                        .frame(width: 220, height: 80)
                        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
                }
                .ignoresSafeArea(edges: .top)
                
                // Back Button
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
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .frame(height: 55)
            
            // Scrollable Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Page Title: "Reports"
                    Text("Reports")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(darkTextColor)
                        .padding(.top, 16)
                        .padding(.bottom, 22)
                    
                    // List of 5 Report Card Items
                    VStack(spacing: 12) {
                        ForEach(reportItems, id: \.self) { item in
                            Button {
                                selectedReport = item
                                showAlert = true
                            } label: {
                                HStack {
                                    Text(item)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(darkTextColor)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(chevronColor)
                                }
                                .padding(.horizontal, 18)
                                .frame(height: 50)
                                .background(cardGray)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 36)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .alert(selectedReport, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Live '\(selectedReport)' analytics will load once the API is connected.")
        }
    }
}

// MARK: - Wave Crest Shape for Top Right
struct ReportsWaveCrest: Shape {
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

#Preview("Reports Screen") {
    ReportsView(onBack: {})
}
