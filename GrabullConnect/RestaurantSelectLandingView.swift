//
//  RestaurantSelectLandingView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI

struct RestaurantSelectLandingView: View {
    var onSelectRestaurant: () -> Void
    
    var body: some View {
        ZStack {
            // 1. Red Background with Subtle Radial Glow / Lens Flare
            ZStack {
                // Base Red Gradient
                LinearGradient(
                    colors: [
                        Color(red: 235/255, green: 25/255, blue: 35/255),
                        Color(red: 215/255, green: 15/255, blue: 24/255),
                        Color(red: 195/255, green: 10/255, blue: 18/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Top-Center Lens Glow
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.18),
                        Color.white.opacity(0.06),
                        Color.clear
                    ]),
                    center: UnitPoint(x: 0.5, y: 0.28),
                    startRadius: 10,
                    endRadius: 280
                )
                .ignoresSafeArea()
                
                // Subtle Lower Lens Flare Orb
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 220, height: 220)
                    .blur(radius: 20)
                    .offset(y: 120)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 14, height: 14)
                    .blur(radius: 2)
                    .offset(y: 125)
            }
            
            // 2. Foreground Elements
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 90)
                
                // Centered "gb" Circular Logo Badge
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 228/255, green: 20/255, blue: 28/255),
                                    Color(red: 185/255, green: 10/255, blue: 16/255)
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 5)
                    
                    // White "gb" Monogram
                    Image("GrabullLogo")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 95, height: 95)
                }
                
                Spacer()
                    .frame(height: 70)
                
                // "RESTAURANT" Action Button
                Button(action: onSelectRestaurant) {
                    Text("RESTAURANT")
                        .font(.system(size: 18, weight: .bold))
                        .tracking(1.0)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            Color(red: 220/255, green: 18/255, blue: 26/255)
                        )
                        .overlay(
                            Rectangle()
                                .stroke(Color.black.opacity(0.38), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.18), radius: 3, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 28)
                
                Spacer()
                
                // Bottom Brand Text: "GRABULL"
                Text("GRABULL")
                    .font(.system(size: 22, weight: .heavy))
                    .tracking(2.0)
                    .foregroundStyle(.white)
                    .padding(.bottom, 24)
            }
        }
    }
}

#Preview("Restaurant Select Landing") {
    RestaurantSelectLandingView(onSelectRestaurant: {})
}
