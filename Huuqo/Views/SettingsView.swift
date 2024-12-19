import SwiftUI

struct SettingsView: View {
    @State private var playerQuality = "Auto"
    @State private var enableAutoPlay = true
    @State private var enableClosedCaptions = true
    @State private var enablePictureInPicture = true
    @State private var selectedTheme = "System"
    
    private let qualityOptions = ["Auto", "1080p", "720p", "480p"]
    private let themeOptions = ["System", "Light", "Dark"]
    
    var body: some View {
        NavigationStack {
            List {
                Section("Playback Settings") {
                    Picker("Quality", selection: $playerQuality) {
                        ForEach(qualityOptions, id: \.self) { quality in
                            Text(quality)
                        }
                    }
                    
                    Toggle("Auto-Play Next Episode", isOn: $enableAutoPlay)
                    Toggle("Closed Captions", isOn: $enableClosedCaptions)
                    Toggle("Picture in Picture", isOn: $enablePictureInPicture)
                }
                
                Section("Appearance") {
                    Picker("Theme", selection: $selectedTheme) {
                        ForEach(themeOptions, id: \.self) { theme in
                            Text(theme)
                        }
                    }
                }
                
                Section("Playlist Management") {
                    NavigationLink {
                        Text("Playlist Management View")
                    } label: {
                        Label("Manage Playlists", systemImage: "list.bullet")
                    }
                    
                    NavigationLink {
                        Text("Add New Playlist View")
                    } label: {
                        Label("Add New Playlist", systemImage: "plus.circle")
                    }
                }
                
                Section("Account") {
                    NavigationLink {
                        Text("Profile Settings View")
                    } label: {
                        Label("Profile Settings", systemImage: "person.circle")
                    }
                    
                    NavigationLink {
                        Text("Subscription Details View")
                    } label: {
                        Label("Subscription Details", systemImage: "creditcard")
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink {
                        Text("Privacy Policy View")
                    } label: {
                        Text("Privacy Policy")
                    }
                    
                    NavigationLink {
                        Text("Terms of Service View")
                    } label: {
                        Text("Terms of Service")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
} 