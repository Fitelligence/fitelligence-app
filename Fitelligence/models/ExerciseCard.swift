//
//  ExerciseCard.swift
//  Fitelligence
//
//  Created by Robert Penate on 11/30/25.
//

import SwiftUICore


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
