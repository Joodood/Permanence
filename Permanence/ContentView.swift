import SwiftUI
import SwiftData
import Foundation

// Add this to the top of BOTH ContentView.swift AND DetailViews.swift

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Platform Extensions (FIXED)
extension View {
    func universalNavigationBarTitleDisplayModeInline() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }
}

extension ToolbarItemPlacement {
    static var universalLeading: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarLeading
        #else
        return .navigation
        #endif
    }
    
    static var universalTrailing: ToolbarItemPlacement {
        #if os(iOS)
        return .navigationBarTrailing
        #else
        return .navigation
        #endif
    }
}

// MARK: - Simplified CloudKit-Compatible Data Models
@Model
final class QualityNote {
    var title: String = ""
    var content: String = ""
    
//    var tags: [String] = []
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
    var tags: [String] = []

    
    var qualityScore: Double = 0.0
    var createdDate: Date = Date()
    var lastModified: Date = Date()
    
    // Simplified: Remove circular references
    var groupID: String? = nil  // Instead of direct relationship
    
    init(title: String, content: String, tags: [String] = [], qualityScore: Double = 0.0) {
        self.title = title
        self.content = content
        self.tags = tags
        self.qualityScore = qualityScore
        self.createdDate = Date()
        self.lastModified = Date()
    }
}

@Model
final class QualityGroup {
    var id: String = UUID().uuidString
    var isPermanent: Bool = false
    var permanenceDate: Date? = nil
    var permanenceConfidence: Double = 0.0
    var createdDate: Date = Date()
    
    // Simplified: Use IDs instead of direct relationships
    var frontCardID: String? = nil
    
    
//    var supportingCardIDs: [String] = []
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
    var supportingCardIDs: [String] = []
    
    var topicID: String? = nil
    
    init(frontCardID: String? = nil, supportingCardIDs: [String] = [], isPermanent: Bool = false) {
        self.frontCardID = frontCardID
        self.supportingCardIDs = supportingCardIDs
        self.isPermanent = isPermanent
        self.permanenceConfidence = 0.0
        self.createdDate = Date()
    }
}

@Model
final class QualityTopic {
    var id: String = UUID().uuidString
    var name: String = ""
    var topicDescription: String = ""
    var createdDate: Date = Date()
    var isActive: Bool = true
    
    // Simplified: Use IDs instead of direct relationships
    
    //even more simplified
//    var groupIDs: [String] = []
    @Attribute(.transformable(by: "NSSecureUnarchiveFromData"))
    var groupIDs: [String] = []
    
    
    init(name: String, topicDescription: String = "") {
        self.name = name
        self.topicDescription = topicDescription
        self.createdDate = Date()
        self.isActive = true
    }
}

@Model
final class QualityComparison {
    var noteAID: String = ""
    var noteBID: String = ""
    var chosenNoteID: String = ""
    var comparisonDate: Date = Date()
    var sessionType: String = "gradual"
    
    init(noteAID: String = "", noteBID: String = "", chosenNoteID: String = "", sessionType: String = "gradual") {
        self.noteAID = noteAID
        self.noteBID = noteBID
        self.chosenNoteID = chosenNoteID
        self.comparisonDate = Date()
        self.sessionType = sessionType
    }
}

@Model
final class QualitySession {
    var sessionType: String = "gradual"
    var startDate: Date = Date()
    var endDate: Date? = nil
    var comparisonsCount: Int = 0
    var isComplete: Bool = false
    
    init(sessionType: String = "gradual") {
        self.sessionType = sessionType
        self.startDate = Date()
        self.comparisonsCount = 0
        self.isComplete = false
    }
}

// MARK: - Drawing Models (unchanged)
struct Drawing: Codable {
    var points: [DrawingPoint] = []
    var color: DrawingColor = .black
    var lineWidth: CGFloat = 3.0
    
    init() {}
    
    init(points: [DrawingPoint], color: DrawingColor, lineWidth: CGFloat) {
        self.points = points
        self.color = color
        self.lineWidth = lineWidth
    }
}

struct DrawingPoint: Codable {
    let x: CGFloat
    let y: CGFloat
    
    var location: CGPoint {
        CGPoint(x: x, y: y)
    }
    
    init(location: CGPoint) {
        self.x = location.x
        self.y = location.y
    }
}

enum DrawingColor: String, Codable, CaseIterable {
    case black, blue, red, green, orange, purple, brown, pink
    
    var color: Color {
        switch self {
        case .black: return .black
        case .blue: return .blue
        case .red: return .red
        case .green: return .green
        case .orange: return .orange
        case .purple: return .purple
        case .brown: return .brown
        case .pink: return .pink
        }
    }
}

// MARK: - QualityNote Extensions (updated for new model)
extension QualityNote {
    var hasDrawing: Bool {
        content.contains("DRAWING_DATA:") && tags.contains("drawing")
    }
    
    var isDrawingNote: Bool {
        tags.contains("drawing") || tags.contains("sketch")
    }
    
