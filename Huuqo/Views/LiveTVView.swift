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
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(selectedCategory == category ? .black : .white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == category ? Color.white : Color.gray.opacity(0.3))
                                    )
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