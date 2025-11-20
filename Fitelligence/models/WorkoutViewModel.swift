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
    
}

class WorkoutService {
    
    func fetchAllExercises() async throws -> [ExerciseLibraryItem] {
        try await ExerciseLibraryItem.query().findAll()
    }
}
