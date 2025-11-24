//
//  MainTabView.swift
//  Fitelligence
//
//  Created by Jake Capuana on 11/24/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Calendar/Workout Planner Tab - Using Robert's view
            CustomCalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                        .font(.system(size: 24))
                }
                .tag(0)
            
            // AI Assistant Tab
            AIAssistantView()
                .tabItem {
                    Image(systemName: "sparkles")
                        .font(.system(size: 24))
                }
                .tag(1)
            
            // My Exercises Tab
            MyExercisesView()
                .tabItem {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 24))
                }
                .tag(2)
        }
        .accentColor(.blue) // Selected tab color
    }
}

// AI Assistant View
struct AIAssistantView: View {
    @State private var userInput = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 80))
                    .foregroundColor(.gray.opacity(0.5))
                
                Text("Ask Fitelligence Anything")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                // Input field
                HStack {
                    TextField("Suggest a good workout routine for leg day...", text: $userInput)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(25)
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .navigationBarHidden(true)
        }
    }
}

// My Exercises View
struct MyExercisesView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Exercises")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Example exercise cards
                    ExerciseCard(name: "Squats", reps: 20, sets: 3, weight: 140)
                    ExerciseCard(name: "Bench Press", reps: 10, sets: 3, weight: 160)
                    ExerciseCard(name: "Bicep Curls", reps: 10, sets: 2, weight: 30)
                }
                .padding(.bottom, 100)
            }
            .navigationBarHidden(true)
        }
    }
}

// Exercise Card Component
struct ExerciseCard: View {
    let name: String
    let reps: Int
    let sets: Int
    let weight: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Text(name)
                    .font(.title3)
                    .bold()
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                StatBadge(label: "Reps", value: "\(reps)")
                StatBadge(label: "Sets", value: "\(sets)")
                StatBadge(label: "Weight", value: "\(weight)")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct StatBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.body)
                .bold()
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(8)
        }
    }
}

#Preview {
    MainTabView()
}
