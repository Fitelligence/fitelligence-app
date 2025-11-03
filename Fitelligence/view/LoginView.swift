//
//  LoginView.swift
//  
//
//  Created by Michael Steelman on 11/3/25.
//

import SwiftUI

struct LoginView : View
{
    @State private var username = ""
    @State private var password = ""
    
    var body : some View
    {
        VStack(spacing: 30)
        {
            Text("Fitelligence")
                .font(.system(size: 48, weight: .bold))
                .padding(.top, 100)
            
            Spacer()
            
            VStack(spacing: 20)
            {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
}


#Preview {
    LoginView()
}
