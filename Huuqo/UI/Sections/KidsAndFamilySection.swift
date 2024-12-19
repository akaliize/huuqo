import SwiftUI

struct KidsAndFamilySection: View {
    let items: [ContentItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader(
                title: "Kids & Family",
                subtitle: "Family-friendly entertainment for everyone"
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    ForEach(items) { item in
                        ContentCard(
                            title: item.title,
                            subtitle: item.subtitle,
                            imageAspectRatio: 2/3,
                            imageURL: item.imageURL
                        )
                        .frame(width: Layout.Cards.largeWidth)
                    }
                }
                .padding(.horizontal, Layout.Padding.standard)
            }
        }
    }
}

#Preview {
    KidsAndFamilySection(
        items: [
            ContentItem(
                tmdbId: 1,
                title: "Family Movie 1",
                subtitle: "Animation, Adventure",
                imageURL: nil,
                backdropURL: nil,
                type: .movie,
                logoURL: nil
            ),
            ContentItem(
                tmdbId: 2,
                title: "Family Movie 2",
                subtitle: "Comedy, Family",
                imageURL: nil,
                backdropURL: nil,
                type: .movie,
                logoURL: nil
            )
        ]
    )
    .background(Theme.background)
} 