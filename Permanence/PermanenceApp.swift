//import SwiftUI
//import SwiftData
//
//@main
//struct PermanenceApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(createCloudKitContainer())
//    }
//}
//
//func createCloudKitContainer() -> ModelContainer {
//    let schema = Schema([
//        QualityNote.self,
//        QualityGroup.self,
//        QualityTopic.self,
//        QualityComparison.self,
//        QualitySession.self
//    ])
//
//    // CloudKit configuration for iCloud sync
//    let cloudKitConfiguration = ModelConfiguration(
//        schema: schema,
//        isStoredInMemoryOnly: false,
//        allowsSave: true,
//        cloudKitDatabase: .automatic // This enables iCloud sync
//    )
//
//    do {
//        let container = try ModelContainer(for: schema, configurations: [cloudKitConfiguration])
//        print("✅ CloudKit ModelContainer created successfully")
//        return container
//    } catch {
//        print("❌ CloudKit ModelContainer error: \(error)")
//
//        // Fallback to local storage if CloudKit fails
//        let localConfiguration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false
//        )
//
//        do {
//            let localContainer = try ModelContainer(for: schema, configurations: [localConfiguration])
//            print("⚠️ Using local storage only (CloudKit unavailable)")
//            return localContainer
//        } catch {
//            print("❌ Local ModelContainer error: \(error)")
//
//            // Final fallback - in-memory only
//            let memoryConfiguration = ModelConfiguration(
//                schema: schema,
//                isStoredInMemoryOnly: true
//            )
//
//            do {
//                let memoryContainer = try ModelContainer(for: schema, configurations: [memoryConfiguration])
//                print("⚠️ Using in-memory storage only")
//                return memoryContainer
//
//            } catch {
//                fatalError("Could not create any ModelContainer: \(error)")
//            }
//        }
//    }
//}
//

import SwiftUI
import SwiftData

@main
struct PermanenceApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(createCloudKitContainer())
    }
}

func createCloudKitContainer() -> ModelContainer {
    let schema = Schema([
        QualityNote.self,
        QualityGroup.self,
        QualityTopic.self,
        QualityComparison.self,
        QualitySession.self
    ])

    // CloudKit configuration for iCloud sync
    let cloudKitConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false,
        allowsSave: true,
        cloudKitDatabase: .automatic // This enables iCloud sync
    )

    do {
        let container = try ModelContainer(for: schema, configurations: [cloudKitConfiguration])
        print("✅ CloudKit ModelContainer created successfully")
        return container
    } catch {
        print("❌ CloudKit ModelContainer error: \(error)")

        // Fallback to local storage if CloudKit fails
        let localConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let localContainer = try ModelContainer(for: schema, configurations: [localConfiguration])
            print("⚠️ Using local storage only (CloudKit unavailable)")
            return localContainer
        } catch {
            print("❌ Local ModelContainer error: \(error)")

            // Final fallback - in-memory only
            let memoryConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )

            do {
                let memoryContainer = try ModelContainer(for: schema, configurations: [memoryConfiguration])
                print("⚠️ Using in-memory storage only")
                return memoryContainer
                
            } catch {
                fatalError("Could not create any ModelContainer: \(error)")
            }
        }
    }
}


