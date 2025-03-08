import SwiftUI

struct SoundscapeMenuView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    let presentAction: () -> Void

    var body: some View {
        Menu {
           Button(action: presentAction) {
               Label("Save Current Mix", systemImage: "square.and.arrow.down")
           }
           
           if !audioManager.saved.isEmpty {
               Menu("Load Saved Mixes") {
                   ForEach(audioManager.saved) { saved in
                       Button(saved.name) {
                           audioManager.loadSaved(saved: saved)
                       }
                   }
               }
           }
           
           Divider()
           
           Button(action: {
               // Stop all sounds
               for sound in audioManager.activeSoundsList {
                   audioManager.toggleSound(id: sound.id, isOn: false)
               }
           }) {
               Label("Stop All Sounds", systemImage: "stop.circle")
           }
            
            Button("Add Custom Sound") {
                // Show file picker
            }
            
            Button(action: {
                // Reset audio session if there are issues
                audioManager.resetAudioSession()
            }) {
                Label("Fix Audio Issues", systemImage: "speaker.wave.3.fill")
            }


       } label: {
           Image(systemName: "ellipsis.circle")
       }
    }
}
