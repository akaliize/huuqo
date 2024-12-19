import SwiftUI

struct UpcomingSection: View {
    let title: String
    let items: [ContentItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader(
                title: title,
                subtitle: "Coming soon to your screens"
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
    UpcomingSection(
        title: "Upcoming Movies",
        items: [
            ContentItem(
                tmdbId: 1,
                title: "Sample Movie",
                subtitle: "Available soon\nMarch 15, 2024",
                imageURL: nil,
                backdropURL: nil,
                type: .movie,
                logoURL: nil
            ),
            ContentItem(
                tmdbId: 2,
                title: "Sample Series",
                subtitle: "Airing on\nMarch 20, 2024",
                imageURL: nil,
                backdropURL: nil,
                type: .series,
                logoURL: nil
            )
        ]
    )
    .background(Theme.background)
} 