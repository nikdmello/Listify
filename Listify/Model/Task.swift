//
//  Task.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/18/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import Foundation
import RealmSwift

// Subclasses Object class to define Realm objects
class Task: Object {
    @objc dynamic var title : String = ""
    @objc dynamic var completed = false
    @objc dynamic var dateCreated: Date?
    // Represents the many-to-one relationship between Tasks and Category
    // Auto-updating container
    // Links each Task object to a parent Category
    var parentCategory = LinkingObjects(fromType: Category.self, property: "tasks")
}
