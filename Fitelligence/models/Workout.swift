//
//  Workout.swift
//  Fitelligence
//
//  Created by Austin on 11/5/25.
//

import ParseSwift
import Foundation

//Workout
//This model represents the top-level document. When the user goes to the gym, they create a workout, and then add exercises to it.

//Usage:
//the user field stores the User that created the workout as a pointer.
//when saving to the database: workout.user = try? currentUser.toPointer()
//when querying the database: make sure to add include(["user"]) to query

struct Workout: ParseObject, Codable {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var user: Pointer<User>?
    var name: String?
    var isCompleted: Bool?
}
