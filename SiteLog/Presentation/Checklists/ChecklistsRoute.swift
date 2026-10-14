import SwiftUI

enum ChecklistsRoute: Hashable {
    case templatePicker
    // nil: the default checklist
    case run(title: String?)
    case done
}

extension View {
    func checklistsDestinations() -> some View {
        navigationDestination(for: ChecklistsRoute.self) { route in
            switch route {
            case .templatePicker:
                TemplatePickerScreen()
            case .run(let title):
                if let title {
                    ChecklistRunScreen(title: title)
                } else {
                    ChecklistRunScreen()
                }
            case .done:
                ChecklistDoneScreen()
            }
        }
    }
}
