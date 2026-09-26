//
//  ContentView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 19/9/26.
//

import SwiftUI
import Core

struct TotoItemModel: Identifiable {
    let id: Int = UUID()
    var title: String
    var isDone: Bool = false
}

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
