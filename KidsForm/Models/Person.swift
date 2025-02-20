//
//  Person.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import Foundation

struct Person: Hashable {
    let id: UUID = UUID()
    var name: String
    var age: String
    
    static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
