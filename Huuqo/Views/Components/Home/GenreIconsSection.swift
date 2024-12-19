import SwiftUI

struct GenreIconsSection: View {
    @Binding var selectedGenreId: Int?
    
    // TMDB Genre IDs
    static let genres: [(name: String, id: Int, icon: String)] = [
        ("Action", 28, "bolt.fill"),
        ("Adventure", 12, "map.fill"),
        ("Animation", 16, "sparkles"),
        ("Comedy", 35, "face.smiling.fill"),
        ("Crime", 80, "flame"),
        ("Documentary", 99, "camera.fill"),
        ("Drama", 18, "theatermasks.fill"),
        ("Family", 10751, "figure.2.and.child.holdinghands"),
        ("Fantasy", 14, "wand.and.stars"),
        ("History", 36, "book.fill"),
        ("Horror", 27, "scissors"),
        ("Music", 10402, "music.note"),
        ("Mystery", 9648, "magnifyingglass"),
        ("Romance", 10749, "heart.fill"),
        ("Science Fiction", 878, "atom"),
        ("TV Movie", 10770, "tv.fill"),
        ("Thriller", 53, "exclamationmark.triangle.fill"),
        ("War", 10752, "shield.fill"),
        ("Western", 37, "star.circle.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(
                title: "Browse by Genre",
                subtitle: "Explore content by your favorite categories"
            )
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 20) {
                    ForEach(Self.genres, id: \.id) { genre in
                        Button {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            if selectedGenreId == genre.id {
                                selectedGenreId = nil // Deselect if tapping the same genre
                            } else {
                                selectedGenreId = genre.id
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(systemName: genre.icon)
                                    .font(.system(size: 24))
                                    .foregroundColor(selectedGenreId == genre.id ? .yellow : .white)
                                    .frame(width: 24, height: 24)
                                    .accessibilityHidden(true)
                                
                                Text(genre.name)
                                    .font(.caption)
                                    .foregroundColor(selectedGenreId == genre.id ? .yellow : .white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .frame(height: 28, alignment: .top)
                            }
                            .frame(width: 65, height: 70)
                            .contentShape(Rectangle())
                        }
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(genre.name) genre")
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
} 

#Preview {
    GenreIconsSection(selectedGenreId: .constant(nil))
        .background(Theme.background)
} 