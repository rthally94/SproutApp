//
//  Plant.swift
//  GrowApp
//
//  Created by Ryan Thally on 1/15/21.
//

import Foundation

class Plant: Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        lhs.id == rhs.id
    }
    
    private(set) var id = UUID()
    private(set) var careDates = [Date]()
    
    //MARK:- Intents
    func logCare() {
        careDates.append(Date())
    }
    
    var nextCareDate: Date {
        if let lastDate = careDates.last, let next = Calendar.current.date(byAdding: .day, value: 1, to: lastDate) {
            return Calendar.current.startOfDay(for: next)
        } else {
            return Calendar.current.startOfDay(for: Date())
        }
    }
}
