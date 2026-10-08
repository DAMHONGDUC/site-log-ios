//
//  SitePhoto.swift
//  SiteLog
//
//  Placeholder for a site photo: a grey box with a photo icon.
//  The mockups draw flat room scenes here; replace with the real image later.
//

import DesignSystem
import SwiftUI

struct SitePhoto: View {
    // Kept so call sites don't change; the placeholder ignores them
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

// Square photo thumbnail (list rows)
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
