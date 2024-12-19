// ... existing code ...

    func getMovieDetails(id: Int) async throws -> Movie {
        let url = "\(baseURL)/movie/\(id)?api_key=\(apiKey)&language=en-US"
        let (data, _) = try await URLSession.shared.data(from: URL(string: url)!)
        let movie = try JSONDecoder().decode(Movie.self, from: data)
        return movie
    }

// ... existing code ... 