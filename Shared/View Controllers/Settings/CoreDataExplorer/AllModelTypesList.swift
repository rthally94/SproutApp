//
//  AllModelTypesList.swift
//  Sprout
//
//  Created by Ryan Thally on 7/24/21.
//

import SwiftUI
import SproutKit

struct AllModelTypesList: View {
    @Environment(\.managedObjectContext) var viewContext
    @StateObject var viewModel = AllModelTypesViewModel()
    
    var body: some View {
        List(viewModel.counts, id: \.0) { count in
            VStack(alignment: .leading) {
                Text(count.0)
                Text("Count: \(count.1)")
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
