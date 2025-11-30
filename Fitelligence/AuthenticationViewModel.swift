//
//  AuthenticationViewModel.swift
//  User-Login
//
//  Created by shaun amoah on 11/6/25.
//

import SwiftUI
import ParseSwift
import Combine


class AuthenticationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var isAuthenticated = false
    
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
    
    // MARK: - Login (Real Parse Authentication)
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
        
        // Use Parse login - will FAIL if account doesn't exist
        User.login(username: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ User logged in successfully:", user)
                    self.isAuthenticated = true
                    self.showSuccessAlert("Welcome back!")
                    
                case .failure(let error):
                    print("❌ Login failed:", error.message)
                    // Parse will return an error if account doesn't exist
                    if error.message.contains("Invalid username/password") {
                        self.showErrorAlert("Invalid email or password. Please sign up if you don't have an account.")
                    } else {
                        self.showErrorAlert(error.message)
                    }
                }
            }
        }
    }
    
    // MARK: - Sign Up (Real Parse Account Creation)
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
        
        // Create real Parse user account
        var newUser = User()
        newUser.username = email
        newUser.email = email
        newUser.password = password
        newUser.fullName = fullName
        
        newUser.signup { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    print("✅ User account created:", user)
                    self.showSuccessAlert("Account created successfully! You can now log in.")
                    self.clearFields()
                    
                case .failure(let error):
                    print("❌ Sign up failed:", error.message)
                    // Parse will return error if email already exists
                    if error.message.contains("Account already exists") {
                        self.showErrorAlert("An account with this email already exists. Please log in.")
                    } else {
                        self.showErrorAlert(error.message)
                    }
                }
            }
        }
    }
    
    // MARK: - Forgot Password (Real Parse Password Reset)
    func forgotPassword() {
        guard !email.isEmpty else {
            showErrorAlert("Please enter your email address first")
            return
        }
        
        guard isValidEmail(email) else {
            showErrorAlert("Please enter a valid email address")
            return
        }
        
        // Use Parse password reset
        User.passwordReset(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Password reset email sent to:", self.email)
                    self.showSuccessAlert("Password reset link sent to \(self.email)")
                    
                case .failure(let error):
                    print("❌ Password reset failed:", error.message)
                    self.showErrorAlert(error.message)
                }
            }
        }
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
    
    func clearFields() {
        email = ""
        password = ""
        fullName = ""
    }
}


