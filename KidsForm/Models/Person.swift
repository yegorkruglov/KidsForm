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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(age)
    }
}
