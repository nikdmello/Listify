//
//  Category.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/18/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import Foundation
import RealmSwift

// Inherits from Object to save Category as a realm object
class Category: Object {
    // Dynamic var - can monitor changes in property during runtime
    @objc dynamic var categoryTitle : String = ""
    @objc dynamic var color : String = ""
    // Defines the one-to-many relationship between Category and Tasks
    let tasks = List<Task>()
    
    
}
