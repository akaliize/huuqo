import SwiftUI

struct SkeletonView: View {
    private let cardWidth: CGFloat = Layout.Cards.largeWidth
    
    private func SkeletonCard() -> some View {
        VStack(alignment: .leading) {
            Rectangle()
                .fill(Color(white: 0.15))
                .aspectRatio(2/3, contentMode: .fit)
                .cornerRadius(10)
            
            Text("Loading...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
                .redacted(reason: .placeholder)
            
            Text("Loading...")
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(1)
                .redacted(reason: .placeholder)
        }
        .frame(width: cardWidth)
    }
    
    private func SectionHeader() -> some View {
        Text("Loading...")
            .font(.title2)
            .bold()
            .foregroundColor(Theme.text)
            .padding(.horizontal)
            .redacted(reason: .placeholder)
    }
    
    private func HorizontalScrollSection() -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    ForEach(0..<5, id: \.self) { _ in
                        SkeletonCard()
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func BigCardSection() -> some View {
        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
            SectionHeader()
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: Layout.Spacing.standard) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: Layout.Spacing.small) {
                            Rectangle()
                                .fill(Color(white: 0.15))
                                .aspectRatio(16/9, contentMode: .fit)
                                .cornerRadius(10)
                            
                            HStack(spacing: Layout.Spacing.small) {
                                Rectangle()
                                    .fill(Color(white: 0.15))
                                    .frame(width: 40, height: 40)
                                    .cornerRadius(20)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Loading...")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .redacted(reason: .placeholder)
                                    
                                    Text("Loading...")
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .redacted(reason: .placeholder)
                                }
                            }
                        }
                        .frame(width: cardWidth * 1.5)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func GenreSection() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: Layout.Spacing.standard) {
                ForEach(0..<8, id: \.self) { _ in
                    Circle()
                        .fill(Color(white: 0.15))
                        .frame(width: 80, height: 80)
                }
            }
            .padding(.horizontal)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Trending Movies Section
                HorizontalScrollSection()
                
                // Genre Icons Section
                GenreSection()
                
                // Popular Movies Section (Big Cards)
                BigCardSection()
                
                // Upcoming Movies Section
                HorizontalScrollSection()
                
                // Trending Series Section
                HorizontalScrollSection()
                
                // Popular Series Section (Big Cards)
                BigCardSection()
                
                // Upcoming Series Section
                HorizontalScrollSection()
                
                // Kids & Family Section
                HorizontalScrollSection()
            }
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    SkeletonView()
        .preferredColorScheme(.dark)
} 