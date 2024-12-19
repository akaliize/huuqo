import SwiftUI

struct SeriesSearchView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var searchResults: [ContentItem] = []
    @State private var recommendedSeries: [ContentItem] = []
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
                        
                        TextField("Search TV series...", text: $searchText)
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
                            // Show recommended series when not searching
                            VStack(alignment: .leading) {
                                Text("Recommended TV Series")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                LazyVGrid(columns: columns, spacing: 16) {
                                    if recommendedSeries.isEmpty {
                                        ForEach(0..<10) { _ in
                                            SkeletonMovieCard()
                                        }
                                    } else {
                                        ForEach(recommendedSeries) { series in
                                            MovieCard(item: series)
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
                                    ForEach(searchResults) { series in
                                        MovieCard(item: series)
                                            .onAppear {
                                                if series == searchResults.last && hasMoreResults && !isLoadingMore {
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
                await loadRecommendedSeries()
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func loadRecommendedSeries() async {
        do {
            let result = try await TMDBService.shared.getRecommendedSeries(page: 1)
            recommendedSeries = result.series
        } catch {
            print("Failed to load recommended series: \(error)")
        }
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
            let result = try await TMDBService.shared.searchAllSeries(query: searchText, page: currentPage)
            searchResults = result.series
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
            let result = try await TMDBService.shared.searchAllSeries(query: searchText, page: currentPage)
            searchResults.append(contentsOf: result.series)
            hasMoreResults = currentPage < result.totalPages
        } catch {
            print("Load more error: \(error)")
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
}

#Preview {
    SeriesSearchView(isPresented: .constant(true))
        .preferredColorScheme(.dark)
} 