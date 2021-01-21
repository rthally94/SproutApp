//
//  Plant.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation

class Plant: Hashable, Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
            && lhs.careDates == rhs.careDates
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(careDates)
    }
    
    
    
    private(set) var id = UUID()
    private(set) var careDates = [Date]()
    
    //MARK:- Intents
    func logCare() {
        logCare(on: Date())
    }
    
    func logCare(on date: Date) {
        careDates.append(date)
    }
    
    var nextCareDate: Date {
        if let lastDate = careDates.last, let next = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) {
            return Calendar.current.startOfDay(for: next)
        } else {
            return Calendar.current.startOfDay(for: Date())
        }
    }
}
