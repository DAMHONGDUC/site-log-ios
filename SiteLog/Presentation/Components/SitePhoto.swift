// Placeholder until real photos are loaded

import DesignSystem
import SwiftUI

struct SitePhoto: View {
    // Unused by the placeholder
    var variant: Int = 0
    var showsCrack: Bool = false

    var body: some View {
        Rectangle()
            .fill(DSColor.lineStrong)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(DSColor.textSecondary)
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
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.small))
    }
}

#Preview {
    VStack {
        SitePhoto()
            .frame(height: 250)
        SitePhotoThumb()
    }
}
