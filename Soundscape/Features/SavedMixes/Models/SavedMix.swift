import SwiftData
import Foundation

@Model final class SavedMix {
    var name: String
    var dateCreated: Date
    var mixComponents: [MixComponent]
    
    init(name: String, mixComponents: [MixComponent]) {
        self.name = name
        self.dateCreated = Date()
        self.mixComponents = mixComponents
    }
}
