//
//  TodoItemModel.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 29/9/26.
//

import Foundation

struct TodoItemModel: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}
