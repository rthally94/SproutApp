//
//  AllModelTypesList.swift
//  Sprout
//
//  Created by Ryan Thally on 7/24/21.
//

import CoreData
import SwiftUI
import SproutKit

struct AllModelTypesList: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel = AllModelTypesViewModel()
    
    var body: some View {
        List(viewModel.counts, id: \.0) { count in
            switch count.1.name {
            case "SproutPlantMO":
                NavigationLink(
                    destination: DataListView<SproutPlantMO>(),
                    label: {
                        VStack(alignment: .leading) {
                            Text(count.1.name ?? "NO NAME")
                            Text("Count: \(count.2)")
                        }
                    })
            case "SproutCareTaskMO":
                NavigationLink(
                    destination: DataListView<SproutCareTaskMO>(),
                    label: {
                        VStack(alignment: .leading) {
                            Text(count.1.name ?? "NO NAME")
                            Text("Count: \(count.2)")
                        }
                    })
            case "SproutCareInformationMO":
                NavigationLink(
                    destination: DataListView<SproutCareInformationMO>(),
                    label: {
                        VStack(alignment: .leading) {
                            Text(count.1.name ?? "NO NAME")
                            Text("Count: \(count.2)")
                        }
                    })
            case "SproutImageDataMO":
                NavigationLink(
                    destination: DataListView<SproutImageDataMO>(),
                    label: {
                        VStack(alignment: .leading) {
                            Text(count.1.name ?? "NO NAME")
                            Text("Count: \(count.2)")
                        }
                    })
            default:
                VStack(alignment: .leading) {
                    Text(count.1.name ?? "NO NAME")
                    Text("Count: \(count.2)")
                }
            }
        }
        .navigationTitle("All Model Types")
        .onAppear {
            viewModel.viewContext = viewContext
            viewModel.fetchCounts()
        }
    }
}

struct AllModelTypesList_Previews: PreviewProvider {
    static let previewStorageProvider = StorageProvider.preview
    
    static var previews: some View {
        NavigationView {
            AllModelTypesList()
        }
        .environment(\.managedObjectContext, previewStorageProvider.persistentContainer.viewContext)
    }
}
