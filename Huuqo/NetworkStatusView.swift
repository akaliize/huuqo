import SwiftUI

struct NetworkStatusView: View {
    let networkMonitor = NetworkMonitor.shared
    
    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            
            if networkMonitor.isLoading {
                SkeletonView()
                    .transition(.opacity)
            } else {
                NoInternetView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: networkMonitor.isLoading)
    }
}

#Preview {
    NetworkStatusView()
        .preferredColorScheme(.dark)
} 