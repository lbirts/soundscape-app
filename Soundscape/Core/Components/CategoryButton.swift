import SwiftUI

struct CategoryButton: View {
    let category: SoundCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
            VStack {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : category.color.opacity(0.8))
                }
                .shadow(color: isSelected ? category.color.opacity(0.4) : Color.clear, radius: 4)
                
                Text(category.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? category.color : .primary)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    action()
                }
            }
        }
}
