//
//  WorketPlannerView.swift
//  Fitelligence
//
//  Created by Jake Capuana on 11/24/25.
//

import SwiftUI

struct WorkoutPlannerMainView: View {
    @State private var viewModel = WorkoutPlannerViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Header
                        Text("Fitelligence")
                            .font(.largeTitle)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top)
                        
                        // Calendar
                        CustomCalendarView()
                        .padding(.horizontal)
                        
                        // Workouts for selected date
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(selectedDate, style: .date)
                                    .font(.title3)
                                    .bold()
                                Spacer()
                                Button(action: {
                                    viewModel.showingCreateWorkout = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            let dailyWorkouts = viewModel.workouts(for: selectedDate)
                            
                            if dailyWorkouts.isEmpty {
                                EmptyWorkoutStateView()
                                    .padding(.horizontal)
                            } else {
                                ForEach(dailyWorkouts, id: \.objectId) { workout in
                                    WorkoutPlannerCard(
                                        workout: workout,
                                        onComplete: {
                                            Task {
                                                await viewModel.toggleWorkoutCompletion(workout)
                                            }
                                        },
                                        onDelete: {
                                            Task {
                                                await viewModel.deleteWorkout(workout)
                                            }
                                        }
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .padding(.bottom, 100)
                }
                
                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showingCreateWorkout) {
                CreateWorkoutView()
                    .onDisappear {
                        // Refresh workouts when create view is dismissed
                        Task {
                            await viewModel.refreshWorkouts()
                        }
                    }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// Empty state view
struct EmptyWorkoutStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text("No workouts scheduled")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tap + to create a workout")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// Workout Card Component
struct WorkoutPlannerCard: View {
    let workout: Workout
    let onComplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name ?? "Untitled Workout")
                        .font(.headline)
                    
                    if let scheduleDate = workout.scheduleDate {
                        Text("Scheduled: \(scheduleDate, style: .time)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    if workout.isCompleted == true {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("Completed")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                
                Spacer()
                
                // Completion checkmark
                Button(action: onComplete) {
                    Image(systemName: workout.isCompleted == true ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(workout.isCompleted == true ? .green : .gray)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    WorkoutPlannerMainView()
}
