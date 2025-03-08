import SwiftUI

struct SoundscapeView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    @State private var selectedCategory: SoundCategory? = nil
    @State private var isSaveSheetPresented = false
    
    var body: some View {
        NavigationView {
            List {
                // Categories section
                CategoryFilterView(selectedCategory: $selectedCategory)
                
                // Active sounds section
                ActiveSoundsView()
                
                // Sound library section filtered by category
                SoundLibraryView(selectedCategory: selectedCategory)
            }
            .navigationTitle("SoundScape")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
//                        isFavoritesSheetPresented = true
                    }) {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.pink)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    SoundscapeMenuView(presentAction: { isSaveSheetPresented = true })
                }
            }
            .sheet(isPresented: $isSaveSheetPresented) {
                SaveMixSheet(isPresented: $isSaveSheetPresented)
            }
        }
    }
}
