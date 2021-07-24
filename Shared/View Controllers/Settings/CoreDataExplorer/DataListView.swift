//
//  DataListView.swift
//  Sprout
//
//  Created by Ryan Thally on 7/24/21.
//

import CoreData
import SproutKit
import SwiftUI

struct DataListView<ObjectType: NSManagedObject>: View {
    @FetchRequest(entity: ObjectType.entity(), sortDescriptors: []) var objects: FetchedResults<ObjectType>
    
    var body: some View {
        VStack {
            if objects.isEmpty {
                Text("Not Objects")
            } else {
                List(objects, id: \.self) { object in
                    Text(object.description)
                }
            }
        }
        .navigationTitle(ObjectType.entity().name ?? "NO NAME")
    }
}

struct DataListView_Previews: PreviewProvider {
    static let storageProvider = StorageProvider.preview
    
    static var previews: some View {
        NavigationView {
            DataListView<SproutPlantMO>()
        }
        .environment(\.managedObjectContext, storageProvider.persistentContainer.viewContext)
    }
}
