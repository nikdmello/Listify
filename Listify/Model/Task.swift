//
//  Task.swift
//  Listify
//
//  Created by Nikhil D'Mello on 8/10/19.
//  Copyright © 2019 Nikhil D'Mello. All rights reserved.
//

import Foundation

// Conforms to codable protocol in order to encode/decode Tasks
class Task: Codable {
    var title : String = ""
    var completed : Bool = false
}
