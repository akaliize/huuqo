import SwiftUI

struct BigCardView: View {
    let item: ContentItem
    let onPlayTapped: () -> Void
    let onAddToListTapped: () -> Void
    
    @State private var certification: String = ""
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: TMDBService.shared.getImageURL(path: item.backdropURL ?? "", size: .original)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.card)
                    .skeleton()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if let logoPath = item.logoURL {
                    AsyncImage(url: TMDBService.shared.getImageURL(path: logoPath, size: .w500)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } placeholder: {
                        Color.clear
                            .frame(height: 50)
                    }
                } else {
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                
                HStack(spacing: 8) {
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                    
                    if !certification.isEmpty {
                        Text(certification)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                            )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .truncationMode(.tail)
                
                HStack(spacing: 12) {
                    Button(action: onPlayTapped) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("Play")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 140, height: 48)
                        .background(.white)
                        .cornerRadius(12)
                    }
                    
                    Button(action: onAddToListTapped) {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("My List")
                                .fontWeight(.bold)
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 48)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
            .padding(Layout.Padding.standard)
            .background(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0),
                        .init(color: .clear, location: 0.2),
                        .init(color: .black.opacity(0.3), location: 0.4),
                        .init(color: .black.opacity(0.8), location: 0.8),
                        .init(color: .black, location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .frame(width: UIScreen.main.bounds.width - Layout.Padding.standard * 2)
        .frame(height: UIScreen.main.bounds.height * 0.5)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
        .task {
            // Fetch certification based on content type
            if item.type == .movie {
                certification = await TMDBService.shared.getUSCertification(forMovieId: item.tmdbId) ?? ""
            } else {
                certification = await TMDBService.shared.getUSCertification(forTVShowId: item.tmdbId) ?? ""
            }
        }
    }
}

#Preview {
    BigCardView(
        item: ContentItem(
            tmdbId: 1,
            title: "Sample Movie",
            subtitle: "Action",
            imageURL: nil,
            backdropURL: nil,
            type: .movie,
            logoURL: nil
        ),
        onPlayTapped: {},
        onAddToListTapped: {}
    )
    .preferredColorScheme(.dark)
} 