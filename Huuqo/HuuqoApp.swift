//
//  HuuqoApp.swift
//  Huuqo
//
//  Created by Anthony Nicolaas on 12/18/24.
//

import SwiftUI

@main
struct HuuqoApp: App {
    init() {
        // Configure standard appearance (when scrolling)
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithDefaultBackground()
        standardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        standardAppearance.shadowColor = .clear // This removes the separator line
        standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Configure scroll edge appearance (when at top)
        let scrollEdgeAppearance = UINavigationBarAppearance()
        scrollEdgeAppearance.configureWithOpaqueBackground()
        scrollEdgeAppearance.backgroundColor = .black
        scrollEdgeAppearance.shadowColor = .clear
        scrollEdgeAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        scrollEdgeAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = standardAppearance
        UINavigationBar.appearance().compactAppearance = standardAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = scrollEdgeAppearance
        
        // Configure tab bar standard appearance (when scrolling)
        let tabBarStandardAppearance = UITabBarAppearance()
        tabBarStandardAppearance.configureWithDefaultBackground()
        tabBarStandardAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        tabBarStandardAppearance.backgroundColor = nil
        tabBarStandardAppearance.shadowColor = .clear
        
        // Configure tab bar scroll edge appearance (when at bottom)
        let tabBarScrollEdgeAppearance = UITabBarAppearance()
        tabBarScrollEdgeAppearance.configureWithOpaqueBackground()
        tabBarScrollEdgeAppearance.backgroundColor = .black
        tabBarScrollEdgeAppearance.shadowColor = .clear
        
        UITabBar.appearance().standardAppearance = tabBarStandardAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarScrollEdgeAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0
    let networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if networkMonitor.isConnected {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }
                        .tag(0)
                    
                    LiveTVView()
                        .tabItem {
                            Label("Live TV", systemImage: "antenna.radiowaves.left.and.right")
                        }
                        .tag(1)
                    
                    SeriesView()
                        .tabItem {
                            Label("Series", systemImage: "play.tv.fill")
                        }
                        .tag(2)
                    
                    MoviesView()
                        .tabItem {
                            Label("Movies", systemImage: "film.stack")
                        }
                        .tag(3)
                    
                    Text("Profile")
                        .tabItem {
                            Label("Profile", systemImage: "person.crop.circle.fill")
                        }
                        .tag(4)
                }
                .onChange(of: selectedTab) { oldValue, newValue in
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }
                .tint(Theme.accent)
                .transition(.opacity)
            } else {
                NetworkStatusView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isConnected)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainTabView()
}
