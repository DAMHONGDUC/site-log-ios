//
//  AppMark.swift
//  SiteLog
//
//  Placeholder app mark for the access screens: a yellow tile.
//  Swap for the real icon from docs/design/app-icon/.
//

import DesignSystem
import SwiftUI

struct AppMark: View {
    var size: CGFloat = 72

    var body: some View {
        RoundedRectangle(cornerRadius: DSRadius.large)
            .fill(DSColor.hiVis)
            .frame(width: size, height: size)
    }
}

#Preview {
    AppMark()
}
