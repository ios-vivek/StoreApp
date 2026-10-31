//
//  RequestSignUpWebView.swift
//  GrabullConnect
//
//  Created by Vivek SIngh on 25/10/26.
//

import SwiftUI
import WebKit

struct RequestSignUpWebView: View {
    var onBack: () -> Void
    
    private let targetURL = URL(string: "https://www.grabullmarketing.com/new-restaurant-sign-up/")!
    private let brandRed = Color(red: 227/255, green: 27/255, blue: 35/255)
    
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Bar with < BACK and Top-Right Red Wave Crest
            ZStack(alignment: .top) {
                // Top Right Red Wave Graphic
                HStack {
                    Spacer()
                    SignUpWaveCrest()
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
                
                // Leading < BACK Button
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
                        .padding(.trailing, 16)
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 16)
                    .padding(.top, 10)
                    
                    Spacer()
                }
            }
            .frame(height: 56)
            
            // Web Content Area
            ZStack {
                WebViewRepresentable(url: targetURL, isLoading: $isLoading, loadFailed: $loadFailed)
                    .ignoresSafeArea(edges: .bottom)
                
                if isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: brandRed))
                            .scaleEffect(1.2)
                        
                        Text("Loading Sign Up Page...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                }
                
                if loadFailed {
                    VStack(spacing: 16) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 40))
                            .foregroundStyle(.gray)
                        
                        Text("Unable to load page")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.black.opacity(0.75))
                        
                        Button {
                            loadFailed = false
                            isLoading = true
                        } label: {
                            Text("Retry")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 10)
                                .background(brandRed)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
    }
}

// MARK: - UIViewRepresentable for WKWebView
struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var loadFailed: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        let request = URLRequest(url: url)
        webView.load(request)
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // If user tapped retry after failure
        if !loadFailed && isLoading && uiView.url == nil {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = true
                self.parent.loadFailed = false
            }
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = false
            }
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = true
            }
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.loadFailed = true
            }
        }
    }
}

// MARK: - Top-Right Wave Shape
struct SignUpWaveCrest: Shape {
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

#Preview("Request Sign Up Page") {
    RequestSignUpWebView(onBack: {})
}
