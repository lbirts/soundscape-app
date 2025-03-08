import SwiftUI

struct SavedRow: View {
    let saved: SavedMix
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var showDeleteConfirmation = false
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isExpanded.toggle()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(saved.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text("\(saved.mixComponents.count) sounds")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("•")
                                .foregroundColor(.gray)
                            
                            Text(dateFormatter.string(from: saved.dateCreated))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Button(action: {
                            audioManager.loadSaved(saved: saved)
                            
                            // Optionally dismiss the sheet after loading
                            // isPresented = false
                        }) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                        }
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.8))
                        }
                        .padding(.leading, 8)
                    }
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Divider()
                    .padding(.top, 4)
                
                Text("Sounds in this mix:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                
                ForEach(saved.mixComponents, id: \.soundId) { selection in
                    if let sound = audioManager.sounds.first(where: { $0.id == selection.soundId }) {
                        HStack {
                            Text("• \(sound.name)")
                                .font(.subheadline)
                            
                            Spacer()
                            
                            Text("Volume: \(Int(selection.volume * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog(
            "Delete \(saved.name)?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                audioManager.deleteSaved(saved: saved)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}
