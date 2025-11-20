import SwiftUI

struct ExerciseCardView: View {
    let exerciseLibraryItem: ExerciseLibraryItem
    @Bindable var viewModel: WorkoutViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 22))
                    .padding(10)
                    .background(Color.black.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                VStack(alignment: .leading, spacing: 12) {
                    // Exercise name
                    Text(exerciseLibraryItem.name ?? "Unknown Exercise")
                        .font(.system(size: 20, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                
                    
                    Divider()
                    
                    ForEach(viewModel.trackedExercises[exerciseLibraryItem] ?? []) { set in
                        SetRowView(
                            exerciseLibraryItem: exerciseLibraryItem,
                            set: set,
                            viewModel: viewModel
                        )
                    }
                }
                Button(action: {viewModel.removeTrackedExercise(exerciseLibraryItem)}) {
                    Image(systemName: "x.circle")
                        .foregroundStyle(.gray)
                }
            }
            
            HStack {
                Spacer()
                Button("Add Set +") {
                    viewModel.addSet(to: exerciseLibraryItem)
                }
                .font(.subheadline)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.18))
        )
        .padding(.horizontal)
    }
}

struct SetRowView: View {
    let exerciseLibraryItem: ExerciseLibraryItem
    let set: Set
    @Bindable var viewModel: WorkoutViewModel
    
    var body: some View {
        HStack(spacing: 24) {
            
            // --- Set Number (Read Only) ---
            MetricColumn(
                title: "Set",
                value: .constant("\(set.setNumber)"),
                isReadOnly: true
            )
            
            // --- Weight Input ---
            MetricColumn(
                title: "Weight",
                value: Binding(
                    get: { String(format: "%.0f", set.weight) },
                    set: { newValue in
                        if let newDouble = Double(newValue) {
                            viewModel.updateSetWeight(for: exerciseLibraryItem, setId: set.id, weight: newDouble)
                        }
                    }
                )
            )
            
            // --- Reps Input ---
            MetricColumn(
                title: "Reps",
                value: Binding(
                    get: { String(set.reps) },
                    set: { newValue in
                        if let newInt = Int(newValue) {
                            viewModel.updateSetReps(for: exerciseLibraryItem, setId: set.id, reps: newInt)
                        }
                    }
                )
            )
            
            VStack {
                Spacer()
                Button(action: {
                    viewModel.removeSet(from: exerciseLibraryItem, setId: set.id)
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red.opacity(0.8))
                        .imageScale(.medium)
                }
                .padding(.bottom, 6)
            }
        }
    }
}

struct MetricColumn: View {
    let title: String
    @Binding var value: String
    var isReadOnly: Bool = false

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))

            if isReadOnly {
                // Read-only version (for Set Number)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 60, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 1, y: 1)
            } else {
                // Editable version (for Weight/Reps)
                TextField("0", text: $value)
                    .font(.subheadline.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .keyboardType(.decimalPad)
                    .frame(width: 60, height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 1, y: 1)
            }
        }
    }
}
