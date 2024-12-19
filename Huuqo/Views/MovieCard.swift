import SwiftUI

struct MovieCard: View {
    let item: ContentItem
    
    var body: some View {
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
        }
    }
}

#Preview {
    MovieCard(item: ContentItem(
        tmdbId: 1,
        title: "Sample Movie",
        subtitle: "Action, Adventure",
        imageURL: nil,
        backdropURL: nil,
        type: .movie,
        logoURL: nil,
        releaseDate: "2024-03-15"
    ))
    .frame(width: 150)
    .padding()
    .background(Color.black)
} 