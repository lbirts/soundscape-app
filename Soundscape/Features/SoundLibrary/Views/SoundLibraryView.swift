import SwiftUI

struct SoundLibraryView: View {
    @StateObject private var audioManager = AudioManager.shared
    var selectedCategory: SoundCategory?
    
    var body: some View {
        Section(header: Text(selectedCategory?.displayName ?? "All Sounds")) {
            ForEach(audioManager.sounds(in: selectedCategory)) { sound in
                SoundToggleRow(sound: sound)
            }
        }
    }
}
