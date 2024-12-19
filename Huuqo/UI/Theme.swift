import SwiftUI

enum Theme {
    static let background = Color.black
    static let accent = Color.orange
    static let card = Color(white: 0.15)
    static let secondaryCard = Color(white: 0.1)
    static let text = Color.white
    static let secondaryText = Color.gray
    
    static let cardBlur: CGFloat = 10
    static let cardOpacity: CGFloat = 0.15
    
    static let tabBarBackground = Color(white: 0.1)
}

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.card)
                    .opacity(Theme.cardOpacity)
                    .blur(radius: Theme.cardBlur)
            }
    }
}

extension View {
    func glassBackground() -> some View {
        modifier(GlassBackground())
    }
} 