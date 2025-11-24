//
//  FitelligenceApp.swift
//  Fitelligence
//
//  Created by Michael Steelman + Jake C on 11/3/25.
//

import SwiftUI
import ParseSwift

@main
struct FitelligenceApp: App {
    
    @StateObject private var authViewModel = AuthenticationViewModel()
    
    init() {
        ParseSwift.initialize(
            applicationId: "1g9mCtQTndUdapOL2URSjzBarbEVJpBxXI09peRa",
            clientKey: "Uc7vWW8kRkgrEgm0TDQ9l9CkrST9rQUvkZQluN5H",
            serverURL: URL(string: "https://parseapi.back4app.com")!
        )
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()  // ← Changed this line
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