//deleting one
//import SwiftUI
//import SwiftData
//
//@main
//struct PermanenceApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(createCloudKitContainer())
//    }
//}
//
//@MainActor func createCloudKitContainer() -> ModelContainer {
//    let schema = Schema([
//        QualityNote.self,
//        QualityGroup.self,
//        QualityTopic.self,
//        QualityComparison.self,
//        QualitySession.self
//    ])
//
//    // CloudKit configuration for iCloud sync
//    let cloudKitConfiguration = ModelConfiguration(
//        schema: schema,
//        isStoredInMemoryOnly: false,
//        allowsSave: true,
//        cloudKitDatabase: .automatic // This enables iCloud sync
//    )
//
//    do {
//        let container = try ModelContainer(for: schema, configurations: [cloudKitConfiguration])
//        
//        // TEMPORARY: Clear old incompatible data
//        let context = container.mainContext
//        do {
//            try context.delete(model: QualityNote.self)
//            try context.delete(model: QualityGroup.self)
//            try context.delete(model: QualityTopic.self)
//            try context.delete(model: QualityComparison.self)
//            try context.delete(model: QualitySession.self)
//            try context.save()
//            print("🗑️ Cleared old incompatible data")
//        } catch {
//            print("⚠️ Clear data warning: \(error)")
//        }
//        
//        print("✅ CloudKit ModelContainer created successfully")
//        return container
//    } catch {
//        print("❌ CloudKit ModelContainer error: \(error)")
//
//        // Fallback to local storage if CloudKit fails
//        let localConfiguration = ModelConfiguration(
//            schema: schema,
//            isStoredInMemoryOnly: false
//        )
//
//        do {
//            let localContainer = try ModelContainer(for: schema, configurations: [localConfiguration])
//            
//            // TEMPORARY: Clear old incompatible data for local container too
//            let context = localContainer.mainContext
//            do {
//                try context.delete(model: QualityNote.self)
//                try context.delete(model: QualityGroup.self)
//                try context.delete(model: QualityTopic.self)
//                try context.delete(model: QualityComparison.self)
//                try context.delete(model: QualitySession.self)
//                try context.save()
//                print("🗑️ Cleared old incompatible data (local)")
//            } catch {
//                print("⚠️ Clear data warning (local): \(error)")
//            }
//            
//            print("⚠️ Using local storage only (CloudKit unavailable)")
//            return localContainer
//        } catch {
//            print("❌ Local ModelContainer error: \(error)")
//
//            // Final fallback - in-memory only
//            let memoryConfiguration = ModelConfiguration(
//                schema: schema,
//                isStoredInMemoryOnly: true
//            )
//
//            do {
//                let memoryContainer = try ModelContainer(for: schema, configurations: [memoryConfiguration])
//                print("⚠️ Using in-memory storage only")
//                return memoryContainer
//                
//            } catch {
//                fatalError("Could not create any ModelContainer: \(error)")
//            }
//        }
//    }
//}


//previous from deleting one
//import SwiftUI
//import SwiftData
//import Foundation
//
//// MARK: - Fixed CloudKit-Compatible Data Models
//@Model
//final class QualityNote {
//    var title: String = ""
//    var content: String = ""
//    
//    // FIXED: Use @Attribute(.transformable) for arrays in CloudKit
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
//    var tags: [String] = []
//    
//    var qualityScore: Double = 0.0
//    var createdDate: Date = Date()
//    var lastModified: Date = Date()
//    
//    // Simplified: Remove circular references for CloudKit
//    var groupID: String? = nil
//    
//    init(title: String, content: String, tags: [String] = [], qualityScore: Double = 0.0) {
//        self.title = title
//        self.content = content
//        self.tags = tags
//        self.qualityScore = qualityScore
//        self.createdDate = Date()
//        self.lastModified = Date()
//    }
//}
//
//@Model
//final class QualityGroup {
//    var id: String = UUID().uuidString
//    var isPermanent: Bool = false
//    var permanenceDate: Date? = nil
//    var permanenceConfidence: Double = 0.0
//    var createdDate: Date = Date()
//    
//    // FIXED: Use @Attribute(.transformable) for arrays
//    var frontCardID: String? = nil
//    
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
//    var supportingCardIDs: [String] = []
//    
//    var topicID: String? = nil
//    
//    init(frontCardID: String? = nil, supportingCardIDs: [String] = [], isPermanent: Bool = false) {
//        self.frontCardID = frontCardID
//        self.supportingCardIDs = supportingCardIDs
//        self.isPermanent = isPermanent
//        self.permanenceConfidence = 0.0
//        self.createdDate = Date()
//    }
//}
//
//@Model
//final class QualityTopic {
//    var id: String = UUID().uuidString
//    var name: String = ""
//    var topicDescription: String = ""
//    var createdDate: Date = Date()
//    var isActive: Bool = true
//    
//    // FIXED: Use @Attribute(.transformable) for arrays
//    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
//    var groupIDs: [String] = []
//    
//    init(name: String, topicDescription: String = "") {
//        self.name = name
//        self.topicDescription = topicDescription
//        self.createdDate = Date()
//        self.isActive = true
//    }
//}
//
//@Model
//final class QualityComparison {
//    var noteAID: String = ""
//    var noteBID: String = ""
//    var chosenNoteID: String = ""
//    var comparisonDate: Date = Date()
//    var sessionType: String = "gradual"
//    
//    init(noteAID: String = "", noteBID: String = "", chosenNoteID: String = "", sessionType: String = "gradual") {
//        self.noteAID = noteAID
//        self.noteBID = noteBID
//        self.chosenNoteID = chosenNoteID
//        self.comparisonDate = Date()
//        self.sessionType = sessionType
//    }
//}
//
//@Model
//final class QualitySession {
//    var sessionType: String = "gradual"
//    var startDate: Date = Date()
//    var endDate: Date? = nil
//    var comparisonsCount: Int = 0
//    var isComplete: Bool = false
//    
//    init(sessionType: String = "gradual") {
//        self.sessionType = sessionType
//        self.startDate = Date()
//        self.comparisonsCount = 0
//        self.isComplete = false
//    }
//}



