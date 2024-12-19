import SwiftUI

struct UpcomingSection: View {
    let title: String
    let items: [ContentItem]
    private let cardWidth: CGFloat = Layout.Cards.largeWidth
    
    private func formatReleaseDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "Coming Soon" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else { return "Coming Soon" }
        
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader(
                title: title,
                subtitle: "Stay ahead with upcoming releases"
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            AsyncImage(url: item.imageURL.flatMap { TMDBService.shared.getImageURL(path: $0) }) { phase in
                                switch phase {
                                case .empty:
                                    Rectangle()
                                        .fill(Color(white: 0.15))
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .cornerRadius(10)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .cornerRadius(10)
                                case .failure:
                                    Rectangle()
                                        .fill(Color(white: 0.15))
                                        .aspectRatio(2/3, contentMode: .fit)
                                        .cornerRadius(10)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            Text(item.title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Text(item.subtitle)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            
                            Text(formatReleaseDate(item.releaseDate))
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        .frame(width: cardWidth)
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
                subtitle: "Action",
                imageURL: nil,
                backdropURL: nil,
                type: .movie,
                logoURL: nil,
                releaseDate: "2024-03-15"
            )
        ]
    )
    .preferredColorScheme(.dark)
} 