import Foundation

enum TMDBError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
}

struct GenreResponse: Codable {
    let genres: [Genre]
}

struct Genre: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id
    }
}

struct TMDBImages: Codable {
    let logos: [TMDBImage]
    let posters: [TMDBImage]
    let backdrops: [TMDBImage]
}

struct TMDBImage: Codable {
    let aspectRatio: Double
    let filePath: String
    let height: Int
    let width: Int
    let voteAverage: Double
    let voteCount: Int
}

struct TMDBResponse: Codable {
    let page: Int
    let results: [TMDBContent]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct TMDBContent: Codable, Identifiable, Hashable {
    let id: Int
    let title: String?
    let name: String?
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let mediaType: String?
    let voteAverage: Double
    let releaseDate: String?
    let firstAirDate: String?
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case mediaType = "media_type"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case firstAirDate = "first_air_date"
        case genreIds = "genre_ids"
    }
    
    var displayTitle: String {
        title ?? name ?? "Unknown"
    }
    
    var genreNames: [String] {
        guard let ids = genreIds else { return [] }
        return ids.compactMap { id in
            TMDBService.shared.genres.first(where: { $0.id == id })?.name
        }
    }
    
    var type: ContentItem.ContentType {
        if mediaType == "tv" {
            return .series
        } else if mediaType == "movie" || title != nil {
            return .movie
        } else if name != nil {
            return .series
        } else {
            return .movie
        }
    }
}

extension TMDBContent {
    func toContentItem() -> ContentItem {
        let subtitle = genreNames.isEmpty ? "No genres available" : genreNames.first ?? "No genres available"
        
        return ContentItem(
            tmdbId: id,
            title: displayTitle,
            subtitle: subtitle,
            imageURL: posterPath,
            backdropURL: backdropPath,
            type: type,
            logoURL: nil
        )
    }
}

// Add this struct near the top with other response types
struct MovieResponse: Codable {
    let page: Int
    let results: [Movie]
    let totalPages: Int
    let totalResults: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Movie: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?
    let genreIds: [Int]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case voteAverage = "vote_average"
        case releaseDate = "release_date"
        case genreIds = "genre_ids"
    }
}

// Add these structures after the other response types at the top
struct CertificationResponse: Codable {
    let certifications: [String: [Certification]]
}

struct Certification: Codable {
    let certification: String
    let meaning: String
    let order: Int
}

// Add these structures after the other response types
struct MovieReleaseDatesResponse: Codable {
    let results: [MovieReleaseInfo]
}

struct MovieReleaseInfo: Codable {
    let iso31661: String
    let releaseDates: [ReleaseDate]
    
    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case releaseDates = "release_dates"
    }
}

struct ReleaseDate: Codable {
    let certification: String
    let type: Int
}

struct TVContentRatingsResponse: Codable {
    let results: [TVContentRating]
}

struct TVContentRating: Codable {
    let iso31661: String
    let rating: String
    
    enum CodingKeys: String, CodingKey {
        case iso31661 = "iso_3166_1"
        case rating
    }
}

@Observable
class TMDBService {
    static let shared = TMDBService()
    private let apiKey = "5eea9dcd70fe6821ed6cad71b987fbaf"
    private let baseURL = "https://api.themoviedb.org/3"
    private let imageBaseURL = "https://image.tmdb.org/t/p"
    
    private init() {}
    
    private(set) var genres: [Genre] = []
    
    func fetchGenres() async throws {
        // Fetch movie genres
        let movieUrl = URL(string: "\(baseURL)/genre/movie/list?api_key=\(apiKey)")!
        let (movieData, _) = try await URLSession.shared.data(from: movieUrl)
        let movieResponse = try JSONDecoder().decode(GenreResponse.self, from: movieData)
        
        // Fetch TV genres
        let tvUrl = URL(string: "\(baseURL)/genre/tv/list?api_key=\(apiKey)")!
        let (tvData, _) = try await URLSession.shared.data(from: tvUrl)
        let tvResponse = try JSONDecoder().decode(GenreResponse.self, from: tvData)
        
        // Combine genres, removing duplicates
        var uniqueGenres = Set<Genre>()
        movieResponse.genres.forEach { uniqueGenres.insert($0) }
        tvResponse.genres.forEach { uniqueGenres.insert($0) }
        genres = Array(uniqueGenres)
    }
    
