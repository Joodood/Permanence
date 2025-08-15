// DetailViews.swift - Missing views and extensions

import SwiftUI
import SwiftData
import Foundation

#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - Device Info Helper
struct UniversalDeviceInfo {
    static var deviceModel: String {
        #if os(iOS)
        return UIDevice.current.model
        #else
        return "Mac"
        #endif
    }
    
    static var systemVersion: String {
        #if os(iOS)
        return UIDevice.current.systemVersion
        #else
        return ProcessInfo.processInfo.operatingSystemVersionString
        #endif
    }
}

// MARK: - Note Detail View
struct NoteDetailView: View {
    let note: QualityNote
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(displayTitle(for: note))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(displayTitle(for: note).isEmpty ? .secondary : .primary)
            
            // Drawing Display
            if let drawingData = note.drawingData, note.hasDrawing {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "pencil.and.scribble")
                            .foregroundColor(.purple)
                        Text("Drawing Content:")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                    
                    DrawingDisplayView(drawingData: drawingData)
                        .frame(height: 300)
                        .background(Color.white)
                        .border(Color.gray.opacity(0.3), width: 1)
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 1, y: 1)
                }
            }
            
            // Text Content
            let textContent = note.content.components(separatedBy: "DRAWING_DATA:").first ?? note.content
            if !textContent.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    if note.hasDrawing {
                        Text("Text Content:")
                            .font(.headline)
                    }
                    
                    Text(textContent)
                        .font(.body)
                }
            }
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(note.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(tag == "u-notes" ? Color.orange.opacity(0.1) : Color.blue.opacity(0.1))
                                .foregroundColor(tag == "u-notes" ? .orange : .blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Note Detail")
        .universalNavigationBarTitleDisplayModeInline()
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
}

// MARK: - Group Detail View
struct GroupDetailView: View {
    let group: QualityGroup
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Group Detail")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Group \(group.id.prefix(8))")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("\(group.supportingCardIDs.count) supporting cards")
                .font(.body)
                .foregroundColor(.secondary)
            
            if group.isPermanent {
                Text("Status: Permanent")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            } else {
                Text("Status: Forming")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Group")
        .universalNavigationBarTitleDisplayModeInline()
    }
}

// MARK: - Topic Detail View
struct TopicDetailView: View {
    let topic: QualityTopic
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Topic Detail")
                .font(.title)
                .fontWeight(.bold)
            
            Text(topic.name)
                .font(.title2)
                .foregroundColor(.secondary)
            
            if !topic.topicDescription.isEmpty {
                Text(topic.topicDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Text("\(topic.groupIDs.count) groups in this topic")
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Topic")
        .universalNavigationBarTitleDisplayModeInline()
    }
}

// MARK: - Drawing Display View
struct DrawingDisplayView: View {
    let drawingData: Data
    @State private var drawings: [Drawing] = []
    @State private var hasLoaded = false
    @State private var dataHash: Int = 0
    