    var drawingData: Data? {
        guard hasDrawing else { return nil }
        
        let lines = content.components(separatedBy: .newlines)
        for line in lines {
            if line.hasPrefix("DRAWING_DATA:") {
                let base64String = String(line.dropFirst("DRAWING_DATA:".count))
                return Data(base64Encoded: base64String)
            }
        }
        return nil
    }
    
    // FIXED: Remove references to .group since we're using IDs now
    var group: QualityGroup? {
        return nil // Will need to implement lookup by groupID if needed
    }
    
    static func createWithDrawing(title: String, content: String, tags: [String], drawingData: Data?) -> QualityNote {
        var finalContent = content
        var finalTags = tags
        
        if let drawingData = drawingData {
            let base64String = drawingData.base64EncodedString()
            finalContent += "\nDRAWING_DATA:\(base64String)"
            
            if !finalTags.contains("drawing") {
                finalTags.append("drawing")
            }
            if !finalTags.contains("sketch") {
                finalTags.append("sketch")
            }
        }
        
        return QualityNote(title: title, content: finalContent, tags: finalTags)
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var qualityNotes: [QualityNote]
    @Query private var qualityGroups: [QualityGroup]
    @Query private var qualityTopics: [QualityTopic]
    
    @State private var selectedMode: InterfaceMode = .overview
    @State private var showingImport = false
    @State private var showingDeleteConfirmation = false
    
    var uNotes: [QualityNote] {
        qualityNotes.filter { $0.tags.contains("u-notes") }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $selectedMode) {
                    ForEach(InterfaceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                switch selectedMode {
                case .overview:
                    if qualityNotes.isEmpty {
                        QualityOnboardingView(modelContext: modelContext)
                    } else {
                        QualitySystemOverview(
                            notes: qualityNotes,
                            groups: qualityGroups,
                            topics: qualityTopics,
                            modelContext: modelContext
                        )
                    }
                    
                case .notes:
                    if qualityNotes.isEmpty {
                        QualityOnboardingView(modelContext: modelContext)
                    } else {
                        NotesListView(notes: qualityNotes, modelContext: modelContext)
                    }
                    
                case .groups:
                    if qualityGroups.isEmpty {
                        EmptyStateView(
                            title: "No Groups Yet",
                            message: "Start quality sensing to form groups",
                            systemImage: "mountain.2"
                        )
                    } else {
                        GroupsListView(groups: qualityGroups)
                    }
                    
                case .topics:
                    if qualityTopics.isEmpty {
                        EmptyStateView(
                            title: "No Topics Yet",
                            message: "Groups will crystallize into topics",
                            systemImage: "folder"
                        )
                    } else {
                        TopicsListView(topics: qualityTopics)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Permanence")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("Import") {
                            showingImport = true
                        }
                        
                        if !uNotes.isEmpty {
                            Button("Clear U-Notes (\(uNotes.count))", role: .destructive) {
                                showingDeleteConfirmation = true
                            }
                        }
                        
                        NavigationLink("🔍 Debug Data") {
                            DebugView()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        
        //was too small on mac catalyst
//        .sheet(isPresented: $showingImport) {
//            ImportNotesView(modelContext: modelContext)
//        }
        .sheet(isPresented: $showingImport) {
            ImportNotesView(modelContext: modelContext)
                .frame(minWidth: 600, minHeight: 500)
        }

        //was too small on mac catalyst too
//        .sheet(isPresented: $showingImport) {
//            ImportNotesView(modelContext: modelContext)
//                .presentationDetents([.large]) // This fixes iPhone sizing
//        }
//        
        .alert("Delete All U-Notes?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete \(uNotes.count) U-Notes", role: .destructive) {
                clearAllUNotes()
            }
        } message: {
            Text("This will permanently delete all \(uNotes.count) U-notes. This action cannot be undone.")
        }
    }
    
    private func clearAllUNotes() {
        let uNotesToDelete = qualityNotes.filter { $0.tags.contains("u-notes") }
        for note in uNotesToDelete {
            modelContext.delete(note)
        }
        try? modelContext.save()
    }
}

enum InterfaceMode: String, CaseIterable {
    case overview = "Overview"
    case notes = "Notes"
    case groups = "Groups"
    case topics = "Topics"
}

// MARK: - Onboarding View
struct QualityOnboardingView: View {
    let modelContext: ModelContext
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "mountain.2")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Welcome to Permanence")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Import your notes to begin quality sensing and group formation")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Add Sample Notes") {
                addSampleNotes()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func addSampleNotes() {
        let sampleNotes = [
            QualityNote(title: "Music Theory Basics", content: "Understanding chord progressions and harmonic relationships", tags: ["music", "theory"]),
            QualityNote(title: "SwiftUI Architecture", content: "MVVM patterns and state management in SwiftUI applications", tags: ["swift", "architecture"]),
            QualityNote(title: "Quality Philosophy", content: "Robert Pirsig's insights on quality and note organization", tags: ["philosophy", "quality"]),
            QualityNote(title: "Band Practice Ideas", content: "Song arrangements and rehearsal scheduling thoughts", tags: ["music", "band"]),
            QualityNote(title: "Code Review Process", content: "Best practices for effective team code reviews", tags: ["development", "process"])
        ]
        
        for note in sampleNotes {
            modelContext.insert(note)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

// MARK: - Notes List View (FIXED)
struct NotesListView: View {
    let notes: [QualityNote]
    let modelContext: ModelContext
    
    var sortedNotes: [QualityNote] {
        notes.sorted { $0.qualityScore > $1.qualityScore }
    }
    
    var body: some View {
        List {
            // FIXED: Use the computed property and direct iteration
            ForEach(sortedNotes, id: \.title) { note in
                NavigationLink {
                    NoteDetailView(note: note)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(displayTitle(for: note))
                            .font(.headline)
                            .lineLimit(1)
                            .foregroundColor(displayTitle(for: note).isEmpty ? .secondary : .primary)
                        
                        Text(displayContent(for: note))
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        HStack {
                            if note.qualityScore > 0 {
                                Text("Quality: \(note.qualityScore, specifier: "%.2f")")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            if note.groupID != nil {
                                Text("Grouped")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            if note.tags.contains("u-notes") {
                                Text("U-Note")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            if note.isDrawingNote {
                                Text("Drawing")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .onDelete(perform: deleteNotes)
        }
    }
    
    private func displayTitle(for note: QualityNote) -> String {
        if note.tags.contains("u-notes") && note.content.isEmpty {
            if note.title.hasPrefix("U-") {
                let withoutPrefix = String(note.title.dropFirst(2)).trimmingCharacters(in: .whitespacesAndNewlines)
                return withoutPrefix.isEmpty ? "" : withoutPrefix
            }
        }
        return note.title
    }
    
    private func displayContent(for note: QualityNote) -> String {
        return note.content.isEmpty ? "No content" : note.content
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sortedNotes[index])
            }
        }
    }
}

// MARK: - Groups List View (FIXED)
struct GroupsListView: View {
    let groups: [QualityGroup]
    
    var body: some View {
        List(groups, id: \.id) { group in
            NavigationLink {
                GroupDetailView(group: group)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Group \(group.id.prefix(8))")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(group.supportingCardIDs.count) supporting cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        if group.isPermanent {
                            Text("Permanent")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(4)
                        } else {
                            Text("Forming")
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - Topics List View (FIXED)
struct TopicsListView: View {
    let topics: [QualityTopic]
    
    var body: some View {
        List(topics, id: \.id) { topic in
            NavigationLink {
                TopicDetailView(topic: topic)
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text(topic.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if !topic.topicDescription.isEmpty {
                        Text(topic.topicDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    Text("\(topic.groupIDs.count) groups")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 2)
            }
        }
    }
}

// MARK: - System Overview
struct QualitySystemOverview: View {
    let notes: [QualityNote]
    let groups: [QualityGroup]
    let topics: [QualityTopic]
    let modelContext: ModelContext
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Permanence")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Quality Sensing System")
                .font(.title2)
                .foregroundColor(.secondary)
            
            QualitySystemStats(notes: notes, groups: groups, topics: topics)
        }
        .padding()
    }
}

struct QualitySystemStats: View {
    let notes: [QualityNote]
    let groups: [QualityGroup]
    let topics: [QualityTopic]
    
    var qualityProgress: Double {
        let rankedNotes = notes.filter { $0.qualityScore > 0 }.count
        return notes.isEmpty ? 0 : Double(rankedNotes) / Double(notes.count)
    }
    
    var uNotesCount: Int {
        notes.filter { $0.tags.contains("u-notes") }.count
    }
    
    var drawingNotesCount: Int {
        notes.filter { $0.hasDrawing }.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Quality Sensing Progress")
                    .font(.headline)
                
                ProgressView(value: qualityProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                
                Text("\(Int(qualityProgress * 100))% of notes have quality rankings")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                StatCard(title: "Notes", value: "\(notes.count)", color: .blue)
                StatCard(title: "Groups", value: "\(groups.count)", color: .green)
                StatCard(title: "Topics", value: "\(topics.count)", color: .orange)
            }
            
            if uNotesCount > 0 {
                HStack {
                    Image(systemName: "tag")
                        .foregroundColor(.orange)
                    Text("\(uNotesCount) U-Notes imported")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            if drawingNotesCount > 0 {
                HStack {
                    Image(systemName: "pencil.and.scribble")
                        .foregroundColor(.purple)
                    Text("\(drawingNotesCount) Drawing Notes")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            }
            
            VStack(spacing: 12) {
                Text("Recommended Actions")
                    .font(.headline)
                
                if qualityProgress < 0.1 {
                    ActionButton(title: "Start Quality Sensing", systemImage: "slider.horizontal.3", color: .blue)
                } else if groups.isEmpty {
                    ActionButton(title: "Form Groups", systemImage: "mountain.2", color: .green)
                } else {
                    ActionButton(title: "Explore Landscape", systemImage: "map", color: .purple)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(color)
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
//                .fill(Color(UIColor.systemGray6))
        )
    }
}

#Preview {
    ContentView()
}
