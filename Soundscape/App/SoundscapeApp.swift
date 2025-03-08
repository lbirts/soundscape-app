import SwiftUI
import SwiftData

@main
struct SoundscapeApp: App {
    @State private var didInitialize = false
        
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            SavedMix.self,
            MixComponent.self
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    if !didInitialize {
                        didInitialize = true
                        
                        // Delay audio setup slightly
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            AudioManager.shared.resetAudioSession()
                        }
                    }
                    
                    // Set up SwiftData context
                   let context = sharedModelContainer.mainContext
                   AudioManager.shared.setupSwiftData(context: context)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