    var body: some View {
        Canvas { context, size in
            for drawing in drawings {
                if !drawing.points.isEmpty {
                    var path = Path()
                    path.move(to: drawing.points[0].location)
                    for point in drawing.points.dropFirst() {
                        path.addLine(to: point.location)
                    }
                    context.stroke(
                        path,
                        with: .color(drawing.color.color),
                        style: StrokeStyle(lineWidth: drawing.lineWidth, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }
        .background(Color.white)
        .onAppear {
            loadDrawingsIfNeeded()
        }
        .onChange(of: drawingData) { _, newData in
            let newHash = newData.hashValue
            if newHash != dataHash {
                dataHash = newHash
                loadDrawings()
            }
        }
        .id("drawing-\(dataHash)")
    }
    
    private func loadDrawingsIfNeeded() {
        let currentHash = drawingData.hashValue
        if !hasLoaded || currentHash != dataHash {
            dataHash = currentHash
            loadDrawings()
            hasLoaded = true
        }
    }
    
    private func loadDrawings() {
        do {
            let decodedDrawings = try JSONDecoder().decode([Drawing].self, from: drawingData)
            DispatchQueue.main.async {
                self.drawings = decodedDrawings
                print("✅ Loaded \(decodedDrawings.count) drawing strokes")
            }
        } catch {
            print("❌ Error loading drawings: \(error)")
            DispatchQueue.main.async {
                self.drawings = []
            }
        }
    }
}

// MARK: - Import Notes View
struct ImportNotesView: View {
    let modelContext: ModelContext
    
    @State private var isImporting = false
    @State private var importProgress: Double = 0.0
    @State private var importedCount = 0
    @State private var showingFilePicker = false
    @State private var importMethod: ImportMethod = .sample
    @State private var importStatus = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Import Your Notes")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Choose how to import your notes")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 20) {
                    Picker("Import Method", selection: $importMethod) {
                        Text("Sample Data").tag(ImportMethod.sample)
                        Text("Paste U-Notes").tag(ImportMethod.paste)
                        Text("Manual Entry").tag(ImportMethod.manual)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    if !isImporting {
                        switch importMethod {
                        case .sample:
                            Button("Load Sample Notes") {
                                loadSampleNotes()
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            
                        case .paste:
                            NavigationLink("Paste U-Notes") {
                                PasteNotesView(modelContext: modelContext)
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            
                        case .manual:
                            NavigationLink("Enter Notes Manually") {
                                ManualImportView(modelContext: modelContext)
                            }
                            .buttonStyle(.borderedProminent)
                            .font(.headline)
                            
                        default:
                            EmptyView()
                        }
                    }
                    
                    if isImporting {
                        VStack(spacing: 12) {
                            ProgressView(value: importProgress)
                                .progressViewStyle(LinearProgressViewStyle())
                            
                            Text(importStatus)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("Imported: \(importedCount) notes")
                                .font(.headline)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Notes")
            .universalNavigationBarTitleDisplayModeInline()
            .toolbar {
                ToolbarItem(placement: .universalLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                if importedCount > 0 && !isImporting {
                    ToolbarItem(placement: .universalTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.bold)
                    }
                }
            }
        }
    }
    
    private func loadSampleNotes() {
        isImporting = true
        importStatus = "Loading sample notes..."
        importProgress = 0.0
        
        let sampleData = [
            ("Music Theory Fundamentals", "Understanding chord progressions, scales, and harmonic relationships.", ["music", "theory"]),
            ("Guitar Chord Progressions", "Common progressions in different keys. Jazz, rock, and folk patterns.", ["music", "guitar"]),
            ("SwiftUI Architecture Patterns", "MVVM, Redux-like patterns, and state management in SwiftUI applications.", ["swift", "architecture"]),
            ("iOS Development Notes", "Core Data, CloudKit, and local storage patterns. Performance optimization.", ["iOS", "development"]),
            ("Quality and Zen Philosophy", "Robert Pirsig's insights on quality, zen, and the art of motorcycle maintenance.", ["philosophy", "quality"]),
            ("Code Review Best Practices", "Effective team code reviews, constructive feedback, and maintaining quality.", ["development", "teamwork"])
        ]
        
        for (index, (title, content, tags)) in sampleData.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                let note = QualityNote(title: title, content: content, tags: tags)
                modelContext.insert(note)
                
                importedCount += 1
                importProgress = Double(index + 1) / Double(sampleData.count)
                importStatus = "Importing: \(title)"
                
                if index == sampleData.count - 1 {
                    do {
                        try modelContext.save()
                        importStatus = "✓ Import complete! Ready for quality sensing."
                    } catch {
                        importStatus = "Error saving: \(error.localizedDescription)"
                    }
                    isImporting = false
                }
            }
        }
    }
}

enum ImportMethod: String, CaseIterable {
    case sample = "Sample"
    case paste = "Paste Notes"
    case manual = "Manual"
}

// MARK: - Paste Notes View
struct PasteNotesView: View {
    let modelContext: ModelContext
    
    @State private var notesText = ""
    @State private var importedCount = 0
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import U-Format Notes")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter your U-notes (one per line):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $notesText)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
                .frame(minHeight: 200)
            
            if notesText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example U-notes:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("U-Music Theory: Understanding chord progressions")
                    Text("U-SwiftUI: MVVM patterns in iOS development")
                    Text("U-Quality: Pirsig's insights on zen and quality")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Import U-Notes") {
                importUNotes()
            }
            .buttonStyle(.borderedProminent)
            .disabled(notesText.isEmpty)
            
            Button("Load Sample U-Notes") {
                addSampleUNotes()
            }
            .buttonStyle(.bordered)
            
            if importedCount > 0 {
                Text("✅ Imported \(importedCount) notes successfully!")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Import U-Notes")
        .universalNavigationBarTitleDisplayModeInline()
    }
    
    private func importUNotes() {
        let lines = notesText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.hasPrefix("U-") }
        
        for line in lines {
            let (title, content) = extractTitleAndContent(from: line)
            let tags = generateTags(from: line)
            
            let note = QualityNote(title: title, content: content, tags: tags)
            modelContext.insert(note)
            importedCount += 1
        }
        
        try? modelContext.save()
        notesText = ""
    }
    
    private func addSampleUNotes() {
        let sampleUNotes = [
            "U-Perfect! You've identified the core sensing mechanism - permanence intuition.",
            "U-Music Theory: Understanding chord progressions and harmonic relationships.",
            "U-SwiftUI Architecture: MVVM patterns and state management in iOS applications.",
            "U-Quality Philosophy: Robert Pirsig's insights on note organization and zen.",
            "U-Band Practice: Coordinate rehearsal times and song arrangement ideas.",
            "U-Code Review: Best practices for effective team collaboration and quality.",
            "U-Recording Studio Setup: Microphone placement and acoustic considerations.",
            "U-Live Performance: Stage presence and audience engagement techniques."
        ]
        
        for uNote in sampleUNotes {
            let (title, content) = extractTitleAndContent(from: uNote)
            let tags = generateTags(from: uNote)
            
            let note = QualityNote(title: title, content: content, tags: tags)
            modelContext.insert(note)
            importedCount += 1
        }
        
        try? modelContext.save()
    }
    
    private func extractTitleAndContent(from fullLine: String) -> (title: String, content: String) {
        let separators = [":", ".", "!", "?", "-"]
        
        for separator in separators {
            if let separatorRange = fullLine.range(of: separator) {
                let potentialTitle = String(fullLine[..<separatorRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                let potentialContent = String(fullLine[separatorRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
                
                if potentialTitle.count >= 3 && potentialTitle.count <= 50 && !potentialContent.isEmpty {
                    return (title: potentialTitle, content: potentialContent)
                }
            }
        }
        
        let words = fullLine.components(separatedBy: .whitespaces)
        if words.count > 3 {
            let titleWords = Array(words.prefix(3))
            let contentWords = Array(words.dropFirst(3))
            return (title: titleWords.joined(separator: " "), content: contentWords.joined(separator: " "))
        }
        
        return (title: fullLine, content: "")
    }
    
    private func generateTags(from fullLine: String) -> [String] {
        var tags: [String] = ["imported", "u-notes"]
        let lowercased = fullLine.lowercased()
        
        if lowercased.contains("music") || lowercased.contains("chord") || lowercased.contains("song") || lowercased.contains("band") {
            tags.append("music")
        }
        if lowercased.contains("swift") || lowercased.contains("code") || lowercased.contains("programming") || lowercased.contains("ios") {
            tags.append("programming")
        }
        if lowercased.contains("quality") || lowercased.contains("pirsig") || lowercased.contains("philosophy") || lowercased.contains("zen") {
            tags.append("philosophy")
        }
        if lowercased.contains("permanence") || lowercased.contains("sensing") || lowercased.contains("group") {
            tags.append("permanence-system")
        }
        if lowercased.contains("architecture") || lowercased.contains("design") || lowercased.contains("pattern") {
            tags.append("architecture")
        }
        
        return Array(Set(tags))
    }
}

// MARK: - Manual Import View
struct ManualImportView: View {
    let modelContext: ModelContext
    @State private var notesText = ""
    @State private var isImporting = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Manual Note Entry")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enter notes in format: Title | Content | Tags (optional)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $notesText)
                .font(.system(.body, design: .monospaced))
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            
            if notesText.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Example format:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Music Theory | Chord progressions and scales | music,theory")
                    Text("Swift Notes | MVVM architecture patterns | swift,ios")
                    Text("Philosophy | Quality and zen thoughts | philosophy")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button(isImporting ? "Importing..." : "Import Notes") {
                importManualNotes()
            }
            .buttonStyle(.borderedProminent)
            .disabled(notesText.isEmpty || isImporting)
        }
        .padding()
        .navigationTitle("Manual Import")
        .universalNavigationBarTitleDisplayModeInline()
    }
    
    private func importManualNotes() {
        isImporting = true
        
        let lines = notesText.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        for line in lines {
            let components = line.components(separatedBy: " | ")
            let title = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Untitled"
            let content = components.count > 1 ? components[1].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let tags = components.count > 2 ? components[2].components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } : ["manual"]
            
            let note = QualityNote(title: title, content: content, tags: tags)
            modelContext.insert(note)
        }
        
        try? modelContext.save()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            dismiss()
        }
    }
}

// MARK: - Debug View
struct DebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allNotes: [QualityNote]
    @Query private var allGroups: [QualityGroup]
    @Query private var allTopics: [QualityTopic]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("🔍 Debug: Data Investigation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Data counts
                VStack(alignment: .leading, spacing: 8) {
                    Text("Data Counts:")
                        .font(.headline)
                    Text("Notes: \(allNotes.count)")
                    Text("Groups: \(allGroups.count)")
                    Text("Topics: \(allTopics.count)")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                // Device Info section
                VStack(alignment: .leading, spacing: 8) {
                    Text("System Info:")
                        .font(.headline)
                    Text("Device: \(UniversalDeviceInfo.deviceModel)")
                    Text("OS: \(UniversalDeviceInfo.systemVersion)")
                    Text("Is Simulator: \(isSimulator ? "YES" : "NO")")
                    #if targetEnvironment(macCatalyst)
                    Text("Environment: Mac Catalyst")
                    #elseif os(macOS)
                    Text("Environment: Native macOS")
                    #else
                    Text("Environment: iOS")
                    #endif
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
                
                // Debug Actions
                VStack(spacing: 12) {
                    Text("Debug Actions:")
                        .font(.headline)
                    
                    Button("🔄 Force Refresh Data") {
                        forceRefreshData()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("📊 Log All Note Details") {
                        logAllNoteDetails()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("🗑️ Clear All Data") {
                        clearAllData()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                
                // Notes List
                if !allNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("All Notes:")
                            .font(.headline)
                        
                        ForEach(allNotes.prefix(10), id: \.title) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📝 \(note.title)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                Text("Content: \(note.content.prefix(50))...")
                                    .font(.caption2)
                                Text("Tags: \(note.tags.joined(separator: ", "))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("Created: \(note.createdDate.formatted())")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Divider()
                            }
                        }
                        
                        if allNotes.count > 10 {
                            Text("... and \(allNotes.count - 10) more notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .navigationTitle("Debug")
        .universalNavigationBarTitleDisplayModeInline()
    }
    
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    private func forceRefreshData() {
        do {
            try modelContext.save()
            print("✅ Force refresh completed")
        } catch {
            print("❌ Force refresh failed: \(error)")
        }
    }
    
    private func logAllNoteDetails() {
        print("📊 === ALL NOTES DEBUG ===")
        print("Total notes in context: \(allNotes.count)")
        
        for (index, note) in allNotes.enumerated() {
            print("Note \(index + 1):")
            print("  Title: \(note.title)")
            print("  Content: \(note.content)")
            print("  Tags: \(note.tags)")
            print("  Created: \(note.createdDate)")
            print("  Quality Score: \(note.qualityScore)")
            print("  ---")
        }
        print("📊 === END DEBUG ===")
    }
    
    private func clearAllData() {
        do {
            let noteDescriptor = FetchDescriptor<QualityNote>()
            let existingNotes = try modelContext.fetch(noteDescriptor)
            for note in existingNotes {
                modelContext.delete(note)
            }
            
            let groupDescriptor = FetchDescriptor<QualityGroup>()
            let existingGroups = try modelContext.fetch(groupDescriptor)
            for group in existingGroups {
                modelContext.delete(group)
            }
            
            let topicDescriptor = FetchDescriptor<QualityTopic>()
            let existingTopics = try modelContext.fetch(topicDescriptor)
            for topic in existingTopics {
                modelContext.delete(topic)
            }
            
            let comparisonDescriptor = FetchDescriptor<QualityComparison>()
            let existingComparisons = try modelContext.fetch(comparisonDescriptor)
            for comparison in existingComparisons {
                modelContext.delete(comparison)
            }
            
            let sessionDescriptor = FetchDescriptor<QualitySession>()
            let existingSessions = try modelContext.fetch(sessionDescriptor)
            for session in existingSessions {
                modelContext.delete(session)
            }
            
            try modelContext.save()
            print("✅ All data cleared")
        } catch {
            print("❌ Clear data failed: \(error)")
        }
    }
}
