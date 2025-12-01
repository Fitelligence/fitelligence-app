//
//  CustomCalendarView.swift
//  Fitelligence
//
//  Created by Robert Penate on 11/29/25.
//

import SwiftUI
import ParseSwift

struct MyExercisesView: View {
    
    @State private var workoutVM = WorkoutViewModel()
    private let calendar = Calendar.current
    
    // Cache for exercise names
    @State private var exerciseNames: [String: String] = [:]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    
                    Text("My Exercises Today")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    if workoutVM.workoutsForSelectedDate.isEmpty {
                        VStack {
                            Spacer()
                            EmptyWorkoutsView()
                            Spacer()
                        }
                        .frame(minHeight: UIScreen.main.bounds.height * 0.7)
                        .frame(maxWidth: .infinity)
                    } else {
                        ForEach(workoutVM.workoutsForSelectedDate, id: \.objectId) { workout in
                            WorkoutView(
                                workout: workout,
                                exercises: workout.objectId.flatMap { workoutVM.exercisesForWorkout[$0] },
                                exerciseNames: $exerciseNames,
                                markCompleteAction: { updatedWorkout in
                                    Task {
                                        var updated = updatedWorkout
                                        updated.isCompleted = true
                                        do {
                                            _ = try await updated.save()
                                            let today = calendar.startOfDay(for: Date())
                                            workoutVM.loadWorkoutsWithExercises(for: today)
                                        } catch {
                                            print("Failed to mark workout completed:", error)
                                        }
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.bottom, 50)
            }
            .navigationBarHidden(true)
            .onAppear {
                let today = calendar.startOfDay(for: Date())
                workoutVM.loadWorkoutsWithExercises(for: today)
            }
            .onChange(of: workoutVM.exercisesForWorkout) { _ in
                fetchAllExerciseNames()
            }
        }
    }
    
    // Fetch names for all exercises in current workouts
    func fetchAllExerciseNames() {
        Task {
            for exercises in workoutVM.exercisesForWorkout.values {
                for exercise in exercises {
                    guard let exerciseId = exercise.objectId, exerciseNames[exerciseId] == nil,
                          let pointer = exercise.exercise else { continue }
                    do {
                        let item = try await pointer.fetch()
                        await MainActor.run {
                            exerciseNames[exerciseId] = item.name ?? "Unnamed Exercise"
                        }
                    } catch {
                        print("Failed to fetch exercise name:", error)
                    }
                }
            }
        }
    }
}

struct EmptyWorkoutsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No workouts logged today")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}

struct WorkoutView: View {
    let workout: Workout
    let exercises: [Exercise]?
    @Binding var exerciseNames: [String: String]
    let markCompleteAction: (Workout) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Workout title
            Text(workout.name ?? "Unnamed Workout")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            Divider()
            
            // Exercises
            if let exercises = exercises, !exercises.isEmpty {
                ForEach(exercises, id: \.objectId) { exercise in
                    ExerciseView(exercise: exercise, exerciseNames: $exerciseNames)
                }
            } else {
                Text("No exercises for this workout")
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding(.horizontal)
            }
            
            // Mark Complete Button
            Button(action: {
                markCompleteAction(workout)
            }) {
                HStack {
                    Spacer()
                    Text(workout.isCompleted == true ? "Completed" : "Mark Complete")
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    Spacer()
                }
                .background(workout.isCompleted == true ? Color.green : Color.blue)
                .cornerRadius(8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct ExerciseView: View {
    let exercise: Exercise
    @Binding var exerciseNames: [String: String]
    
    @ViewBuilder
    var body: some View {
        let name  = exercise.objectId.flatMap { exerciseNames[$0] } ?? "Loading..."
        
        if let sets = exercise.sets, !sets.isEmpty {
            ForEach(sets) { set in
                ExerciseCard(
                    name: name,
                    reps: set.reps,
                    sets: set.setNumber,
                    weight: Int(set.weight)
                )
            }
        } else {
            Text(name)
                .padding(.horizontal)
        }
    }
}
