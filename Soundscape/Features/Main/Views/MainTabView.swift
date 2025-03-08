import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SoundscapeView()
                .tabItem {
//                    Label("Soundscape", systemName: "speaker.wave.3")
                }
            
            SavedMixesView()
                .tabItem {
//                    Label("Saved Mixes", systemName: "music.note.list")
                }
        }
    }
}
