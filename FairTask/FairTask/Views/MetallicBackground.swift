import SwiftUI

struct MetallicBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.96, green: 0.96, blue: 0.97),
                    Color(red: 0.89, green: 0.90, blue: 0.92),
                    Color(red: 0.98, green: 0.98, blue: 0.99)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.6),
                    Color(red: 0.86, green: 0.86, blue: 0.88).opacity(0.0)
                ],
                center: .topLeading,
                startRadius: 40,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    Color.white.opacity(0.4),
                    Color(red: 0.90, green: 0.91, blue: 0.93).opacity(0.0)
                ],
                center: .bottomTrailing,
                startRadius: 60,
                endRadius: 460
            )
        }
    }
}
