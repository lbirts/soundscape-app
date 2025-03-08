import SwiftUI

struct CategoryFilterView: View {
    @ObservedObject private var audioManager = AudioManager.shared
    @Binding var selectedCategory: SoundCategory?
    
    private var availableCategories: [SoundCategory] {
        let categorySet = Set(audioManager.sounds.map { $0.category })
        return Array(categorySet).sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        Section(header: Text("Categories")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(audioManager.availableCategories, id: \.self) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategory == category
                        ) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
        }
    }
}
