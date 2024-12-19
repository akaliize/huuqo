import SwiftUI

struct TrendingSection: View {
    let title: String
    let items: [ContentItem]
    let isLoading: Bool
    let logoName: String?
    private let cardWidth: CGFloat = Layout.Cards.largeWidth
    
    init(title: String, items: [ContentItem], isLoading: Bool = false, logoName: String? = nil) {
        self.title = title
        self.items = items
        self.isLoading = isLoading
        self.logoName = logoName
    }
    
    private func SkeletonCard() -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            Rectangle()
                .fill(Color(white: 0.15))
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Loading...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .redacted(reason: .placeholder)
                
                Text("Loading...")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .redacted(reason: .placeholder)
            }
        }
        .frame(width: cardWidth)
    }
    
    private var headerView: some View {
        HStack(spacing: 12) {
            if let logoName = logoName {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 30)
            } else {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Theme.text)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            if isLoading {
                Rectangle()
                    .fill(Theme.card)
                    .frame(height: 30)
                    .skeleton()
                    .padding(.horizontal)
            } else {
                headerView
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    if isLoading {
                        ForEach(0..<5) { _ in
                            SkeletonCard()
                        }
                    } else {
                        ForEach(items) { item in
                            MovieCard(item: item)
                                .frame(width: cardWidth)
                        }
                    }
                }
                .padding(.horizontal, Layout.Padding.standard)
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        TrendingSection(
            title: "Trending Movies",
            items: [],
            isLoading: true
        )
        
        TrendingSection(
            title: "Netflix",
            items: [],
            logoName: "netflix-logo"
        )
    }
    .preferredColorScheme(.dark)
} 