//import SwiftUI
//import SwiftData
//import Foundation
//
//// MARK: - String-Based CloudKit-Compatible Data Models
//@Model
//final class QualityNote {
//    var title: String = ""
//    var content: String = ""
//    
//    // FIXED: Use comma-separated string instead of array
//    var tagsString: String = ""
//    
//    var qualityScore: Double = 0.0
//    var createdDate: Date = Date()
//    var lastModified: Date = Date()
//    var groupID: String? = nil
//    
//    // Computed property for easy array access
//    var tags: [String] {
//        get {
//            guard !tagsString.isEmpty else { return [] }
//            return tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//        }
//        set {
//            tagsString = newValue.joined(separator: ",")
//        }
//    }
//    
//    init(title: String, content: String, tags: [String] = [], qualityScore: Double = 0.0) {
//        self.title = title
//        self.content = content
//        self.tagsString = tags.joined(separator: ",")
//        self.qualityScore = qualityScore
//        self.createdDate = Date()
//        self.lastModified = Date()
//    }
//}
//
//@Model
//final class QualityGroup {
//    var id: String = UUID().uuidString
//    var isPermanent: Bool = false
//    var permanenceDate: Date? = nil
//    var permanenceConfidence: Double = 0.0
//    var createdDate: Date = Date()
//    var frontCardID: String? = nil
//    var topicID: String? = nil
//    
//    // FIXED: Use comma-separated string
//    var supportingCardIDsString: String = ""
//    
//    // Computed property for easy array access
//    var supportingCardIDs: [String] {
//        get {
//            guard !supportingCardIDsString.isEmpty else { return [] }
//            return supportingCardIDsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//        }
//        set {
//            supportingCardIDsString = newValue.joined(separator: ",")
//        }
//    }
//    
//    init(frontCardID: String? = nil, supportingCardIDs: [String] = [], isPermanent: Bool = false) {
//        self.frontCardID = frontCardID
//        self.supportingCardIDsString = supportingCardIDs.joined(separator: ",")
//        self.isPermanent = isPermanent
//        self.permanenceConfidence = 0.0
//        self.createdDate = Date()
//    }
//}
//
//@Model
//final class QualityTopic {
//    var id: String = UUID().uuidString
//    var name: String = ""
//    var topicDescription: String = ""
//    var createdDate: Date = Date()
//    var isActive: Bool = true
//    
//    // FIXED: Use comma-separated string
//    var groupIDsString: String = ""
//    
//    // Computed property for easy array access
//    var groupIDs: [String] {
//        get {
//            guard !groupIDsString.isEmpty else { return [] }
//            return groupIDsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//        }
//        set {
//            groupIDsString = newValue.joined(separator: ",")
//        }
//    }
//    
//    init(name: String, topicDescription: String = "") {
//        self.name = name
//        self.topicDescription = topicDescription
//        self.createdDate = Date()
//        self.isActive = true
//    }
//}
//
//@Model
//final class QualityComparison {
//    var noteAID: String = ""
//    var noteBID: String = ""
//    var chosenNoteID: String = ""
//    var comparisonDate: Date = Date()
//    var sessionType: String = "gradual"
//    
//    init(noteAID: String = "", noteBID: String = "", chosenNoteID: String = "", sessionType: String = "gradual") {
//        self.noteAID = noteAID
//        self.noteBID = noteBID
//        self.chosenNoteID = chosenNoteID
//        self.comparisonDate = Date()
//        self.sessionType = sessionType
//    }
//}
//
//@Model
//final class QualitySession {
//    var sessionType: String = "gradual"
//    var startDate: Date = Date()
//    var endDate: Date? = nil
//    var comparisonsCount: Int = 0
//    var isComplete: Bool = false
//    
//    init(sessionType: String = "gradual") {
//        self.sessionType = sessionType
//        self.startDate = Date()
//        self.comparisonsCount = 0
//        self.isComplete = false
//    }
//}
