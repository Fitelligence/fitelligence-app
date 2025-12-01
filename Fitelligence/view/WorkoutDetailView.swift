//
//  CustomCalendarView.swift
//  Fitelligence
//
//  Created by Robert Penate on 11/29/25.
//

import SwiftUI
import ParseSwift

struct WorkoutDetailView: View {
    let workout: Workout
    var workoutVM: WorkoutViewModel
    let selectedDate: Date
    
    @State private var exercises: [Exercise] = []
    @State private var exerciseNames: [String: String] = [:]
    @State private var isLoading = true

    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteConfirm = false
    
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading exercises...")
            } else if exercises.isEmpty {
                Text("No exercises in this workout")
                    .foregroundColor(.gray)
            } else {
                List(exercises, id: \.objectId) { exercise in

                    VStack(alignment: .leading, spacing: 8) {
                        Text(exerciseNames[exercise.objectId ?? ""] ?? "Loading...")
                            .font(.headline)

                        if let sets = exercise.sets {
                            ForEach(sets) { set in
                                ExerciseCard(
                                    name: "",
                                    reps: set.reps,
                                    sets: set.setNumber,
                                    weight: Int(set.weight)
                                )
                            }
                        } else {
                            Text("No sets recorded")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name ?? "Workout")
        .task {
            await loadExercises()
        }.toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Edit button
                NavigationLink(destination: CreateWorkoutView(
                    workoutToEdit: workout,
                    workoutVM: workoutVM,
                    selectedDate: selectedDate
                )) {
                    Image(systemName: "pencil")
                }

                // Delete button
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Delete Workout?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                Task {
                    await deleteWorkout()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete the workout and all exercises inside it.")
        }.onDisappear {
            workoutVM.refresh(for: selectedDate)
        }

    }

    func loadExercises() async {
        guard let id = workout.objectId else { return }

        do {
            let results = try await Exercise
                .query("workout" == Pointer<Workout>(objectId: id))
                .include(["exercise"])
                .find()

            exercises = results

            for exercise in results {
                if let pointer = exercise.exercise,
                   let item = try? await pointer.fetch() {
                    exerciseNames[exercise.objectId ?? ""] = item.name ?? "Unnamed Exercise"
                }
            }

        } catch {
            print("Failed to load exercises:", error.localizedDescription)
        }

        isLoading = false
    }
    
    func deleteWorkout() async {
        guard let workoutId = workout.objectId else { return }

        do {
            // Delete exercises linked to this workout
            let exerciseQuery = Exercise
                .query("workout" == Pointer<Workout>(objectId: workoutId))

            let exercisesToDelete = try await exerciseQuery.find()

            for exercise in exercisesToDelete {
                _ = try await exercise.delete()
            }

            // Delete workout
            _ = try await workout.delete()

            // Return to previous screen
            await MainActor.run {
                dismiss()
            }

        } catch {
            print("Failed to delete workout:", error.localizedDescription)
        }
    }

}
