//
//  RemindersProvider.swift
//  GrowApp
//
//  Created by Ryan Thally on 5/21/21.
//

import CoreData
import Combine
import Foundation

class ReminderNotificationProvider: NSObject {
    let moc: NSManagedObjectContext
    
    @Published var data: [Date: [SproutCareTaskMO]]?
    private let request: NSFetchRequest<SproutCareTaskMO> = {
        let request = SproutCareTaskMO.remindersFetchRequest()
        request.propertiesToGroupBy = [
            \SproutCareTaskMO.statusDate
        ]
        request.resultType = .dictionaryResultType
        return request
    }()

    init(managedObjectContext: NSManagedObjectContext) {
        self.moc = managedObjectContext
        super.init()

        updateData()

        NotificationCenter.default.addObserver(self, selector: #selector(contextDidSave), name: .NSManagedObjectContextDidSave, object: moc)
    }

    @objc private func contextDidSave() {
        updateData()
    }
    
    func updateData() {
        let data = try? moc.fetch(request)
        print("--- Start Display Data ---")
        print(data)
        print("--- END Display Data ---")
    }
}
