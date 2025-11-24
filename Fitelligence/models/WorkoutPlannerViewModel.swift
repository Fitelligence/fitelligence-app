//
//  WorkoutPlannerViewModel.swift
//  Fitelligence
//
//  Created by Jake Capuana on 11/24/25.
//

import Foundation
import ParseSwift
import Combine

@Observable
class WorkoutPlannerViewModel {
    var workouts: [Workout] = []
    var selectedDate: Date = Date()
    var isLoading = false
    var errorMessage: String?
    var showingCreateWorkout = false
    
    init() {
        Task {
            await fetchWorkouts()
        }
    }
    
    // Fetch all workouts for the current user
    func fetchWorkouts() async {
        guard let currentUser = User.current else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Create pointer to current user for query
            let userPointer = try currentUser.toPointer()
            
            // Create query with proper where clause
            let query = Workout.query()
                .where("user" == userPointer)
                .order([.descending("scheduleDate")])
                .include(["user"])
            
            let fetchedWorkouts = try await query.find()
            await MainActor.run {
                self.workouts = fetchedWorkouts
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load workouts: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Get workouts for a specific date
    func workouts(for date: Date) -> [Workout] {
        let calendar = Calendar.current
        return workouts.filter { workout in
            guard let workoutDate = workout.scheduleDate else { return false }
            return calendar.isDate(workoutDate, inSameDayAs: date)
        }
    }
    
    // Check if a date has workouts
    func hasWorkouts(on date: Date) -> Bool {
        return !workouts(for: date).isEmpty
    }
    
    // Delete a workout
    func deleteWorkout(_ workout: Workout) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        var workoutToDelete = workout
        
        do {
            try await workoutToDelete.delete()
            await MainActor.run {
                self.workouts.removeAll { $0.objectId == workout.objectId }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to delete workout: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Mark workout as completed
    func toggleWorkoutCompletion(_ workout: Workout) async {
        var updatedWorkout = workout
        
        // Toggle completion status
        if updatedWorkout.isCompleted == nil {
            updatedWorkout.isCompleted = true
        } else {
            updatedWorkout.isCompleted?.toggle()
        }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let savedWorkout = try await updatedWorkout.save()
            await MainActor.run {
                if let index = self.workouts.firstIndex(where: { $0.objectId == savedWorkout.objectId }) {
                    self.workouts[index] = savedWorkout
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to update workout: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Refresh workouts (call after creating new workout)
    func refreshWorkouts() async {
        await fetchWorkouts()
    }
}
