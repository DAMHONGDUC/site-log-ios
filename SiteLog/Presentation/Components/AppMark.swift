// Placeholder until the app icon asset is added

import SwiftUI
import SystemDesign

struct AppMark: View {
    var size: CGFloat = 72

    var body: some View {
        RoundedRectangle(cornerRadius: SDRadius.large)
            .fill(SDColor.hiVis)
            .frame(width: size, height: size)
    }
}

#Preview {
    AppMark()
}
