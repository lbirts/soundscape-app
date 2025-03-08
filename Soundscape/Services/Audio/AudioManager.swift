import AVFoundation
import SwiftUI
import SwiftData
import Combine

class AudioManager: ObservableObject {
    // MARK: - Published Properties
    @Published var sounds: [Sound] = []
    @Published var activeSoundIds: [String] = []
    @Published var saved: [SavedMix] = []
       
   // MARK: - Private Properties
   private var audioPlayers: [String: AVAudioPlayer] = [:]
   private var isLoadingSavedMix = false
   private var modelContext: ModelContext?

    // MARK: - Singleton Instance
    static let shared = AudioManager()
    
    // MARK: - Initialization
    private init() {
        setupAudioSession()
        loadSoundLibrary()
    }
    
    // MARK: - SwiftData Setup
    func setupSwiftData(context: ModelContext) {
        self.modelContext = context
        loadSaved()
    }
    
    // MARK: - Audio Setup
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            
            // Optimize audio settings
            try session.setPreferredSampleRate(44100)
            try session.setPreferredIOBufferDuration(0.01)
            
            // Enable background playback
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .duckOthers])
            try session.setActive(true)
            
            // Add interruption handling
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAudioInterruption),
                name: AVAudioSession.interruptionNotification,
                object: nil
            )
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    @objc private func handleAudioInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
            return
        }
        
        switch type {
        case .began:
            // Audio was interrupted - nothing to do, iOS will pause playback
            break
            
        case .ended:
            // Interruption ended - resume playing active sounds
            guard let optionsInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
                  AVAudioSession.InterruptionOptions(rawValue: optionsInt).contains(.shouldResume) else {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                // Resume playback of all active sounds
                self?.resumeAllActiveSounds()
            }
            
        @unknown default:
            break
        }
    }
    
    func resetAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            // Wait a moment
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                    self?.resumeAllActiveSounds()
                } catch {
                    print("Failed to reactivate audio session: \(error)")
                }
            }
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }
    
    private func resumeAllActiveSounds() {
        for id in activeSoundIds {
            audioPlayers[id]?.play()
        }
    }
    
    // MARK: - Sound Library Management
    private func loadSoundLibrary() {
        if let url = Bundle.main.url(forResource: "sounds", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                sounds = try decoder.decode([Sound].self, from: data)
                preloadSounds()
            } catch {
                print("Error loading sounds: \(error)")
                loadDefaultSounds()
            }
        } else {
            loadDefaultSounds()
        }
    }
    
    private func loadDefaultSounds() {
        // Fallback with some default sounds
        let natureCategory = SoundCategory.nature
        sounds = [
            Sound(id: "forest", name: "Forest", fileName: "forest.mp3", category: natureCategory),
            Sound(id: "birds", name: "Birds", fileName: "birds.mp3", category: natureCategory)
        ]
        
        preloadSounds()
    }
    
    private func preloadSounds() {
        for sound in sounds {
            if let fileName = sound.fileName.components(separatedBy: ".").first,
               let fileExtension = sound.fileName.components(separatedBy: ".").last,
               let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
                loadSound(id: sound.id, url: url)
            } else {
                print("Could not find sound file: \(sound.fileName)")
            }
        }
    }
    
    private func loadSound(id: String, url: URL) {
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0.7
            player.prepareToPlay()
            audioPlayers[id] = player
        } catch {
            print("Could not load sound: \(error)")
        }
    }
    
    // MARK: - Sound Control
    func toggleSound(id: String, isOn: Bool) {
        guard let player = audioPlayers[id] else { return }
        
        // Update model
        if let index = sounds.firstIndex(where: { $0.id == id }) {
            sounds[index].isActive = isOn
        }
        
        // Track active sounds
        if isOn {
            if !activeSoundIds.contains(id) {
                activeSoundIds.append(id)
            }
            
            // Start playback with fade-in for smoother transitions
            player.volume = 0
            player.currentTime = 0
            player.play()
            
            // Gradually fade in the volume
            let targetVolume = sounds.first(where: { $0.id == id })?.volume ?? 0.7
            fadeVolumeIn(player: player, to: targetVolume)
        } else {
            // Remove from active sounds if not loading a favorite
            if !isLoadingSavedMix, let index = activeSoundIds.firstIndex(of: id) {
                activeSoundIds.remove(at: index)
            }
            
            // Fade out and stop playback
            fadeVolumeOut(player: player) {
                player.stop()
            }
        }
    }
    
    private func fadeVolumeIn(player: AVAudioPlayer, to targetVolume: Float, duration: TimeInterval = 0.3) {
        var currentVolume: Float = 0
        let step: Float = 0.05
        let stepTime = duration * Double(step / targetVolume)
        
        Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            currentVolume += step
            player.volume = min(currentVolume, targetVolume)
            
            if currentVolume >= targetVolume {
                timer.invalidate()
            }
        }
    }
    
    private func fadeVolumeOut(player: AVAudioPlayer, duration: TimeInterval = 0.3, completion: @escaping () -> Void) {
        let originalVolume = player.volume
        var currentVolume = originalVolume
        let step: Float = 0.05
        let stepTime = duration * Double(step / originalVolume)
        
        Timer.scheduledTimer(withTimeInterval: stepTime, repeats: true) { timer in
            currentVolume -= step
            player.volume = max(currentVolume, 0)
            
            if currentVolume <= 0 {
                timer.invalidate()
                completion()
            }
        }
    }
    
    func setVolume(id: String, volume: Float) {
        guard let player = audioPlayers[id] else { return }
        
        // Update model
        if let index = sounds.firstIndex(where: { $0.id == id }) {
            sounds[index].volume = volume
        }
        
        // Set volume on player (with a slight smoothing)
        UIView.animate(withDuration: 0.1) {
            player.volume = volume
        }
    }
    
    // MARK: - Favorites Management
    private func loadSaved() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<SavedMix>(sortBy: [SortDescriptor(\.dateCreated, order: .reverse)])
            saved = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch favorites: \(error)")
            saved = []
        }
    }
    
    func saveMix(name: String) {
        guard let context = modelContext else { return }
        
        var mixComponents: [MixComponent] = []
        for sound in sounds.filter({ $0.isActive }) {
            let component = MixComponent(soundId: sound.id, volume: sound.volume)
            mixComponents.append(component)
        }
        
        // Create and save the favorite mix
        let newSaved = SavedMix(name: name, mixComponents: mixComponents)
        context.insert(newSaved)
        
        do {
            try context.save()
            loadSaved() // Refresh the favorites list
        } catch {
            print("Failed to save favorite: \(error)")
        }
    }
    
    func loadSaved(saved: SavedMix) {
        isLoadingSavedMix = true
        
        // First stop all active sounds
        for sound in sounds where sound.isActive {
            toggleSound(id: sound.id, isOn: false)
        }
        
        // Clear active sounds list
        activeSoundIds.removeAll()
        
        // Small delay to allow sounds to stop
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Activate saved sounds with their saved volumes
            for component in saved.mixComponents {
                if let index = self.sounds.firstIndex(where: { $0.id == component.soundId }) {
                    // Set the volume first
                    self.sounds[index].volume = component.volume
                    if let player = self.audioPlayers[component.soundId] {
                        player.volume = component.volume
                    }
                    
                    // Add to active sounds
                    self.activeSoundIds.append(component.soundId)
                    
                    // Turn on the sound
                    self.toggleSound(id: component.soundId, isOn: true)
                }
            }
            
            self.isLoadingSavedMix = false
        }
    }
    
    func deleteSaved(saved: SavedMix) {
        guard let context = modelContext else { return }
        
        context.delete(saved)
        
        do {
            try context.save()
            loadSaved() // Refresh the favorites list
        } catch {
            print("Failed to delete favorite: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    var availableCategories: [SoundCategory] {
        let categorySet = Set(sounds.map { $0.category })
        return Array(categorySet).sorted { $0.displayName < $1.displayName }
    }
    
    func sounds(in category: SoundCategory?) -> [Sound] {
        if let category = category {
            return sounds.filter { $0.category == category }
        } else {
            return sounds
        }
    }
    
    var activeSoundsList: [Sound] {
        return sounds.filter { $0.isActive }
    }
}
