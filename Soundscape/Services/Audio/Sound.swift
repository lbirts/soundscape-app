struct Sound: Identifiable, Codable {
    let id: String
    let name: String
    let fileName: String
    let category: SoundCategory
    var isActive: Bool = false
    var volume: Float = 0.7
    
    enum CodingKeys: String, CodingKey {
        case id, name, fileName, category
    }
}
