//
//  Exercise.swift
//  Fitelligence
//
//  Created by Austin on 11/5/25.
//

import ParseSwift
import Foundation

//Exercise
//This model represents individual exercises of a workout. Exercises are linked to workouts via pointer, and the ExerciseLibraryItem pointer can be used to retrieve exercise details, such as name and category, as needed. 

struct Set: Codable, Equatable {
    var set: Int
    var weight: Double
    var reps: Int
}

struct Exercise: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var workout: Pointer<Workout>?
    var exercise: Pointer<ExerciseLibraryItem>?
    var sets: [Set]?
}
