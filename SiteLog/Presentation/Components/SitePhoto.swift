// Placeholder until real photos are loaded

import SystemDesign
import SwiftUI

struct SitePhoto: View {
    // Unused by the placeholder
    var variant: Int = 0
    var showsCrack: Bool = false

    var body: some View {
        Rectangle()
            .fill(SDColor.lineStrong)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(SDColor.textSecondary)
            }
    }
}

struct SitePhotoThumb: View {
    var variant: Int = 0
    var size: CGFloat = 48
    var showsCrack: Bool = false

    var body: some View {
        SitePhoto(variant: variant, showsCrack: showsCrack)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: SDRadius.small))
    }
}

#Preview {
    VStack {
        SitePhoto()
            .frame(height: 250)
        SitePhotoThumb()
    }
}
