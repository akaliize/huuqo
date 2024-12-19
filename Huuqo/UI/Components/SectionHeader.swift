import SwiftUI

struct SectionHeader: View {
    let title: String
    let subtitle: String
    var logoName: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let logoName = logoName {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 45)
            } else {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    VStack(spacing: 20) {
        SectionHeader(
            title: "Regular Title",
            subtitle: "Regular subtitle"
        )
        
        SectionHeader(
            title: "Netflix",
            subtitle: "Streaming content",
            logoName: "netflix-logo"
        )
    }
    .padding()
    .background(Color.black)
} 