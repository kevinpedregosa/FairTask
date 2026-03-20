import SwiftUI
import Combine

@MainActor
final class ThemeStore: ObservableObject {
    @Published var color1: Color
    @Published var color2: Color

    let palette: [Color] = [
        .red, .blue, .teal, .mint, .orange, .yellow, .indigo, .green, .cyan, .pink
    ]

    init() {
        self.color1 = palette.randomElement() ?? .blue
        self.color2 = palette.randomElement() ?? .purple
    }

    func randomize() {
        color1 = palette.randomElement() ?? color1
        color2 = palette.randomElement() ?? color2
    }
}
