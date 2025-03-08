import SwiftData

@Model final class MixComponent {
    var soundId: String
    var volume: Float
    
    init(soundId: String, volume: Float) {
        self.soundId = soundId
        self.volume = volume
    }
}