    func getImageURL(path: String, size: ImageSize = .w500) -> URL? {
        return URL(string: "\(imageBaseURL)/\(size.rawValue)\(path)")
    }
    
    enum ImageSize: String {
        case w200 = "/w200"
        case w500 = "/w500"
        case original = "/original"
    }
    
    func getTrendingMovies() async throws -> [TMDBContent] {
        let url = "\(baseURL)/trending/movie/day?api_key=\(apiKey)&page=1&language=en-US"
        let movies = try await fetchContent(from: url)
        return Array(movies.prefix(20))
    }
    
    func getTrendingSeries() async throws -> [TMDBContent] {
        let url = "\(baseURL)/trending/tv/day?api_key=\(apiKey)&page=1&language=en-US"
        let series = try await fetchContent(from: url)
        return Array(series.prefix(20))
    }
    
    private func fetchContent(from urlString: String) async throws -> [TMDBContent] {
        guard let url = URL(string: urlString) else {
            throw TMDBError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            let result = try decoder.decode(TMDBResponse.self, from: data)
            return result.results
        } catch {
            print("Decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    func search(query: String) async throws -> [TMDBContent] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(baseURL)/search/multi?api_key=\(apiKey)&query=\(encodedQuery)"
        
        guard let url = URL(string: url) else {
            throw TMDBError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let result = try decoder.decode(TMDBResponse.self, from: data)
            return result.results
        } catch {
            print("Decoding error: \(error)")
            throw TMDBError.decodingError
        }
    }
    
    func getMovieImages(movieId: Int) async throws -> TMDBImages {
        let url = URL(string: "\(baseURL)/movie/\(movieId)/images")!
        
        // Try English first
        let englishImages: TMDBImages = try await fetch(url: url, parameters: [
            "api_key": apiKey,
            "include_image_language": "en"
        ])
        
        // If English logos found, return them
        if !englishImages.logos.isEmpty {
            return englishImages
        }
        
        // If no English logos, try all languages
        return try await fetch(url: url, parameters: [
            "api_key": apiKey,
            "include_image_language": "en,null,fr,de,es,pt,it,ru,ja,ko,zh"
        ]) as TMDBImages
    }
    
    private func fetch<T: Codable>(url: URL, parameters: [String: String]) async throws -> T {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        let (data, response) = try await URLSession.shared.data(from: components.url!)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw TMDBError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(T.self, from: data)
    }
    
    func getTrendingMoviesWithLogos() async throws -> [ContentItem] {
        let movies = try await getTrendingMovies()
        
        var contentItems: [ContentItem] = []
        
        for movie in movies {
            do {
                let images = try await getMovieImages(movieId: movie.id)
                print("Movie: \(movie.displayTitle)")
                print("Number of logos: \(images.logos.count)")
                if let firstLogo = images.logos.first {
                    print("First logo path: \(firstLogo.filePath)")
                }
                
                let logoPath = images.logos.first?.filePath
                
                var contentItem = movie.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(movie.displayTitle): \(error)")
                contentItems.append(movie.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func discoverMovies(genre: String? = nil) async throws -> [ContentItem] {
        let url = "\(baseURL)/discover/movie?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc"
        let movies = try await fetchContent(from: url)
        return movies.map { $0.toContentItem() }
    }
    
    func discoverSeries(genre: String? = nil) async throws -> [ContentItem] {
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc"
        let series = try await fetchContent(from: url)
        return series.map { $0.toContentItem() }
    }
    
    func getFamilyContent() async throws -> [ContentItem] {
        // Family genre ID in TMDB is 10751
        let urlString = "\(baseURL)/discover/movie?api_key=\(apiKey)&with_genres=10751&sort_by=popularity.desc&include_adult=false"
        return try await fetchContent(from: urlString).map { $0.toContentItem() }
    }
    
    func getSeriesImages(seriesId: Int) async throws -> TMDBImages {
        let languages = ["en", "null", ""]  // null and empty string will include all languages
        
        for language in languages {
            let url = URL(string: "\(baseURL)/tv/\(seriesId)/images")!
            
            do {
                let images: TMDBImages = try await fetch(url: url, parameters: [
                    "api_key": apiKey,
                    "include_image_language": language
                ])
                
                print("Series ID \(seriesId) - Language '\(language)' logos count: \(images.logos.count)")
                
                // First try to find non-SVG logos
                let nonSvgLogos = images.logos.filter { !$0.filePath.hasSuffix(".svg") }
                
                // Sort logos by vote average to get the highest quality version
                let sortedLogos = (nonSvgLogos.isEmpty ? images.logos : nonSvgLogos)
                    .sorted { $0.voteAverage > $1.voteAverage }
                
                if !sortedLogos.isEmpty {
                    print("Found \(sortedLogos.count) logos for series \(seriesId) in language '\(language)'")
                    let bestLogo = sortedLogos.first!
                    print("Selected logo: \(bestLogo.filePath) with vote average: \(bestLogo.voteAverage)")
                    return TMDBImages(
                        logos: [bestLogo],
                        posters: images.posters,
                        backdrops: images.backdrops
                    )
                }
            } catch {
                print("Error fetching images for series \(seriesId) with language '\(language)': \(error)")
                continue
            }
        }
        
        // If we get here, we didn't find any logos
        print("No logos found for series \(seriesId) in any language")
        return TMDBImages(logos: [], posters: [], backdrops: [])
    }
    
    func getTrendingSeriesWithLogos() async throws -> [ContentItem] {
        let series = try await getTrendingSeries()
        
        var contentItems: [ContentItem] = []
        
        for show in series {
            do {
                let images = try await getSeriesImages(seriesId: show.id)
                print("Series: \(show.displayTitle)")
                print("Number of logos: \(images.logos.count)")
                if let firstLogo = images.logos.first {
                    print("First logo path: \(firstLogo.filePath)")
                }
                
                let logoPath = images.logos.first?.filePath
                
                var contentItem = show.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(show.displayTitle): \(error)")
                contentItems.append(show.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func getPopularMovies() async throws -> [TMDBContent] {
        // Try US region first with more results
        let usUrl = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=en-US&region=US&page=1"
        let usMovies = try await fetchContent(from: usUrl)
        
        // If no US movies found, try without region
        if usMovies.isEmpty {
            let url = "\(baseURL)/movie/popular?api_key=\(apiKey)&language=en-US&page=1"
            let movies = try await fetchContent(from: url)
            return Array(movies.prefix(15))
        }
        
        return Array(usMovies.prefix(15))
    }
    
    func getPopularSeries() async throws -> [TMDBContent] {
        // Try US region first with more results
        let usUrl = "\(baseURL)/tv/popular?api_key=\(apiKey)&language=en-US&region=US&page=1"
        let usSeries = try await fetchContent(from: usUrl)
        
        // If no US series found, try without region
        if usSeries.isEmpty {
            let url = "\(baseURL)/tv/popular?api_key=\(apiKey)&language=en-US&page=1"
            let series = try await fetchContent(from: url)
            return Array(series.prefix(15))
        }
        
        return Array(usSeries.prefix(15))
    }
    
    func getPopularMoviesWithLogos() async throws -> [ContentItem] {
        let movies = try await getPopularMovies()
        
        var contentItems: [ContentItem] = []
        
        for movie in movies {
            do {
                let images = try await getMovieImages(movieId: movie.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = movie.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(movie.displayTitle): \(error)")
                contentItems.append(movie.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func getPopularSeriesWithLogos() async throws -> [ContentItem] {
        let series = try await getPopularSeries()
        
        var contentItems: [ContentItem] = []
        
        for show in series {
            do {
                let images = try await getSeriesImages(seriesId: show.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = show.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(show.displayTitle): \(error)")
                contentItems.append(show.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func getUpcomingMovies() async throws -> [ContentItem] {
        // Get upcoming movies for US region first
        let usUrl = "\(baseURL)/movie/upcoming?api_key=\(apiKey)&language=en-US&region=US"
        let usMovies = try await fetchContent(from: usUrl)
        
        // If no US movies found, try without region
        let movies = usMovies.isEmpty ? 
            try await fetchContent(from: "\(baseURL)/movie/upcoming?api_key=\(apiKey)&language=en-US") : 
            usMovies
            
        let today = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Filter movies that have a valid release date, are unreleased, and must have a poster
        let unreleasedMovies = movies.compactMap { movie -> (TMDBContent, String)? in
            // Check if movie has a poster (required)
            guard movie.posterPath != nil,
                  let releaseDateString = movie.releaseDate,
                  let releaseDate = dateFormatter.date(from: releaseDateString),
                  releaseDate >= calendar.startOfDay(for: today)
            else { return nil }
            
            // Check if the movie releases today
            if calendar.isDate(releaseDate, inSameDayAs: today) {
                return (movie, "Today")
            }
            
            // Format the date for other days
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let formattedDate = dateFormatter.string(from: releaseDate)
            dateFormatter.dateFormat = "yyyy-MM-dd" // Reset format for next iteration
            
            return (movie, formattedDate)
        }
        .sorted { movie1, movie2 in
            // Sort by the original release date
            guard let date1 = dateFormatter.date(from: movie1.0.releaseDate ?? ""),
                  let date2 = dateFormatter.date(from: movie2.0.releaseDate ?? "")
            else { return false }
            return date1 < date2
        }
        .map { movie, formattedDate in
            ContentItem(
                tmdbId: movie.id,
                title: movie.displayTitle,
                subtitle: "Available \(formattedDate == "Today" ? "Today" : "soon\n\(formattedDate)")",
                imageURL: movie.posterPath,
                backdropURL: movie.backdropPath,
                type: .movie,
                logoURL: nil
            )
        }
        
        return unreleasedMovies
    }
    
    func getUpcomingSeries() async throws -> [ContentItem] {
        print("\n📱 TMDBService - Getting upcoming series")
        
        let today = Date()
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Get the date range for the next 6 months
        let startDate = calendar.startOfDay(for: today)
        guard let endDate = calendar.date(byAdding: .month, value: 6, to: startDate) else {
            throw TMDBError.invalidResponse
        }
        
        let startDateString = dateFormatter.string(from: startDate)
        let endDateString = dateFormatter.string(from: endDate)
        
        // Use discover/tv endpoint with air_date filtering
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&language=en-US" +
                 "&sort_by=first_air_date.asc" +
                 "&air_date.gte=\(startDateString)" +
                 "&air_date.lte=\(endDateString)" +
                 "&first_air_date.gte=\(startDateString)"
        
        print("📱 TMDBService - Fetching from URL: \(url)")
        
        let series = try await fetchContent(from: url)
        print("📱 TMDBService - Raw results count: \(series.count)")
        
        // Map series to ContentItems, filtering out those without a poster
        let upcomingSeries = series.compactMap { show -> ContentItem? in
            // Check if show has a poster (required)
            guard show.posterPath != nil,
                  let firstAirDateString = show.firstAirDate,
                  let airDate = dateFormatter.date(from: firstAirDateString)
            else {
                print("📱 TMDBService - Show '\(show.displayTitle)' skipped: no poster or no valid air date")
                return nil
            }
            
            // Check if the series premieres today
            if calendar.isDate(airDate, inSameDayAs: today) {
                print("📱 TMDBService - Show '\(show.displayTitle)' premiering Today")
                return ContentItem(
                    tmdbId: show.id,
                    title: show.displayTitle,
                    subtitle: "Premiering Today",
                    imageURL: show.posterPath,
                    backdropURL: show.backdropPath,
                    type: .series,
                    logoURL: nil
                )
            }
            
            // Format the date for other days
            dateFormatter.dateFormat = "MMMM d, yyyy"
            let formattedDate = dateFormatter.string(from: airDate)
            dateFormatter.dateFormat = "yyyy-MM-dd" // Reset format for next iteration
            
            print("📱 TMDBService - Including show '\(show.displayTitle)' premiering on \(formattedDate)")
            
            return ContentItem(
                tmdbId: show.id,
                title: show.displayTitle,
                subtitle: "Premiering on\n\(formattedDate)",
                imageURL: show.posterPath,
                backdropURL: show.backdropPath,
                type: .series,
                logoURL: nil
            )
        }
        
        print("\n📱 TMDBService - Final results:")
        print("- Found \(upcomingSeries.count) upcoming series with posters")
        if !upcomingSeries.isEmpty {
            print("- First upcoming series: \(upcomingSeries[0].title) - \(upcomingSeries[0].subtitle)")
            print("- Last upcoming series: \(upcomingSeries[upcomingSeries.count - 1].title) - \(upcomingSeries[upcomingSeries.count - 1].subtitle)")
        } else {
            print("⚠️ TMDBService - No upcoming series found with posters!")
        }
        
        return upcomingSeries
    }
    
    private func getTodayString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    func getGenreId(for genreName: String) async throws -> Int {
        if genres.isEmpty {
            try await fetchGenres()
        }
        
        guard let genre = genres.first(where: { $0.name.lowercased() == genreName.lowercased() }) else {
            throw TMDBError.invalidResponse
        }
        
        return genre.id
    }
    
    func getTrendingMoviesWithLogos(genreId: Int) async throws -> [ContentItem] {
        let url = "\(baseURL)/trending/movie/day?api_key=\(apiKey)&with_genres=\(genreId)&page=1&language=en-US"
        let movies = try await fetchContent(from: url)
        
        var contentItems: [ContentItem] = []
        
        for movie in movies {
            do {
                let images = try await getMovieImages(movieId: movie.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = movie.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(movie.displayTitle): \(error)")
                contentItems.append(movie.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func getTrendingSeriesWithLogos(genreId: Int) async throws -> [ContentItem] {
        let url = "\(baseURL)/trending/tv/day?api_key=\(apiKey)&with_genres=\(genreId)&page=1&language=en-US"
        let series = try await fetchContent(from: url)
        
        var contentItems: [ContentItem] = []
        
        for show in series {
            do {
                let images = try await getSeriesImages(seriesId: show.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = show.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(show.displayTitle): \(error)")
                contentItems.append(show.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func discoverMovies(genreId: Int) async throws -> [ContentItem] {
        let url = "\(baseURL)/discover/movie?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc&with_genres=\(genreId)&page=1"
        let movies = try await fetchContent(from: url)
        
        var contentItems: [ContentItem] = []
        
        for movie in movies.prefix(20) {
            do {
                let images = try await getMovieImages(movieId: movie.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = movie.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(movie.displayTitle): \(error)")
                contentItems.append(movie.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func discoverSeries(genreId: Int) async throws -> [ContentItem] {
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc&with_genres=\(genreId)&page=1"
        let series = try await fetchContent(from: url)
        
        var contentItems: [ContentItem] = []
        
        for show in series.prefix(20) {
            do {
                let images = try await getSeriesImages(seriesId: show.id)
                let logoPath = images.logos.first?.filePath
                
                var contentItem = show.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: logoPath
                )
                contentItems.append(contentItem)
            } catch {
                print("Error fetching images for \(show.displayTitle): \(error)")
                contentItems.append(show.toContentItem())
            }
        }
        
        return contentItems
    }
    
    func getFeaturedContent() async throws -> [ContentItem] {
        // Get trending movies and TV shows for the day
        let movieUrl = "\(baseURL)/trending/movie/day?api_key=\(apiKey)&language=en-US"
        let tvUrl = "\(baseURL)/trending/tv/day?api_key=\(apiKey)&language=en-US"
        
        async let moviesTask = fetchContent(from: movieUrl)
        async let tvShowsTask = fetchContent(from: tvUrl)
        
        let (movies, tvShows) = try await (moviesTask, tvShowsTask)
        
        var featuredItems: [ContentItem] = []
        
        // Process movies
        for movie in movies.prefix(3) {
            do {
                let images = try await getMovieImages(movieId: movie.id)
                var contentItem = movie.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: images.logos.first?.filePath
                )
                featuredItems.append(contentItem)
            } catch {
                print("Error fetching images for featured movie: \(error)")
            }
        }
        
        // Process TV shows
        for show in tvShows.prefix(2) {
            do {
                let images = try await getSeriesImages(seriesId: show.id)
                var contentItem = show.toContentItem()
                contentItem = ContentItem(
                    tmdbId: contentItem.tmdbId,
                    title: contentItem.title,
                    subtitle: contentItem.subtitle,
                    imageURL: contentItem.imageURL,
                    backdropURL: contentItem.backdropURL,
                    type: contentItem.type,
                    logoURL: images.logos.first?.filePath
                )
                featuredItems.append(contentItem)
            } catch {
                print("Error fetching images for featured TV show: \(error)")
            }
        }
        
        // Shuffle the items to mix movies and TV shows
        return featuredItems.shuffled()
    }
    
    func searchAllMovies(query: String, page: Int = 1) async throws -> (movies: [ContentItem], totalPages: Int) {
        print("📱 TMDBService - searchAllMovies called with query: '\(query)', page: \(page)")
        
        let url: String
        if query.isEmpty {
            // If no query, get popular movies
            url = "\(baseURL)/movie/popular?api_key=\(apiKey)&page=\(page)&language=en-US"
            print("📱 TMDBService - Using movie/popular endpoint")
        } else {
            // If there's a query, use search
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            url = "\(baseURL)/search/movie?api_key=\(apiKey)&query=\(encodedQuery)&page=\(page)&include_adult=false&language=en-US"
            print("📱 TMDBService - Using search/movie endpoint")
        }
        
        print("📱 TMDBService - Request URL: \(url)")
        
        guard let url = URL(string: url) else {
            print("❌ TMDBService - Invalid URL")
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ TMDBService - Invalid response type")
                throw TMDBError.invalidResponse
            }
            
            print("📱 TMDBService - Response status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ TMDBService - Bad status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ TMDBService - Response body: \(responseString)")
                }
                throw TMDBError.invalidResponse
            }
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📱 TMDBService - Raw response: \(responseString)")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys // Don't convert snake_case
            
            do {
                let result = try decoder.decode(TMDBResponse.self, from: data)
                print("📱 TMDBService - Successfully decoded response")
                print("📱 TMDBService - Total pages: \(result.totalPages)")
                print("📱 TMDBService - Results count: \(result.results.count)")
                
                let movies = result.results.map { $0.toContentItem() }
                return (movies: movies, totalPages: result.totalPages)
            } catch {
                print("❌ TMDBService - Decoding error: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("❌ TMDBService - Missing key: \(key.stringValue)")
                        print("❌ TMDBService - Context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ TMDBService - Type mismatch: expected \(type)")
                        print("❌ TMDBService - Context: \(context.debugDescription)")
                    default:
                        print("❌ TMDBService - Other decoding error: \(decodingError)")
                    }
                }
                throw TMDBError.decodingError
            }
        } catch {
            print("❌ TMDBService - Network error: \(error)")
            throw error
        }
    }
    
    func getMoviesByProvider(providerId: Int, region: String, page: Int = 1) async throws -> [ContentItem] {
        print("📱 TMDBService - Getting movies for provider ID: \(providerId), region: \(region), page: \(page)")
        
        let url = URL(string: "\(baseURL)/discover/movie")!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_watch_providers", value: String(providerId)),
            URLQueryItem(name: "watch_region", value: region),
            URLQueryItem(name: "with_watch_providers.operator", value: "OR"), // Changed from AND to OR for more results
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "with_watch_monetization_types", value: "flatrate|free|ads"), // Added more monetization types
            URLQueryItem(name: "vote_count.gte", value: "20"), // Lowered vote count threshold
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        print("📱 TMDBService - Request URL: \(components.url!.absoluteString)")
        
        let movies = try await fetchContent(from: components.url!.absoluteString)
        print("📱 TMDBService - Found \(movies.count) movies for provider \(providerId)")
        
        return movies.map { movie in
            let genreNames = movie.genreIds?.compactMap { id in
                genres.first(where: { $0.id == id })?.name
            } ?? []
            let subtitle = genreNames.isEmpty ? "No genres available" : genreNames.prefix(3).joined(separator: ", ")
            
            return ContentItem(
                tmdbId: movie.id,
                title: movie.displayTitle,
                subtitle: subtitle,
                imageURL: movie.posterPath,
                backdropURL: movie.backdropPath,
                type: .movie,
                logoURL: nil
            )
        }
    }
    
    func getSeriesByProvider(providerId: Int, region: String, page: Int) async throws -> [ContentItem] {
        let url = URL(string: "\(baseURL)/discover/tv")!
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "api_key", value: apiKey),
            URLQueryItem(name: "with_watch_providers", value: String(providerId)),
            URLQueryItem(name: "watch_region", value: region),
            URLQueryItem(name: "with_watch_providers.operator", value: "AND"),
            URLQueryItem(name: "sort_by", value: "popularity.desc"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "with_watch_monetization_types", value: "flatrate"),
            URLQueryItem(name: "vote_count.gte", value: "50"),
            URLQueryItem(name: "language", value: "en-US")
        ]
        
        let series = try await fetchContent(from: components.url!.absoluteString)
        return series.map { $0.toContentItem() }
    }
    
    func searchSeries(query: String) async throws -> [ContentItem] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = "\(baseURL)/search/tv?api_key=\(apiKey)&query=\(encodedQuery)&language=en-US&page=1"
        let series = try await fetchContent(from: url)
        return series.map { $0.toContentItem() }
    }
    
    func searchAllSeries(query: String, page: Int = 1) async throws -> (series: [ContentItem], totalPages: Int) {
        print("📱 TMDBService - searchAllSeries called with query: '\(query)', page: \(page)")
        
        let url: String
        if query.isEmpty {
            // If no query, get popular series
            url = "\(baseURL)/tv/popular?api_key=\(apiKey)&page=\(page)&language=en-US"
            print("📱 TMDBService - Using tv/popular endpoint")
        } else {
            // If there's a query, use search
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            url = "\(baseURL)/search/tv?api_key=\(apiKey)&query=\(encodedQuery)&page=\(page)&include_adult=false&language=en-US"
            print("📱 TMDBService - Using search/tv endpoint")
        }
        
        print("📱 TMDBService - Request URL: \(url)")
        
        guard let url = URL(string: url) else {
            print("❌ TMDBService - Invalid URL")
            throw TMDBError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ TMDBService - Invalid response type")
                throw TMDBError.invalidResponse
            }
            
            print("📱 TMDBService - Response status code: \(httpResponse.statusCode)")
            
            guard httpResponse.statusCode == 200 else {
                print("❌ TMDBService - Bad status code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("❌ TMDBService - Response body: \(responseString)")
                }
                throw TMDBError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            do {
                let result = try decoder.decode(TMDBResponse.self, from: data)
                print("📱 TMDBService - Successfully decoded response")
                print("📱 TMDBService - Total pages: \(result.totalPages)")
                print("📱 TMDBService - Results count: \(result.results.count)")
                
                let series = result.results.map { $0.toContentItem() }
                return (series: series, totalPages: result.totalPages)
            } catch {
                print("❌ TMDBService - Decoding error: \(error)")
                throw TMDBError.decodingError
            }
        } catch {
            print("❌ TMDBService - Network error: \(error)")
            throw error
        }
    }
    
    func getUSCertification(forMovieId id: Int) async -> String? {
        let url = "\(baseURL)/movie/\(id)/release_dates?api_key=\(apiKey)"
        guard let url = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(MovieReleaseDatesResponse.self, from: data)
            
            // Find US release dates
            guard let usRelease = response.results.first(where: { $0.iso31661 == "US" }) else {
                print("No US release found for movie \(id)")
                return nil
            }
            
            // Look through all release dates for a valid certification
            let certifications = usRelease.releaseDates
                .filter { !$0.certification.isEmpty }
                .map { $0.certification }
            
            // Print for debugging
            print("Movie \(id) certifications: \(certifications)")
            
            // Return the first valid certification
            return certifications.first
        } catch {
            print("Error fetching movie certification for ID \(id): \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue)")
                    print("Context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type)")
                    print("Context: \(context.debugDescription)")
                default:
                    print("Other decoding error: \(decodingError)")
                }
            }
            return nil
        }
    }
    
    func getUSCertification(forTVShowId id: Int) async -> String? {
        let url = "\(baseURL)/tv/\(id)/content_ratings?api_key=\(apiKey)"
        guard let url = URL(string: url) else { return nil }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Print raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("TV show \(id) raw response: \(responseString)")
            }
            
            let response = try JSONDecoder().decode(TVContentRatingsResponse.self, from: data)
            
            // Find US rating
            let usRatings = response.results.filter { $0.iso31661 == "US" }
            print("TV show \(id) US ratings: \(usRatings)")
            
            if let rating = usRatings.first?.rating, !rating.isEmpty {
                return rating
            }
            
            return nil
        } catch {
            print("Error fetching TV show certification for ID \(id): \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Missing key: \(key.stringValue)")
                    print("Context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: expected \(type)")
                    print("Context: \(context.debugDescription)")
                default:
                    print("Other decoding error: \(decodingError)")
                }
            }
            return nil
        }
    }
    
    func getTVShowsByGenre(genreId: Int) async throws -> [ContentItem] {
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&with_genres=\(genreId)&language=en-US&sort_by=popularity.desc&page=1"
        let response = try await fetchContent(from: url)
        return response.map { $0.toContentItem() }
    }
    
    func getPopularMoviesByGenre(genreId: Int) async throws -> [ContentItem] {
        // Using discover with Netflix (8), Disney+ (337), Apple TV+ (350), Prime Video (9), Hulu (15), Max (1899)
        let providers = [8, 337, 350, 9, 15, 1899].map(String.init).joined(separator: "|")
        let url = "\(baseURL)/discover/movie?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc&with_genres=\(genreId)&watch_region=US&with_watch_providers=\(providers)&with_watch_monetization_types=flatrate"
        
        let response = try await fetchContent(from: url)
        let limitedContent = Array(response.prefix(20))
        
        return limitedContent.map { content in
            let subtitle = content.genreNames.isEmpty ? "No genres available" : content.genreNames.first ?? "No genres available"
            return ContentItem(
                tmdbId: content.id,
                title: content.displayTitle,
                subtitle: subtitle,
                imageURL: content.posterPath,
                backdropURL: content.backdropPath,
                type: .movie,
                logoURL: nil
            )
        }
    }
    
    func getPopularSeriesByGenre(genreId: Int) async throws -> [ContentItem] {
        // Using discover with Netflix (8), Disney+ (337), Apple TV+ (350), Prime Video (9), Hulu (15), Max (1899)
        let providers = [8, 337, 350, 9, 15, 1899].map(String.init).joined(separator: "|")
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&language=en-US&sort_by=popularity.desc&with_genres=\(genreId)&watch_region=US&with_watch_providers=\(providers)&with_watch_monetization_types=flatrate"
        
        let response = try await fetchContent(from: url)
        let limitedContent = Array(response.prefix(20))
        
        return limitedContent.map { content in
            let subtitle = content.genreNames.isEmpty ? "No genres available" : content.genreNames.first ?? "No genres available"
            return ContentItem(
                tmdbId: content.id,
                title: content.displayTitle,
                subtitle: subtitle,
                imageURL: content.posterPath,
                backdropURL: content.backdropPath,
                type: .series,
                logoURL: nil
            )
        }
    }
    
    func getRecommendedMovies(page: Int = 1) async throws -> (movies: [ContentItem], totalPages: Int) {
        // Using major streaming providers: Netflix (8), Disney+ (337), Apple TV+ (350), Prime Video (9), Hulu (15), Max (1899)
        let providers = [8, 337, 350, 9, 15, 1899].map(String.init).joined(separator: "|")
        let url = "\(baseURL)/discover/movie?api_key=\(apiKey)&language=en-US" +
                 "&sort_by=popularity.desc" +
                 "&watch_region=US" +
                 "&with_watch_providers=\(providers)" +
                 "&with_watch_monetization_types=flatrate" +
                 "&vote_count.gte=100" + // Ensure movies have significant views
                 "&page=\(page)"
        
        let response = try await fetchContent(from: url)
        return (
            movies: response.map { content in
                let subtitle = content.genreNames.isEmpty ? "No genres available" : content.genreNames.prefix(2).joined(separator: ", ")
                return ContentItem(
                    tmdbId: content.id,
                    title: content.displayTitle,
                    subtitle: subtitle,
                    imageURL: content.posterPath,
                    backdropURL: content.backdropPath,
                    type: .movie,
                    logoURL: nil
                )
            },
            totalPages: response.count > 0 ? 1000 : 0
        )
    }
    
    func getRecommendedSeries(page: Int = 1) async throws -> (series: [ContentItem], totalPages: Int) {
        // Using major streaming providers: Netflix (8), Disney+ (337), Apple TV+ (350), Prime Video (9), Hulu (15), Max (1899)
        let providers = [8, 337, 350, 9, 15, 1899].map(String.init).joined(separator: "|")
        let url = "\(baseURL)/discover/tv?api_key=\(apiKey)&language=en-US" +
                 "&sort_by=popularity.desc" +
                 "&watch_region=US" +
                 "&with_watch_providers=\(providers)" +
                 "&with_watch_monetization_types=flatrate" +
                 "&vote_count.gte=100" + // Ensure series have significant views
                 "&page=\(page)"
        
        let response = try await fetchContent(from: url)
        return (
            series: response.map { content in
                let subtitle = content.genreNames.isEmpty ? "No genres available" : content.genreNames.prefix(2).joined(separator: ", ")
                return ContentItem(
                    tmdbId: content.id,
                    title: content.displayTitle,
                    subtitle: subtitle,
                    imageURL: content.posterPath,
                    backdropURL: content.backdropPath,
                    type: .series,
                    logoURL: nil
                )
            },
            totalPages: response.count > 0 ? 1000 : 0
        )
    }
} 