import Core
import Inject
import SwiftUI

struct ContentView: View {
    @ObserveInjection var inject

    @State private var todos = [
        TodoItemModel(title: "Hoc Toan 2"),
        TodoItemModel(title: "Hoc Tieng Anh"),
    ]

    var body: some View {
        NavigationStack {
            List(todos) { todo in
                Text(todo.title)
                Text(todo.title)
                Text(todo.title)
                Text(todo.title)
                Text(todo.title)
            }
            .navigationTitle("Todo")
        }
        .enableInjection()
    }
}

#Preview {
    ContentView()
}
