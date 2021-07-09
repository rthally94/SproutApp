//
//  SampleData.swift
//  Sprout
//
//  Created by Ryan Thally on 7/7/21.
//

import SwiftUI

struct SampleData: View {
    @Binding var isVisible: Bool
    @Binding var currentPage: Int
    
    var body: some View {
        PageView {
            Header(image: makeIconImage(), title: Text("Load Sample Plants"), subtitle: Text("Start with some sample data\nto see how the app works."))
        } controls: {
            buttons()
        }

    }
    
    fileprivate func makeIconImage() -> some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.green)
    }
    
    fileprivate func buttons() -> some View {
        return VStack {
            Button(action: loadSampleData, label: {
                Label("Load Sample Plants", systemImage: "opticaldiscdrive.fill")
                    .labelStyle(TitleOnlyLabelStyle())
                    .labelStyle(TitleOnlyLabelStyle())
                    .frame(maxWidth: .infinity)
                    .font(.title3.bold())
                    .padding()
            })
            .accentColor(.white)
            .background(Capsule().foregroundColor(.green))
            
            Button(action: dismissSetup, label: {
                Label("Start New", systemImage: "text.badge.plus")
            })
            .font(.title3.bold())
            .padding()
        }
    }
    
    private func loadSampleData() {
        AppDelegate.storageProvider.loadSampleData()
        dismissSetup()
    }
    
    private func dismissSetup() {
        isVisible = false
    }
}

struct SampleData_Previews: PreviewProvider {
    static var previews: some View {
        SampleData(isVisible: .constant(true), currentPage: .constant(2))
    }
}
