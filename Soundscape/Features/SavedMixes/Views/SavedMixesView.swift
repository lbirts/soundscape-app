import SwiftUI

struct SavedMixesView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    
    var body: some View {
        NavigationView {
            List {
                if audioManager.saved.isEmpty {
                    ContentUnavailableView(
                        "No Saved Mixes",
                        systemImage: "heart.slash",
                        description: Text("Your saved sound mixes will appear here.")
                    )
                } else {
                    ForEach(audioManager.saved) { saved in
                        SavedRow(saved: saved)
                    }
                }
            }
        }
    }
}
