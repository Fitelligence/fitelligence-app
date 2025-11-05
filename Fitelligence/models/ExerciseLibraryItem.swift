//
//  ExerciseLibraryItem.swift
//  Fitelligence
//
//  Created by Austin on 11/5/25.
//

import ParseSwift
import Foundation

//ExerciseLibraryItem
//This model holds the definition of all of the exercises in the app. The database will have stored a library of all the exercises for reference.
//Query this from database when user needs to view list of exercises

//Use 'ExerciseCategory.[category]' when creating a ExerciseLibraryItem object
enum ExerciseCategory: String, Codable {
    case abs = "abs"
    case back = "back"
    case biceps = "biceps"
    case cardio = "cardio"
    case chest = "chest"
    case legs = "legs"
    case shoulders = "shoulders"
    case triceps = "triceps"
    
    var name: String {
        return self.rawValue
    }
}

struct ExerciseLibraryItem: ParseObject {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var name: String?
    var category: ExerciseCategory?
}
