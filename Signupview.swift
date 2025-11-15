//
//  Signupview.swift
//  User-Login
//
//  Created by shaun amoah on 11/5/25.
//
import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Logo/Brand
                        Text("Fitelligence")
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.top, 60)
                            .padding(.bottom, 40)
                        
                        // Sign Up Card
                        VStack(alignment: .leading, spacing: 24) {
                            Text("Sign Up")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundColor(.black)
                                .padding(.bottom, 8)
                            
                            // Full Name Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Enter your full name", text: $viewModel.fullName)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textInputAutocapitalization(.words)
                            }
                            
                            // Email Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                TextField("Enter your email", text: $viewModel.email)
                                    .textFieldStyle(CustomTextFieldStyle())
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                SecureField("Enter your password", text: $viewModel.password)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Confirm Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                SecureField("Confirm your password", text: $confirmPassword)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            // Sign Up Button
                            Button(action: {
                                viewModel.signUp(confirmPassword: confirmPassword)
                            }) {
                                Text("Sign up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color(red: 0.25, green: 0.31, blue: 0.71))
                                    .cornerRadius(28)
                            }
                            .padding(.top, 8)
                            
                            // Terms and Conditions
                            Text("By signing up, you agree to our Terms & Conditions")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                        .padding(32)
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal, 24)
                        
                        // Login Link
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("Log in")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.25, green: 0.31, blue: 0.71))
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {
                    if viewModel.successMessage.contains("successfully") {
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
}

#Preview {
    SignUpView()
}







