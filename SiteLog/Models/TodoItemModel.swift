//
//  Untitled.swift
//  SiteLog
//
//  Created by Duc Dam Dev on 29/9/26.
//

import Core
import Inject
import SwiftUI

struct TodoItemModel: Identifiable {
    let id = UUID()
    var title: String
    var isDone: Bool = false
}
