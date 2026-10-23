import DesignSystem
import SwiftUI

private struct BottomDockModifier<Dock: View>: ViewModifier {
    let showsBackground: Bool
    let dock: Dock

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: DSSpacing.spacing0) {
                VStack {
                    dock
                }
                .padding(DSSpacing.spacing16)
                .background {
                    if showsBackground {
                        DSColor.raised
                            .ignoresSafeArea()
                    }
                }
            }
    }
}

extension View {
    func bottomDock<Dock: View>(
        showsBackground: Bool = true,
        @ViewBuilder _ dock: () -> Dock
    ) -> some View {
        modifier(BottomDockModifier(showsBackground: showsBackground, dock: dock()))
    }
}
