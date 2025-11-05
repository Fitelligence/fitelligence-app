//
//  User.swift
//  Fitelligence
//
//  Created by Austin on 11/4/25.
//

import ParseSwift
import Foundation

struct User: ParseUser {
    var objectId: String?
    var createdAt: Date?
    var updatedAt: Date?
    var ACL: ParseACL?
    var originalData: Data?
    
    var username: String?
    var email: String?
    var emailVerified: Bool?
    var password: String?
    var authData: [String: [String: String]?]?
}
