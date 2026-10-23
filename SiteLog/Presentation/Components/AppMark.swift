// Placeholder until the app icon asset is added

import DesignSystem
import SwiftUI

struct AppMark: View {
    var size: CGFloat = 72

    var body: some View {
        RoundedRectangle(cornerRadius: DSSpacing.spacing16)
            .fill(DSColor.hiVis)
            .frame(width: size, height: size)
    }
}

#Preview {
    AppMark()
}
