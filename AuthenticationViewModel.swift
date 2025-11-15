//
//  AuthenticationViewModel.swift
//  User-Login
//
//  Created by shaun amoah on 11/6/25.
//

import SwiftUI

class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published var showError = false
    @Published var errorMessage = ""
    
    @Published var showSuccess = false
    @Published var successMessage = ""
    
    // MARK: - Validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    // MARK: - Login
    func login() {
        // Validate inputs
        guard !email.isEmpty else {
            showErrorAlert("Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("Please enter a valid email address")
            return
        }
        
        guard !password.isEmpty else {
            showErrorAlert("Please enter your password")
            return
        }
        
        // TODO: Implement actual authentication logic here
        // This is where you would call your backend API or Firebase Auth
        
        // For demo purposes:
        print("Login attempt with:")
        print("Email: \(email)")
        print("Password: [HIDDEN]")
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Replace this with actual authentication
            self.showSuccessAlert("Login successful!")
            
            // TODO: Navigate to main app
            // You would typically use a @StateObject or @EnvironmentObject
            // to manage authentication state across the app
        }
    }
    
    // MARK: - Sign Up
    func signUp(confirmPassword: String) {
        // Validate inputs
        guard !fullName.isEmpty else {
            showErrorAlert("Please enter your full name")
            return
        }
        
        guard !email.isEmpty else {
            showErrorAlert("Please enter your email")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("Please enter a valid email address")
            return
        }
        
        guard !password.isEmpty else {
            showErrorAlert("Please enter your password")
            return
        }
        
        guard isValidPassword(password) else {
            showErrorAlert("Password must be at least 6 characters long")
            return
        }
        
        guard password == confirmPassword else {
            showErrorAlert("Passwords do not match")
            return
        }
        
        // TODO: Implement actual sign up logic here
        // This is where you would call your backend API or Firebase Auth
        
        // For demo purposes:
        print("Sign up attempt with:")
        print("Name: \(fullName)")
        print("Email: \(email)")
        print("Password: [HIDDEN]")
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Replace this with actual authentication
            self.showSuccessAlert("Account created successfully!")
            
            // Clear fields
            self.clearFields()
        }
    }
    
    // MARK: - Forgot Password
    func forgotPassword() {
        guard !email.isEmpty else {
            showErrorAlert("Please enter your email address first")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("Please enter a valid email address")
            return
        }
        
        // TODO: Implement password reset logic
        // This is where you would call your backend API or Firebase Auth
        
        print("Password reset requested for: \(email)")
        
        showSuccessAlert("Password reset link sent to \(email)")
    }
    
    // MARK: - Helper Methods
    private func showErrorAlert(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showSuccessAlert(_ message: String) {
        successMessage = message
        showSuccess = true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        fullName = ""
    }
}

