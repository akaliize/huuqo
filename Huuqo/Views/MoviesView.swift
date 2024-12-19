import SwiftUI

struct MoviesView: View {
    @State private var searchText = ""
    @State private var showSearchResults = false
    @State private var isLoading = true
    @State private var popularMovies: [ContentItem] = []
    @State private var allMovies: [ContentItem] = []
    @State private var netflixMovies: [ContentItem] = []
    @State private var huluMovies: [ContentItem] = []
    @State private var primeMovies: [ContentItem] = []
    @State private var appleTVMovies: [ContentItem] = []
    @State private var peacockMovies: [ContentItem] = []
    @State private var videolandMovies: [ContentItem] = []
    @State private var disneyMovies: [ContentItem] = []
    @State private var paramountMovies: [ContentItem] = []
    @State private var upcomingMovies: [ContentItem] = []
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Search Bar
                    SearchBarButton(action: { showSearchResults = true })
                        .padding(.horizontal)
                    
                    if !isLoading {
                        // Regular Content
                        if !popularMovies.isEmpty {
                            BigCardsSection(
                                items: popularMovies,
                                onPlayTapped: {},
                                onAddToListTapped: {}
                            )
                        }
                        
                        // All Movies Grid
                        if !allMovies.isEmpty {
                            TrendingSection(
                                title: "Trending Movies",
                                items: allMovies
                            )
                        }
                        
                        // Streaming Provider Sections
                        if !netflixMovies.isEmpty {
                            TrendingSection(
                                title: "Netflix",
                                items: netflixMovies,
                                logoName: "netflix-logo"
                            )
                        }
                        
                        if !huluMovies.isEmpty {
                            TrendingSection(
                                title: "Hulu",
                                items: huluMovies,
                                logoName: "hulu-logo"
                            )
                        }
                        
                        if !primeMovies.isEmpty {
                            TrendingSection(
                                title: "Prime Video",
                                items: primeMovies,
                                logoName: "amazon-prime-logo"
                            )
                        }
                        
                        if !appleTVMovies.isEmpty {
                            TrendingSection(
                                title: "Apple TV+",
                                items: appleTVMovies,
                                logoName: "apple-tv-logo"
                            )
                        }
                        
                        if !peacockMovies.isEmpty {
                            TrendingSection(
                                title: "Peacock",
                                items: peacockMovies,
                                logoName: "peacock-logo"
                            )
                        }
                        
                        if !videolandMovies.isEmpty {
                            TrendingSection(
                                title: "Videoland",
                                items: videolandMovies,
                                logoName: "videoland-logo"
                            )
                        }
                        
                        if !disneyMovies.isEmpty {
                            TrendingSection(
                                title: "Disney+",
                                items: disneyMovies,
                                logoName: "disney-plus-logo"
                            )
                        }
                        
                        if !paramountMovies.isEmpty {
                            TrendingSection(
                                title: "Paramount+",
                                items: paramountMovies,
                                logoName: "paramount-plus-logo"
                            )
                        }
                        
                        if !upcomingMovies.isEmpty {
                            TrendingSection(
                                title: "Upcoming Movies",
                                items: upcomingMovies
                            )
                        }
                    } else {
                        // Loading state
                        loadingGridView()
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Movies")
            .sheet(isPresented: $showSearchResults) {
                MovieSearchView(isPresented: $showSearchResults)
            }
        }
        .task {
            await loadAllContent()
        }
    }
    
    @ViewBuilder
    private func loadingGridView() -> some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(0..<10) { _ in
                VStack {
                    Rectangle()
                        .fill(Theme.card)
                        .aspectRatio(2/3, contentMode: .fit)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Theme.card, lineWidth: 1)
                        )
                        .skeleton()
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Rectangle()
                            .fill(Theme.card)
                            .frame(height: 20)
                            .skeleton()
                        
                        Rectangle()
                            .fill(Theme.card)
                            .frame(height: 16)
                            .skeleton()
                    }
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func loadAllContent() async {
        isLoading = true
        do {
            // First fetch genres if they're not already loaded
            if TMDBService.shared.genres.isEmpty {
                try await TMDBService.shared.fetchGenres()
            }
            
            // Load trending movies
            let movies = try await TMDBService.shared.getTrendingMoviesWithLogos()
            popularMovies = Array(movies.prefix(5))
            allMovies = Array(movies.dropFirst(5))
            
            // Load upcoming movies
            async let upcoming = TMDBService.shared.getUpcomingMovies()
            
            // Load streaming provider movies in parallel
            async let netflix = TMDBService.shared.getMoviesByProvider(providerId: 8, region: "US", page: 1)
            async let hulu = TMDBService.shared.getMoviesByProvider(providerId: 15, region: "US", page: 2)
            async let prime = TMDBService.shared.getMoviesByProvider(providerId: 9, region: "US", page: 3)
            async let appleTV = TMDBService.shared.getMoviesByProvider(providerId: 350, region: "US", page: 4)
            async let peacock = TMDBService.shared.getMoviesByProvider(providerId: 386, region: "US", page: 1)
            async let videoland = TMDBService.shared.getMoviesByProvider(providerId: 563, region: "NL", page: 1)
            async let disney = TMDBService.shared.getMoviesByProvider(providerId: 337, region: "US", page: 2)
            async let paramount = TMDBService.shared.getMoviesByProvider(providerId: 531, region: "US", page: 1)
            
            // Await all results
            (upcomingMovies, netflixMovies, huluMovies, primeMovies, appleTVMovies,
             peacockMovies, videolandMovies, disneyMovies, paramountMovies) = try await (
                upcoming, netflix, hulu, prime, appleTV,
                peacock, videoland, disney, paramount
            )
            
            // Add debug print for Paramount+ results
            print("📱 Paramount+ movies count: \(paramountMovies.count)")
        } catch {
            print("Error loading content: \(error)")
        }
        isLoading = false
    }
}

#Preview {
    MoviesView()
        .preferredColorScheme(.dark)
} 