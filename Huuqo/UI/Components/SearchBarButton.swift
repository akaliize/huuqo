import SwiftUI

struct SearchBarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("Search movies...")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(white: 0.15))
            )
        }
    }
}

#Preview {
    SearchBarButton(action: {})
        .padding()
        .background(Color.black)
} 