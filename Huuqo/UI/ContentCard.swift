import SwiftUI

struct ContentCard: View {
    let title: String
    let subtitle: String
    let imageAspectRatio: CGFloat
    let imageURL: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            // Image
            AsyncImage(url: imageURL.flatMap { TMDBService.shared.getImageURL(path: $0) }) { image in
                image
                    .resizable()
                    .aspectRatio(imageAspectRatio, contentMode: .fit)
                    .cornerRadius(8)
            } placeholder: {
                Rectangle()
                    .fill(Theme.card)
                    .aspectRatio(imageAspectRatio, contentMode: .fit)
                    .cornerRadius(8)
                    .skeleton()
            }
            
            // Title
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            // Subtitle (split into paragraphs)
            let subtitleParts = subtitle.split(separator: "\n", maxSplits: 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(String(subtitleParts[0]))
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                if subtitleParts.count > 1 {
                    Text(String(subtitleParts[1]))
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ContentCard(
            title: "A Very Long Movie Title That Should Truncate",
            subtitle: "Action, Adventure, Science Fiction",
            imageAspectRatio: 2/3,
            imageURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg"
        )
        .frame(width: 160)
        
        ContentCard(
            title: "Another Long Title That Should Also Truncate Properly",
            subtitle: "Drama, Thriller, Mystery, Crime",
            imageAspectRatio: 2/3,
            imageURL: "/pB8BM7pdSp6B6Ih7QZ4DrQ3PmJK.jpg"
        )
        .frame(width: 160)
    }
    .padding()
    .background(Theme.background)
} 