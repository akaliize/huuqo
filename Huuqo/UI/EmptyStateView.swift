import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(Theme.accent)
                    .frame(width: 40, height: 40)
                    .background(Theme.secondaryCard)
                    .cornerRadius(8)
                
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(Theme.text)
            }
            
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(Theme.secondaryText)
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.accent)
                    .cornerRadius(12)
            }
        }
        .padding()
        .glassBackground()
        .padding()
    }
}

#Preview {
    ZStack {
        Theme.background.ignoresSafeArea()
        EmptyStateView(
            icon: "house.fill",
            title: "Home, Not-So-Sweet Home",
            message: "Bummer! Your home screen looks as empty as a gym on January 1st. Create a new playlist and let's fill this void with some killer content.",
            buttonTitle: "Create Playlist, Now!"
        ) {}
    }
} 