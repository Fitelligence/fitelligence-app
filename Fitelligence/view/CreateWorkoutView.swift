//
//  CreateWorkoutView.swift
//  Fitelligence
//
//  Created by Austin on 11/14/25.
//

import SwiftUI
import ParseSwift

struct CreateWorkoutView: View {
    @State private var workoutName: String = ""
    @State private var date: Date = Date()
    @State private var isExercisePickerShowing: Bool = false
    @State private var viewModel = WorkoutViewModel()
    
    @State private var showError = false
    @State private var errorMessage = ""
    
    @Environment(\.dismiss) var dismiss

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Create Workout")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Name:")
                            .font(.title2)
                        TextField("", text: $workoutName)
                            .textFieldStyle(.plain)
                            .font(.title2)
                    }
                    Divider()
                    HStack {
                        Text("Date:")
                            .font(.title2)
                        DatePicker("", selection: $date)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                ForEach(viewModel.trackedExercises.keys.sorted(by: { $0.name ?? "" < $1.name ?? "" }), id: \.self) { exerciseLibraryItem in
                    ExerciseCardView(exerciseLibraryItem: exerciseLibraryItem, viewModel: viewModel)
                }
                
                Button(action: {
                    Task(priority: .background) {
                        await viewModel.loadExercises()
                        isExercisePickerShowing = true
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Exercise")
                    }
                    .font(.title3)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                
                
                if viewModel.trackedExercises.count > 0 {
                    Button(action: {
                        Task {
                            guard !workoutName.trimmingCharacters(in: .whitespaces).isEmpty else {
                                        errorMessage = "Workout name cannot be empty."
                                        showError = true
                                        return
                                    }
                            try? await viewModel.saveWorkout(name: workoutName, date: date)
                            workoutName = ""
                            date = Date()
                            await MainActor.run {
                                dismiss()
                            }
                        }
                    }) {
                        Text("Save workout")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .alert("Error", isPresented: $showError, actions: {
                        Button("OK", role: .cancel) {}
                    }, message: {
                        Text(errorMessage)
                    })
                }
                
                
            }
        }
        .padding(.top)
        .sheet(isPresented: $isExercisePickerShowing) {
            ExerciseCategoryPickerView(viewModel: viewModel)
                .environment(\.dismissModal, {
                    isExercisePickerShowing = false
                })
        }
        .onAppear {
            Task(priority: .background) {
                await viewModel.loadExercises()
            }
        }
    }
}

struct ExerciseCategoryPickerView: View {
    @Environment(\.dismissModal) var dismissModal
    @Bindable var viewModel: WorkoutViewModel
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: ExercisePickerView(category: "abs", viewModel: viewModel)) {
                    Text("Abs")
                }
                NavigationLink(destination: ExercisePickerView(category: "back", viewModel: viewModel)) {
                    Text("Back")
                }
                NavigationLink(destination: ExercisePickerView(category: "biceps", viewModel: viewModel)) {
                    Text("Biceps")
                }
                NavigationLink(destination: ExercisePickerView(category: "chest", viewModel: viewModel)) {
                    Text("Chest")
                }
                NavigationLink(destination: ExercisePickerView(category: "legs", viewModel: viewModel)) {
                    Text("Legs")
                }
                NavigationLink(destination: ExercisePickerView(category: "shoulders", viewModel: viewModel)) {
                    Text("Shoulders")
                }
                NavigationLink(destination: ExercisePickerView(category: "triceps", viewModel: viewModel)) {
                    Text("Triceps")
                }
            }
            .navigationTitle("Choose Category")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismissModal()
                    }
                }
            }
        }
    }
}

struct ExercisePickerView: View {
    var category: String
    @Bindable var viewModel: WorkoutViewModel
    
    private var filteredExercises: [ExerciseLibraryItem] {
        viewModel.loadExercises(by: category)
    }
    
    @Environment(\.dismissModal) var dismissModal
    
    var body: some View {
        List(filteredExercises, id: \.objectId) { exercise in
            Button(action: {
                viewModel.addTrackedExercise(exercise)
                dismissModal()
            }) {
                Text(exercise.name!)
            }
        }
        .navigationTitle(category.capitalized)
    }
}

//To close the modal once user selects an exercise
struct ModalDismissActionKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}
extension EnvironmentValues {
    var dismissModal: () -> Void {
        get { self[ModalDismissActionKey.self] }
        set { self[ModalDismissActionKey.self] = newValue }
    }
}


#Preview {
    CreateWorkoutView()
}
