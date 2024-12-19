import SwiftUI

struct GenreContentSection: View {
    let genreName: String
    let movies: [ContentItem]
    let series: [ContentItem]
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            if isLoading {
                // Skeleton loading state for Movies
                TrendingSection(
                    title: "What we are watching for \(genreName) Movies",
                    items: [],
                    isLoading: true
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
                
                // Skeleton loading state for TV Shows
                TrendingSection(
                    title: "What we are watching for \(genreName) Shows",
                    items: [],
                    isLoading: true
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                if !movies.isEmpty {
                    TrendingSection(
                        title: "What we are watching for \(genreName) Movies",
                        items: movies
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                if !series.isEmpty {
                    TrendingSection(
                        title: "What we are watching for \(genreName) Shows",
                        items: series
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
    }
}

#Preview {
    GenreContentSection(
        genreName: "Action",
        movies: [],
        series: [],
        isLoading: true
    )
    .preferredColorScheme(.dark)
} 