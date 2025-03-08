import SwiftUI

struct SoundToggleRow: View {
    @StateObject private var audioManager = AudioManager.shared
    let sound: Sound
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(sound.name)
                        .font(.headline)
                    
                    Text(sound.category.displayName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { sound.isActive },
                    set: { newValue in
                        withAnimation {
                            audioManager.toggleSound(id: sound.id, isOn: newValue)
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: sound.category.color))
            }
            
            if sound.isActive {
                VStack {
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
                        .accentColor(sound.category.color)
                        
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 4)
    }
}
