import Network
import SwiftUI

@Observable
final class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor", qos: .userInitiated)
    
    var isConnected = true
    var isLoading = false
    var hasTriedConnection = false
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.isConnected = path.status == .satisfied
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    func retryConnection() {
        isLoading = true
        hasTriedConnection = false
        
        // Faster connection check (0.5 seconds instead of 2)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.isLoading = false
                self.hasTriedConnection = true
            }
        }
    }
    
    deinit {
        monitor.cancel()
    }
} 