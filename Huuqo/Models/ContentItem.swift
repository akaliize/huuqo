import Foundation

struct ContentItem: Identifiable, Equatable {
    let id = UUID()
    let tmdbId: Int
    let title: String
    let subtitle: String
    let imageURL: String?
    let backdropURL: String?
    let type: ContentType
    let logoURL: String?
    
    enum ContentType {
        case movie
        case series
        case live
    }
    
    static func == (lhs: ContentItem, rhs: ContentItem) -> Bool {
        lhs.tmdbId == rhs.tmdbId
    }
}

extension ContentItem {
    static let preview: [ContentItem] = [
        ContentItem(tmdbId: 1, title: "The Matrix", subtitle: "Action", imageURL: nil, backdropURL: nil, type: .movie, logoURL: nil),
        ContentItem(tmdbId: 2, title: "Breaking Bad", subtitle: "Drama Series", imageURL: nil, backdropURL: nil, type: .series, logoURL: nil),
        ContentItem(tmdbId: 3, title: "Sports Channel", subtitle: "Live", imageURL: nil, backdropURL: nil, type: .live, logoURL: nil),
        ContentItem(tmdbId: 4, title: "Inception", subtitle: "Sci-Fi", imageURL: nil, backdropURL: nil, type: .movie, logoURL: nil),
        ContentItem(tmdbId: 5, title: "The Crown", subtitle: "Drama Series", imageURL: nil, backdropURL: nil, type: .series, logoURL: nil),
        ContentItem(tmdbId: 6, title: "News 24/7", subtitle: "Live", imageURL: nil, backdropURL: nil, type: .live, logoURL: nil),
        ContentItem(tmdbId: 7, title: "Interstellar", subtitle: "Sci-Fi", imageURL: nil, backdropURL: nil, type: .movie, logoURL: nil),
        ContentItem(tmdbId: 8, title: "Stranger Things", subtitle: "Drama Series", imageURL: nil, backdropURL: nil, type: .series, logoURL: nil),
        ContentItem(tmdbId: 9, title: "ESPN Live", subtitle: "Sports", imageURL: nil, backdropURL: nil, type: .live, logoURL: nil),
        ContentItem(tmdbId: 10, title: "The Dark Knight", subtitle: "Action", imageURL: nil, backdropURL: nil, type: .movie, logoURL: nil)
    ]
} 