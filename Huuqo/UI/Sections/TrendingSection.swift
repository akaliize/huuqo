import SwiftUI

struct TrendingSection: View {
    let title: String
    let items: [ContentItem]
    var logoName: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader(
                title: title,
                subtitle: "Most watched content this week",
                logoName: logoName
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
    ScrollView {
        VStack(spacing: 20) {
            TrendingSection(
                title: "Regular Section",
                items: []
            )
            
            TrendingSection(
                title: "Netflix",
                items: [],
                logoName: "netflix-logo"
            )
        }
    }
    .preferredColorScheme(.dark)
    .background(Theme.background)
} 