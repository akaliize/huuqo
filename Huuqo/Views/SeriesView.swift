import SwiftUI

struct SeriesView: View {
    @State private var selectedSeries: ContentItem?
    @State private var popularSeries: [ContentItem] = []
    @State private var allSeries: [ContentItem] = []
    @State private var isLoading = true
    @State private var showSearchResults = false
    @State private var netflixSeries: [ContentItem] = []
    @State private var huluSeries: [ContentItem] = []
    @State private var primeSeries: [ContentItem] = []
    @State private var appleTVSeries: [ContentItem] = []
    @State private var peacockSeries: [ContentItem] = []
    @State private var videolandSeries: [ContentItem] = []
    @State private var disneySeries: [ContentItem] = []
    @State private var paramountSeries: [ContentItem] = []
    @State private var upcomingSeries: [ContentItem] = []
    
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
                        if !popularSeries.isEmpty {
                            BigCardsSection(
                                items: popularSeries,
                                onPlayTapped: {},
                                onAddToListTapped: {}
                            )
                        }
                        
                        // All Series Grid
                        if !allSeries.isEmpty {
                            TrendingSection(
                                title: "Trending Series",
                                items: allSeries
                            )
                        }
                        
                        // Streaming Provider Sections
                        if !netflixSeries.isEmpty {
                            TrendingSection(
                                title: "Netflix",
                                items: netflixSeries,
                                logoName: "netflix-logo"
                            )
                        }
                        
                        if !huluSeries.isEmpty {
                            TrendingSection(
                                title: "Hulu",
                                items: huluSeries,
                                logoName: "hulu-logo"
                            )
                        }
                        
                        if !primeSeries.isEmpty {
                            TrendingSection(
                                title: "Prime Video",
                                items: primeSeries,
                                logoName: "amazon-prime-logo"
                            )
                        }
                        
                        if !appleTVSeries.isEmpty {
                            TrendingSection(
                                title: "Apple TV+",
                                items: appleTVSeries,
                                logoName: "apple-tv-logo"
                            )
                        }
                        
                        if !peacockSeries.isEmpty {
                            TrendingSection(
                                title: "Peacock",
                                items: peacockSeries,
                                logoName: "peacock-logo"
                            )
                        }
                        
                        if !videolandSeries.isEmpty {
                            TrendingSection(
                                title: "Videoland",
                                items: videolandSeries,
                                logoName: "videoland-logo"
                            )
                        }
                        
                        if !disneySeries.isEmpty {
                            TrendingSection(
                                title: "Disney+",
                                items: disneySeries,
                                logoName: "disney-plus-logo"
                            )
                        }
                        
                        if !paramountSeries.isEmpty {
                            TrendingSection(
                                title: "Paramount+",
                                items: paramountSeries,
                                logoName: "paramount-plus-logo"
                            )
                        }
                        
                        // Upcoming Series Section
                        if !upcomingSeries.isEmpty {
                            UpcomingSection(
                                title: "Upcoming TV Shows & Series",
                                items: upcomingSeries
                            )
                        }
                    } else {
                        // Loading state
                        loadingGridView()
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("TV Series")
            .sheet(isPresented: $showSearchResults) {
                SeriesSearchView(isPresented: $showSearchResults)
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
            print("📱 SeriesView - Starting to load content")
            
            // First fetch genres if they're not already loaded
            if TMDBService.shared.genres.isEmpty {
                try await TMDBService.shared.fetchGenres()
            }
            
            // Load trending series
            let series = try await TMDBService.shared.getTrendingSeriesWithLogos()
            popularSeries = Array(series.prefix(5))
            allSeries = Array(series.dropFirst(5))
            
            print("📱 SeriesView - Loaded trending series. Popular: \(popularSeries.count), All: \(allSeries.count)")
            
            // Load upcoming series and streaming provider series in parallel
            print("📱 SeriesView - Starting to fetch upcoming series...")
            async let upcomingTask = TMDBService.shared.getUpcomingSeries()
            async let netflix = TMDBService.shared.getSeriesByProvider(providerId: 8, region: "US", page: 1)
            async let hulu = TMDBService.shared.getSeriesByProvider(providerId: 15, region: "US", page: 2)
            async let prime = TMDBService.shared.getSeriesByProvider(providerId: 9, region: "US", page: 3)
            async let appleTV = TMDBService.shared.getSeriesByProvider(providerId: 350, region: "US", page: 4)
            async let peacock = TMDBService.shared.getSeriesByProvider(providerId: 386, region: "US", page: 1)
            async let videoland = TMDBService.shared.getSeriesByProvider(providerId: 563, region: "NL", page: 1)
            async let disney = TMDBService.shared.getSeriesByProvider(providerId: 337, region: "US", page: 2)
            async let paramount = TMDBService.shared.getSeriesByProvider(providerId: 531, region: "US", page: 1)
            
            // Await all results
            print("📱 SeriesView - Awaiting all API results...")
            let (upcoming, netflixResult, huluResult, primeResult, appleTVResult,
                 peacockResult, videolandResult, disneyResult, paramountResult) = try await (
                upcomingTask, netflix, hulu, prime, appleTV,
                peacock, videoland, disney, paramount
            )
            print("📱 SeriesView - All API calls completed")
            
            // Filter out duplicates from upcoming series
            let usedSeriesIds = Set(popularSeries.map { $0.tmdbId } + allSeries.map { $0.tmdbId })
            upcomingSeries = upcoming.filter { !usedSeriesIds.contains($0.tmdbId) }
            
            // Assign streaming provider results
            netflixSeries = netflixResult
            huluSeries = huluResult
            primeSeries = primeResult
            appleTVSeries = appleTVResult
            peacockSeries = peacockResult
            videolandSeries = videolandResult
            disneySeries = disneyResult
            paramountSeries = paramountResult
            
            print("📱 SeriesView - Content loaded:")
            print("  - Upcoming series: \(upcomingSeries.count)")
            if !upcomingSeries.isEmpty {
                print("  - First upcoming series: \(upcomingSeries[0].title) - \(upcomingSeries[0].subtitle)")
                print("  - Last upcoming series: \(upcomingSeries[upcomingSeries.count - 1].title) - \(upcomingSeries[upcomingSeries.count - 1].subtitle)")
            }
            print("  - Netflix series: \(netflixSeries.count)")
            print("  - Hulu series: \(huluSeries.count)")
            print("  - Prime series: \(primeSeries.count)")
            print("  - Apple TV+ series: \(appleTVSeries.count)")
            print("  - Peacock series: \(peacockSeries.count)")
            print("  - Videoland series: \(videolandSeries.count)")
            print("  - Disney+ series: \(disneySeries.count)")
            print("  - Paramount+ series: \(paramountSeries.count)")
            
            if upcomingSeries.isEmpty {
                print("⚠️ SeriesView - No upcoming series found!")
                print("⚠️ SeriesView - This might indicate an issue with the API response or date filtering")
            }
        } catch {
            print("❌ SeriesView - Error loading content: \(error)")
            print("❌ SeriesView - Error details: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

#Preview {
    SeriesView()
        .preferredColorScheme(.dark)
} 