import SwiftUI

struct BigCardsSection: View {
    let items: [ContentItem]
    let onPlayTapped: () -> Void
    let onAddToListTapped: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Layout.Spacing.standard) {
                ForEach(items.prefix(5)) { item in
                    BigCardView(
                        item: item,
                        onPlayTapped: onPlayTapped,
                        onAddToListTapped: onAddToListTapped
                    )
                }
            }
            .padding(.horizontal, Layout.Padding.standard)
        }
    }
} 