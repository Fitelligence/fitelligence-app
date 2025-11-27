//
//  WorkoutViewModel.swift
//  Fitelligence
//
//  Created by Austin on 11/18/25.
//

import Observation
import ParseSwift
import SwiftUI

@MainActor
@Observable
class WorkoutViewModel {
    var exercises: [ExerciseLibraryItem] = []
    var trackedExercises: [ExerciseLibraryItem: [Set]] = [:]
    
    //edit by robert
    var exercisesForWorkout: [String: [Exercise]] = [:]
    
    var workoutsForSelectedDate: [Workout] = []
    private let calendar = Calendar.current
    //end edit
    
    private let service = WorkoutService()
    
    func addTrackedExercise(_ exercise: ExerciseLibraryItem) {
        if trackedExercises[exercise] == nil {
            trackedExercises[exercise] = [
                Set(setNumber: 1, weight: 0, reps: 0)
            ]
        }
    }
    
    func removeTrackedExercise(_ exercise: ExerciseLibraryItem) {
        trackedExercises.removeValue(forKey: exercise)
    }
    
    func addSet(to exercise: ExerciseLibraryItem) {
        if var sets = trackedExercises[exercise] {
            sets.append(
                Set(setNumber: sets.count + 1, weight: 0, reps: 0)
            )
            trackedExercises[exercise] = sets
        }
    }
    
    func removeSet(from exercise: ExerciseLibraryItem, setId: UUID) {
        guard var sets = trackedExercises[exercise] else { return }
        sets.removeAll { $0.id == setId }
        // Re-number remaining sets
        for idx in sets.indices {
            sets[idx].setNumber = idx + 1
        }
        trackedExercises[exercise] = sets
    }
    
    
    func updateSetWeight(for exercise: ExerciseLibraryItem, setId: UUID, weight: Double) {
        guard var sets = trackedExercises[exercise],
              let idx = sets.firstIndex(where: { $0.id == setId }) else { return }
        sets[idx].weight = weight
        trackedExercises[exercise] = sets
    }
    
    func updateSetReps(for exercise: ExerciseLibraryItem, setId: UUID, reps: Int) {
        guard var sets = trackedExercises[exercise],
              let idx = sets.firstIndex(where: { $0.id == setId }) else { return }
        sets[idx].reps = reps
        trackedExercises[exercise] = sets
    }
    
    func saveWorkout(name: String, date: Date) async throws {
        var workout = Workout()
        workout.name = name
        workout.scheduleDate = date
        
        do {
            let savedWorkout = try await workout.save()
            guard let workoutId = savedWorkout.objectId else { return }
            let workoutPointer = Pointer<Workout>(objectId: workoutId)
            for exercise in trackedExercises {
                var newExercise = Exercise()
                newExercise.workout = workoutPointer
                newExercise.exercise = Pointer<ExerciseLibraryItem>(objectId: exercise.key.objectId!)
                newExercise.sets = exercise.value
                _ = try await newExercise.save()
            }
            trackedExercises = [:]
        } catch {
            print(error)
        }
    }
    
    func loadExercises() async {
        do {
            exercises = try await service.fetchAllExercises()
        } catch {
            print("Failed to load exercises: \(error)")
            exercises = []
        }
    }
    
    func loadExercises(by category: String) -> [ExerciseLibraryItem] {
        return exercises.filter { $0.category?.name == category }
    }
    
    //edit by robert
    
    func refresh(for date: Date) {
        Task {
            loadWorkouts(for: date)
        }
    }
    
    func loadWorkouts(for date: Date) {
        // Offload to background priority
        Task(priority: .background) {
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

            do {
                // Build query
                let query = Workout.query("scheduleDate" >= startOfDay)
                    .where("scheduleDate" < endOfDay)
                    .include(["user"])

                // Perform query
                let results = try await query.find()

                // Update UI on main thread
                await MainActor.run {
                    self.workoutsForSelectedDate = results
                    
                    
                }
            } catch {
                // Handle errors on main thread
                await MainActor.run {
                    self.workoutsForSelectedDate = []
                    print("Failed to load workouts:", error.localizedDescription)
                }
            }
        }
    }

    func loadWorkoutsWithExercises(for date: Date) {
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            Task(priority: .background) {
                do {
                    // Fetch workouts for the day
                    let workouts = try await Workout.query("scheduleDate" >= startOfDay)
                        .where("scheduleDate" < endOfDay)
                        .include(["user"])
                        .find()
                    
                    await MainActor.run {
                        self.workoutsForSelectedDate = workouts
                    }
                    
                    // Fetch exercises for each workout
                    for workout in workouts {
                        guard let workoutId = workout.objectId else { continue }
                        let exercises = try await Exercise.query("workout" == Pointer<Workout>(objectId: workoutId))
                            .include(["exercise"])
                            .find()
                        
                        await MainActor.run {
                            self.exercisesForWorkout[workoutId] = exercises
                        }
                    }
                    
                } catch {
                    await MainActor.run {
                        self.workoutsForSelectedDate = []
                        self.exercisesForWorkout = [:]
                        print("Failed to load workouts with exercises:", error.localizedDescription)
                    }
                }
            }
        }
    }
    //end edit



class WorkoutService {
    
    func fetchAllExercises() async throws -> [ExerciseLibraryItem] {
        try await ExerciseLibraryItem.query().findAll()
    }
}
