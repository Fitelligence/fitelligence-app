
import SwiftUI

struct ExerciseCardView: View {
    let name: String
    let reps: Int
    let sets: Int
    let weight: Int

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 22))
                .padding(10)
                .background(Color.black.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                // Exercise name
                Text(name)
                    .font(.system(size: 20, weight: .semibold))

                // Reps / Sets / Weight row
                HStack(spacing: 24) {
                    MetricColumn(title: "Reps", value: "\(reps)")
                    MetricColumn(title: "Sets", value: "\(sets)")
                    MetricColumn(title: "Weight", value: "\(weight)")
                }
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.18))
        )
        .padding(.horizontal)
    }
}

private struct MetricColumn: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .frame(width: 60, height: 32)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 1, y: 1)
        }
    }
}

#Preview {
  ExerciseCardView()
}
