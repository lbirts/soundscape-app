import SwiftUI

struct SoundControlRow: View {
    @StateObject private var audioManager = AudioManager.shared
    let sound: Sound
    
    var body: some View {
        VStack {
            HStack {
                Text(sound.name)
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    audioManager.toggleSound(id: sound.id, isOn: false)
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            HStack {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Slider(value: Binding(
                    get: { sound.volume },
                    set: { newValue in
                        audioManager.setVolume(id: sound.id, volume: newValue)
                    }
                ))
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}
