import SwiftUI

enum SoundCategory: String, Codable, CaseIterable {
    case rain
    case nature
    case water
    case weather
    case animals
    case urban
    case instruments
    case white
    case meditation
    case household
    case space
    
    var displayName: String {
        switch self {
        case .rain: return "Rain"
        case .nature: return "Nature"
        case .water: return "Water"
        case .weather: return "Weather"
        case .animals: return "Animals"
        case .urban: return "Urban"
        case .instruments: return "Instruments"
        case .white: return "White Noise"
        case .meditation: return "Meditation"
        case .household: return "Household"
        case .space: return "Space"
        }
    }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.drizzle"
        case .nature: return "leaf"
        case .water: return "drop"
        case .weather: return "cloud.rain"
        case .animals: return "hare"
        case .urban: return "building.2"
        case .instruments: return "pianokeys"
        case .white: return "waveform"
        case .meditation: return "sparkles"
        case .household: return "house"
        case .space: return "star"
        }
    }
    
    var color: Color {
        switch self {
        case .rain: return .cyan
        case .nature: return .green
        case .water: return .blue
        case .weather: return .gray
        case .animals: return .orange
        case .urban: return .purple
        case .instruments: return .yellow
        case .white: return .gray
        case .meditation: return .teal
        case .household: return .pink
        case .space: return .indigo
        }
    }
}
