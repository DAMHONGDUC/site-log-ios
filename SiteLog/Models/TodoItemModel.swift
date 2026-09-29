import Foundation

struct TodoItemModel: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}
