import SwiftUI

struct ActiveSoundsView: View {
    @StateObject private var audioManager = AudioManager.shared
    
    var body: some View {
        Section(header: Text("Active Sounds")) {
            ForEach(audioManager.activeSoundsList) { sound in
                SoundControlRow(sound: sound)
            }
            .onDelete { indexSet in
                // Deactivate sounds at these indices
                let activeSounds = audioManager.sounds.filter { $0.isActive }
                indexSet.forEach { index in
                    let sound = activeSounds[index]
                    audioManager.toggleSound(id: sound.id, isOn: false)
                }
            }
        }
    }
}
