import SwiftUI

enum Tab: String {
    case home = "Home"
    case search = "Search"
    case watchlist = "Watchlist"
}

@Observable @MainActor
class HomeViewModel {
    var isLoading = true
    var trendingMovies: [ContentItem] = []
    var trendingSeries: [ContentItem] = []
    var popularMovies: [ContentItem] = []
    var popularSeries: [ContentItem] = []
    var familyContent: [ContentItem] = []
    var upcomingMovies: [ContentItem] = []
    var upcomingSeries: [ContentItem] = []
    var error: Error?
    var featuredContent: [ContentItem] = []
    
    // Add properties for genre filtered content
    var genreFilteredMovies: [ContentItem] = []
    var genreFilteredSeries: [ContentItem] = []
    var selectedGenreName: String = ""
    var isLoadingGenreContent = false
    
    func loadContent() async {
        isLoading = true
        
        do {
            // First, ensure genres are loaded
            if TMDBService.shared.genres.isEmpty {
                try await TMDBService.shared.fetchGenres()
            }
            
            // Load initial content first (trending and popular)
            async let moviesTask = TMDBService.shared.getTrendingMoviesWithLogos()
            async let seriesTask = TMDBService.shared.getTrendingSeriesWithLogos()
            
            let (allMovies, allSeries) = try await (moviesTask, seriesTask)
            
            // Update UI with initial content
            popularMovies = Array(allMovies.prefix(5))
            trendingMovies = Array(allMovies.dropFirst(5).prefix(15))
            popularSeries = Array(allSeries.prefix(5))
            trendingSeries = Array(allSeries.dropFirst(5).prefix(15))
            
            // Then load additional content
            async let featuredTask = TMDBService.shared.getFeaturedContent()
            async let familyTask = TMDBService.shared.getFamilyContent()
            async let upcomingMoviesTask = TMDBService.shared.getUpcomingMovies()
            async let upcomingSeriesTask = TMDBService.shared.getUpcomingSeries()
            
            let (featured, family, upcoming, upcomingTV) = try await (
                featuredTask,
                familyTask,
                upcomingMoviesTask,
                upcomingSeriesTask
            )
            
            // Update UI with additional content
            featuredContent = featured
            
            // Filter out duplicates
            let usedMovieIds = Set(popularMovies.map { $0.id } + trendingMovies.map { $0.id })
            let usedSeriesIds = Set(popularSeries.map { $0.id } + trendingSeries.map { $0.id })
            
            let uniqueUpcomingMovies = upcoming.filter { !usedMovieIds.contains($0.id) }
            let uniqueUpcomingSeries = upcomingTV.filter { !usedSeriesIds.contains($0.id) }
            
            // Filter family content
            let uniqueFamilyContent = family.filter { content in
                !usedMovieIds.contains(content.id) &&
                !Set(uniqueUpcomingMovies.map { $0.id }).contains(content.id)
            }
            
            familyContent = uniqueFamilyContent
            upcomingMovies = uniqueUpcomingMovies
            self.upcomingSeries = uniqueUpcomingSeries
            
            error = nil
        } catch {
            print("❌ Error loading content: \(error)")
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadContentByGenre(genreId: Int, genreName: String) async {
        isLoadingGenreContent = true
        selectedGenreName = genreName
        
        do {
            async let moviesTask = TMDBService.shared.getPopularMoviesByGenre(genreId: genreId)
            async let seriesTask = TMDBService.shared.getPopularSeriesByGenre(genreId: genreId)
            
            let (movies, series) = try await (moviesTask, seriesTask)
            genreFilteredMovies = movies
            genreFilteredSeries = series
            
            error = nil
        } catch {
            print("❌ Error loading genre content: \(error)")
            self.error = error
        }
        
        isLoadingGenreContent = false
    }
    
    func clearGenreFilter() {
        genreFilteredMovies = []
        genreFilteredSeries = []
        selectedGenreName = ""
    }
}

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    @State private var selectedGenreId: Int?
    @AppStorage("selectedTab") private var selectedTab: Tab = .home
    private let cardWidth: CGFloat = Layout.Cards.largeWidth
    
    private func SkeletonCard(aspectRatio: CGFloat) -> some View {
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
    
    // MARK: - Section Components
    private func SectionHeader(title: String) -> some View {
        Group {
            if viewModel.isLoading {
                Rectangle()
                    .fill(Theme.card)
                    .frame(height: 30)
                    .skeleton()
                    .padding(.horizontal)
            } else {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Theme.text)
                    .padding(.horizontal)
            }
        }
    }
    
    private func ContentSection<Content: View>(
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: title)
            content()
        }
    }
    
    private func HorizontalScrollSection(
        title: String,
        items: [ContentItem],
        aspectRatio: CGFloat
    ) -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader(title: title)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    if viewModel.isLoading {
                        ForEach(0..<5) { _ in
                            SkeletonCard(aspectRatio: aspectRatio)
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
    
    private var genreContent: some View {
        VStack(spacing: 24) {
            if viewModel.isLoadingGenreContent {
                // Skeleton loading state for Movies
                HorizontalScrollSection(
                    title: "What we are watching for \(viewModel.selectedGenreName) Movies",
                    items: [],
                    aspectRatio: 2/3
                )
                .transition(.move(edge: .leading).combined(with: .opacity))
                
                // Skeleton loading state for TV Shows
                HorizontalScrollSection(
                    title: "What we are watching for \(viewModel.selectedGenreName) Shows",
                    items: [],
                    aspectRatio: 2/3
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                if !viewModel.genreFilteredMovies.isEmpty {
                    HorizontalScrollSection(
                        title: "What we are watching for \(viewModel.selectedGenreName) Movies",
                        items: viewModel.genreFilteredMovies,
                        aspectRatio: 2/3
                    )
                    .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                if !viewModel.genreFilteredSeries.isEmpty {
                    HorizontalScrollSection(
                        title: "What we are watching for \(viewModel.selectedGenreName) Shows",
                        items: viewModel.genreFilteredSeries,
                        aspectRatio: 2/3
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
    }
    
    private var homeContent: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    SkeletonView()
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Trending Movies Section first
                            if !viewModel.trendingMovies.isEmpty && selectedGenreId == nil {
                                HorizontalScrollSection(
                                    title: "Trending Movies",
                                    items: viewModel.trendingMovies,
                                    aspectRatio: 2/3
                                )
                                .transition(.opacity)
                            }
                            
                            // Genre Icons Section
                            GenreIconsSection(selectedGenreId: $selectedGenreId)
                            
                            // Show genre filtered content if a genre is selected
                            if selectedGenreId != nil {
                                genreContent
                                    .transition(.opacity)
                            }
                            
                            // Only show these sections if no genre is selected
                            if selectedGenreId == nil {
                                // Big Cards Section (Movies)
                                if !viewModel.popularMovies.isEmpty {
                                    BigCardsSection(
                                        items: viewModel.popularMovies,
                                        onPlayTapped: {},
                                        onAddToListTapped: {}
                                    )
                                    .transition(.opacity)
                                }
                                
                                // Upcoming Movies Section
                                if !viewModel.upcomingMovies.isEmpty {
                                    UpcomingSection(
                                        title: "Upcoming Movies",
                                        items: viewModel.upcomingMovies
                                    )
                                    .transition(.opacity)
                                }
                                
                                // Trending Series Section
                                if !viewModel.trendingSeries.isEmpty {
                                    HorizontalScrollSection(
                                        title: "Trending Series",
                                        items: viewModel.trendingSeries,
                                        aspectRatio: 2/3
                                    )
                                    .transition(.opacity)
                                }
                                
                                // Series Big Cards Section
                                if !viewModel.popularSeries.isEmpty {
                                    BigCardsSection(
                                        items: viewModel.popularSeries,
                                        onPlayTapped: {},
                                        onAddToListTapped: {}
                                    )
                                    .transition(.opacity)
                                }
                                
                                // Upcoming TV Series Section
                                if !viewModel.upcomingSeries.isEmpty {
                                    UpcomingSection(
                                        title: "Upcoming TV Shows & Series",
                                        items: viewModel.upcomingSeries
                                    )
                                    .transition(.opacity)
                                }
                                
                                // Kids & Family Section
                                if !viewModel.familyContent.isEmpty {
                                    KidsAndFamilySection(items: viewModel.familyContent)
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(.bottom, 32)
                        .animation(.smooth, value: selectedGenreId)
                        .animation(.smooth, value: viewModel.isLoadingGenreContent)
                    }
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadContent()
        }
        .onChange(of: selectedGenreId) { oldValue, newValue in
            Task {
                if let genreId = newValue {
                    // Find the genre name from GenreIconsSection's genres array
                    if let genreName = GenreIconsSection.genres.first(where: { $0.id == genreId })?.name {
                        withAnimation {
                            viewModel.clearGenreFilter() // Clear old content first
                        }
                        await viewModel.loadContentByGenre(genreId: genreId, genreName: genreName)
                    }
                } else {
                    withAnimation {
                        viewModel.clearGenreFilter()
                    }
                }
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue == .home {
                // Reset the view when returning to home tab
                withAnimation {
                    selectedGenreId = nil
                    viewModel.clearGenreFilter()
                }
            }
        }
    }
    
    var body: some View {
        homeContent
    }
}

#Preview {
    HomeView()
        .preferredColorScheme(.dark)
} 