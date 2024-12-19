import SwiftUI

struct NoInternetView: View {
    let networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 60))
                .foregroundColor(Theme.accent)
            
            Text("No Internet Connection")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text("Please check your internet connection and try again")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                networkMonitor.retryConnection()
            }) {
                Text("Try Again")
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .frame(width: 160, height: 48)
                    .background(Theme.accent)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }
}

#Preview {
    NoInternetView()
        .preferredColorScheme(.dark)
} 