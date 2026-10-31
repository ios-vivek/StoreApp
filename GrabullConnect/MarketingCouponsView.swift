//
//  MarketingCouponsView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct MarketingCouponsView: View {
    var onBack: () -> Void
    
    @State private var showCreateOfferSheet: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // Form fields for creating offer
    @State private var promoTitle: String = ""
    @State private var discountPercentage: String = ""
    
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    private let darkBarColor = Color(red: 45/255, green: 45/255, blue: 45/255)
    private let titleBlack = Color(red: 20/255, green: 20/255, blue: 20/255)
    private let subtitleGray = Color(red: 120/255, green: 120/255, blue: 120/255)
    private let statBlue = Color(red: 0/255, green: 130/255, blue: 225/255)
    private let bubbleLightBlue = Color(red: 236/255, green: 245/255, blue: 254/255)
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Section with < BACK on left and Red Wave Crest on top-right
            ZStack(alignment: .top) {
                // Top Right Wave Graphic
                HStack {
                    Spacer()
                    TopRightWaveCrest()
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
            
            // Dark Header Bar: "Marketing & Coupons"
            ZStack {
                darkBarColor
                
                Text("Marketing & Coupons")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            
            // Scrollable Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Title: Design your Discount coupons
                    Text("Design your Discount coupons")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(titleBlack)
                        .padding(.top, 24)
                        .padding(.bottom, 10)
                    
                    // Subtitle / Promotional Text
                    VStack(spacing: 4) {
                        Text("Our Simple Promotions Attract new customers,")
                        Text("Encourage large orders, get Repeat customers")
                    }
                    .font(.system(size: 14.5, weight: .regular))
                    .foregroundStyle(subtitleGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                    
                    // Users Attracted & Promotion Limits Card
                    ZStack(alignment: .leading) {
                        // Card Container
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color(red: 225/255, green: 230/255, blue: 236/255), lineWidth: 1)
                            .background(Color.white)
                        
                        HStack(spacing: 0) {
                            // Left Column with Circular Light Blue Bubble Background
                            ZStack {
                                // Light Blue curved shape
                                BubbleCurveShape()
                                    .fill(bubbleLightBlue)
                                
                                VStack(spacing: 6) {
                                    Text("USERS ATTRACTED")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundStyle(titleBlack)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                    
                                    Text("JUNE")
                                        .font(.system(size: 16, weight: .heavy))
                                        .foregroundStyle(titleBlack)
                                    
                                    Text("28")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(statBlue)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 18)
                            }
                            .frame(width: 175)
                            
                            // Right Column: "You can create upto 4 Promotions"
                            VStack(spacing: 4) {
                                Text("You can create")
                                Text("upto 4 Promotions")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(titleBlack)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 12)
                        }
                    }
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 1)
                            .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                    )
                    .padding(.horizontal, 0)
                    .padding(.bottom, 28)
                    
                    // Status text: "No Offer Available."
                    Text("No Offer Available.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color(red: 90/255, green: 90/255, blue: 90/255))
                        .padding(.bottom, 16)
                    
                    // Create Offer Button
                    Button {
                        showCreateOfferSheet = true
                    } label: {
                        Text("Create Offer")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(brandRed)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showCreateOfferSheet) {
            createOfferSheetView
        }
        .alert("Marketing & Coupons", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // Sheet to create a discount coupon offer
    private var createOfferSheetView: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("New Promotion Offer")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(titleBlack)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Offer Title")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(subtitleGray)
                    
                    TextField("e.g. Weekend Special 10% Off", text: $promoTitle)
                        .padding(12)
                        .background(Color(white: 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Discount (%)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(subtitleGray)
                    
                    TextField("e.g. 15", text: $discountPercentage)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color(white: 0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
                
                Button {
                    let title = promoTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                    if title.isEmpty {
                        return
                    }
                    showCreateOfferSheet = false
                    alertMessage = "Promotion '\(title)' created! (API will be connected later)."
                    showAlert = true
                    promoTitle = ""
                    discountPercentage = ""
                } label: {
                    Text("Publish Promotion")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(brandRed)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
            .navigationTitle("Create Offer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showCreateOfferSheet = false
                    }
                    .foregroundStyle(brandRed)
                }
            }
        }
    }
}

// MARK: - Top Right Wave Shape
struct TopRightWaveCrest: Shape {
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

// MARK: - Bubble Curve for Left Column
struct BubbleCurveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width * 0.82, y: 0))
        
        // Curved convex arc extending to the right
        path.addCurve(
            to: CGPoint(x: rect.width * 0.82, y: rect.height),
            control1: CGPoint(x: rect.width * 1.15, y: rect.height * 0.3),
            control2: CGPoint(x: rect.width * 1.15, y: rect.height * 0.7)
        )
        
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

#Preview("Marketing & Coupons") {
    MarketingCouponsView(onBack: {})
}
