import SwiftUI

struct SaveMixSheet: View {
    @Binding var isPresented: Bool
    @State private var nameInput = ""
    @ObservedObject private var audioManager = AudioManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Save Current Mix")) {
                    TextField("Name your mix", text: $nameInput)
                        .autocapitalization(.words)
                        .disableAutocorrection(true)
                    
                    HStack {
                        Text("Active sounds:")
                        Spacer()
                        Text("\(audioManager.activeSoundIds.count)")
                            .foregroundColor(.gray)
                    }
                }
                
                Section(header: Text("Sounds in this Mix")) {
                    if audioManager.activeSoundsList.isEmpty {
                        Text("No active sounds selected")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(audioManager.activeSoundsList) { sound in
                            HStack {
                                Text(sound.name)
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Text(sound.category.displayName)
                                        .foregroundColor(.gray)
                                    
                                    Circle()
                                        .fill(sound.category.color)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Saved Favorites")) {
                    if audioManager.saved.isEmpty {
                        Text("No saved favorites yet")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(audioManager.saved) { saved in
                            SavedRow(saved: saved)
                        }
                    }
                }
            }
            .navigationTitle("Save Mix")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Save") {
                    if !nameInput.isEmpty && !audioManager.activeSoundsList.isEmpty {
                        audioManager.saveMix(name: nameInput)
                        nameInput = ""
                        isPresented = false
                    }
                }
                .disabled(nameInput.isEmpty || audioManager.activeSoundsList.isEmpty)
            )
        }
    }
}
