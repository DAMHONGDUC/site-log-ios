import SystemDesign
import SnapshotTesting
import SwiftUI
import Testing

// First run records the reference images and fails; run again and it passes.
// References live next to this file in __Snapshots__/ and are committed.
@MainActor
struct SystemDesignSnapshotTests {
    @Test(arguments: [ColorScheme.light, ColorScheme.dark])
    func gallery(scheme: ColorScheme) {
        let view = SDGallery()
            .environment(\.colorScheme, scheme)
        let controller = UIHostingController(rootView: view)

        assertSnapshot(of: controller, as: .image(on: .iPhone13Pro), named: "\(scheme)")
    }
}