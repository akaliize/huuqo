import SwiftUI

struct HeroSection: View {
    let items: [ContentItem]
    let onPlayTapped: (ContentItem) -> Void
    let onAddToListTapped: (ContentItem) -> Void
    
    @State private var currentIndex = 0
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HeroCard(
                    item: item,
                    onPlayTapped: { onPlayTapped(item) },
                    onAddToListTapped: { onAddToListTapped(item) }
                )
                .tag(index)
            }
        }
        .tabViewStyle(.page)
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.7)
        .edgesIgnoringSafeArea(.all)
    }
}

struct HeroCard: View {
    let item: ContentItem
    let onPlayTapped: () -> Void
    let onAddToListTapped: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background Image
                AsyncImage(url: TMDBService.shared.getImageURL(path: item.backdropURL ?? "", size: .original)) { image in
                    ZStack {
                        // Main backdrop image
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                        
                        // Glossy blur gradient overlay
                        VStack(spacing: 0) {
                            Spacer()
                            Rectangle()
                                .fill(.clear)
                                .background {
                                    // Blurred copy of the image
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .blur(radius: 25)
                                }
                                .overlay {
                                    // Gradient for glossy effect
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            .clear,
                                            Color.black.opacity(0.15),
                                            Color.black.opacity(0.4)
                                        ]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                }
                                .frame(height: 200)
                                .background(.ultraThinMaterial.opacity(0.2))
                        }
                        .padding(.bottom, -60)
                        .ignoresSafeArea(.all)
                    }
                } placeholder: {
                    Rectangle()
                        .fill(Theme.card)
                        .skeleton()
                }
                
                // Content
                VStack(spacing: 16) {
                    Spacer()
                    // Logo or Title
                    if let logoPath = item.logoURL {
                        AsyncImage(url: TMDBService.shared.getImageURL(path: logoPath, size: .w500)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        } placeholder: {
                            Text(item.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    } else {
                        Text(item.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Genre/Info
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 60)
                .padding(.horizontal)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
} 