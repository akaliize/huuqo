import SwiftUI

struct MovieSearchView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var searchResults: [ContentItem] = []
    @State private var recommendedMovies: [ContentItem] = []
    @State private var isSearching = false
    @State private var isLoadingMore = false
    @State private var currentPage = 1
    @State private var totalPages = 1
    @State private var hasMoreResults = true
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                VStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search movies...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .onChange(of: searchText) { oldValue, newValue in
                                Task {
                                    await performSearch()
                                }
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.15))
                    .cornerRadius(10)
                    .padding()
                    
                    ScrollView {
                        if searchText.isEmpty {
                            // Show recommended movies when not searching
                            VStack(alignment: .leading) {
                                Text("Recommended Movies")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    if recommendedMovies.isEmpty {
                                        ForEach(0..<10) { _ in
                                            SkeletonMovieCard()
                                        }
                                    } else {
                                        ForEach(recommendedMovies) { movie in
                                            MovieCard(item: movie)
                                        }
                                    }
                                }
                            }
                            .padding()
                        } else {
                            LazyVGrid(columns: columns, spacing: 16) {
                                if isSearching && searchResults.isEmpty {
                                    // Show skeleton loading for initial search
                                    ForEach(0..<10) { _ in
                                        SkeletonMovieCard()
                                    }
                                } else {
                                    ForEach(searchResults) { movie in
                                        MovieCard(item: movie)
                                            .onAppear {
                                                if movie == searchResults.last && hasMoreResults && !isLoadingMore {
                                                    Task {
                                                        await loadMoreResults()
                                                    }
                                                }
                                            }
                                    }
                                    
                                    // Show skeleton loading when loading more results
                                    if isLoadingMore {
                                        ForEach(0..<4) { _ in
                                            SkeletonMovieCard()
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white)
                }
            }
            .task {
                await loadRecommendedMovies()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        currentPage = 1
        searchResults = [] // Clear previous results
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // Add small delay for better UX
            let result = try await TMDBService.shared.searchAllMovies(query: searchText, page: currentPage)
            searchResults = result.movies
            totalPages = result.totalPages
            hasMoreResults = currentPage < totalPages
        } catch {
            print("Search error: \(error)")
        }
        
        isSearching = false
    }
    
    private func loadMoreResults() async {
        guard !isLoadingMore && hasMoreResults else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            try await Task.sleep(nanoseconds: 300_000_000) // Add small delay for better UX
            let result = try await TMDBService.shared.searchAllMovies(query: searchText, page: currentPage)
            searchResults.append(contentsOf: result.movies)
            hasMoreResults = currentPage < result.totalPages
        } catch {
            print("Load more error: \(error)")
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
    
    private func loadRecommendedMovies() async {
        do {
            let result = try await TMDBService.shared.getRecommendedMovies(page: 1)
            recommendedMovies = result.movies
        } catch {
            print("Failed to load recommended movies: \(error)")
        }
    }
}

struct SkeletonMovieCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Theme.card)
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(10)
                .skeleton()
            
            Rectangle()
                .fill(Theme.card)
                .frame(height: 16)
                .skeleton()
            
            Rectangle()
                .fill(Theme.card)
                .frame(height: 12)
                .skeleton()
        }
    }
}

#Preview {
    MovieSearchView(isPresented: .constant(true))
        .preferredColorScheme(.dark)
} 