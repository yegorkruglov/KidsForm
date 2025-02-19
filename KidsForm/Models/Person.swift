//
//  Person.swift
//  KidsForm
//
//  Created by Egor Kruglov on 18.02.2025.
//

import Foundation

struct Person: Hashable {
    let id: UUID = UUID()
    let name: String
    let age: String
}
