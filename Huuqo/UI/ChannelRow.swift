import SwiftUI

struct ChannelRow: View {
    let channelName: String
    let currentProgram: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                Rectangle()
                    .fill(.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                
                VStack(alignment: .leading) {
                    Text(channelName)
                        .font(.headline)
                    Text(currentProgram)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 10) {
        ChannelRow(
            channelName: "Sports Channel",
            currentProgram: "Live Football",
            onTap: {}
        )
        
        ChannelRow(
            channelName: "News 24/7",
            currentProgram: "Breaking News",
            onTap: {}
        )
    }
    .padding()
} 