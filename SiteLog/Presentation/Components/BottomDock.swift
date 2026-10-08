import DesignSystem
import SwiftUI

private struct BottomDockModifier<Dock: View>: ViewModifier {
    let showsBackground: Bool
    let dock: Dock

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack {
                    dock
                }
                .padding()
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
    func bottomDock<Dock: View>(showsBackground: Bool = true, @ViewBuilder _ dock: () -> Dock) -> some View {
        modifier(BottomDockModifier(showsBackground: showsBackground, dock: dock()))
    }
}
