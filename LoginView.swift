//
//  ContentView.swift
//  User-Login
//
//  Created by shaun amoah on 11/5/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showSignUp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Logo/Brand
                    Text("Fitelligence")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 80)
                        .padding(.bottom, 60)
                    
                    // Login Card
                    VStack(alignment: .leading, spacing: 24) {
                        Text("Login")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(.bottom, 8)
                        
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
                        
                        // Login Button
                        Button(action: {
                            viewModel.login()
                        }) {
                            Text("Log in")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0.25, green: 0.31, blue: 0.71))
                                .cornerRadius(28)
                        }
                        .padding(.top, 8)
                        
                        // Forgot Password
                        Button(action: {
                            viewModel.forgotPassword()
                        }) {
                            Text("Forgot your password?")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    }
                    .padding(32)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack(spacing: 4) {
                        Text("Don't have an account?")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            showSignUp = true
                        }) {
                            Text("Sign up")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0.25, green: 0.31, blue: 0.71))
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSignUp) {
                SignUpView()
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.successMessage)
            }
        }
    }
}

// Custom TextField Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .frame(height: 56)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(28)
            .font(.system(size: 16))
    }
}

#Preview {
    LoginView()
}
