import SwiftUI

struct LiveTVView: View {
    @State private var selectedCategory: String = "All"
    private let categories = ["All", "Sports", "News", "Entertainment", "Movies"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(categories, id: \.self) { category in
                            FilterButton(
                                title: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding()
                }
                
                // Channel Grid
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(0..<10) { index in
                            ChannelRow(
                                channelName: "Channel \(index + 1)",
                                currentProgram: "Current Program \(index + 1)"
                            ) {
                                // Handle channel selection
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Live TV")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }
}

#Preview {
    LiveTVView()
} 