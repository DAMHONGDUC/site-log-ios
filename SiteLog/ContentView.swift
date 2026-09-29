//
//  ContentView.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 19/9/26.
//

import Core
import SwiftUI

struct TotoItemModel: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}

struct ContentView: View {
    @State private var todos = [
        TotoItemModel(title: "Hoc Toan"),
        TotoItemModel(title: "Hoc Tieng Anh"),
    ]

    var body: some View {
        NavigationStack {
            ForEach($todos) { $todo in
                HStack {
                    Text(todo.title)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
