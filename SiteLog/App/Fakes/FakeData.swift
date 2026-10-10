// UI skeleton sample data; each feature moves its part to Data/Fakes and deletes it here

import DesignSystem
import Foundation

struct FakeProject: Identifiable {
    let id = UUID()
    let name: String
    let client: String
    let area: String
    let summary: String
    let photoVariant: Int
}

struct FakeSession: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let isLive: Bool
    let hasPDF: Bool
}

struct FakeRoom: Identifiable {
    let id = UUID()
    let name: String
    let isChecked: Bool
    let photoCount: Int
    let criticalCount: Int
    let note: String?
}

struct FakeUnit: Identifiable {
    let id = UUID()
    let name: String
    let rooms: [FakeRoom]

    var checkedText: String {
        let checked = rooms.filter { $0.isChecked }.count
        return "\(checked) of \(rooms.count)"
    }
}

struct FakeIssue: Identifiable {
    let id = UUID()
    let number: Int
    let title: String
    let room: String
    let assignee: String
    let severity: DSStatusMarker.Kind
    let due: String
    let isLate: Bool
    let level: String
    let photoVariant: Int
    let isOpen: Bool
}

struct FakePlan: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
}

struct FakePin: Identifiable {
    let id = UUID()
    let number: Int
    let severity: DSStatusMarker.Kind
    // 0...1 of the plan size
    let positionX: Double
    let positionY: Double
}

struct FakeChecklist: Identifiable {
    let id = UUID()
    let title: String
    let itemCount: Int
}

struct FakeChecklistItem: Identifiable {
    let id = UUID()
    let number: Int
    let text: String
}

struct FakeUploadFile: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let status: String
    let kind: DSStatusMarker.Kind
    let photoVariant: Int
}

struct FakeDevice: Identifiable {
    let id = UUID()
    let name: String
    let detail: String?
    let isConnected: Bool
}

enum FakeData {
    static let inspector = "Hanh Nguyen"

    static let projects: [FakeProject] = [
        FakeProject(
            name: "Riverside Tower B",
            client: "Riverside Development JSC",
            area: "District 7",
            summary: "District 7 · 14 open issues",
            photoVariant: 0
        ),
        FakeProject(
            name: "Harbor View Villas",
            client: "Harbor Homes",
            area: "Thu Duc",
            summary: "Thu Duc · 3 open · last visit 12 Aug",
            photoVariant: 1
        ),
        FakeProject(
            name: "Northgate Warehouse",
            client: "Northgate Logistics",
            area: "Binh Duong",
            summary: "Binh Duong · nothing open",
            photoVariant: 2
        ),
    ]

    static let sessions: [FakeSession] = [
        FakeSession(title: "Today", summary: "In progress · 37 of 82 rooms", isLive: true, hasPDF: false),
        FakeSession(title: "Tue 12 Aug", summary: "112 photos · 14 issues · Hanh", isLive: false, hasPDF: true),
        FakeSession(title: "Mon 28 Jul", summary: "87 photos · 9 issues · Hanh", isLive: false, hasPDF: true),
        FakeSession(title: "Thu 10 Jul", summary: "64 photos · 5 issues · Minh", isLive: false, hasPDF: false),
    ]

    static let units: [FakeUnit] = [
        FakeUnit(name: "Unit 7A", rooms: [
            FakeRoom(name: "Living room", isChecked: true, photoCount: 4, criticalCount: 2, note: nil),
            FakeRoom(name: "Bedroom 1", isChecked: true, photoCount: 3, criticalCount: 0, note: nil),
            FakeRoom(
                name: "Bathroom",
                isChecked: false,
                photoCount: 0,
                criticalCount: 0,
                note: "1 issue from 12 Aug to re-check"
            ),
            FakeRoom(name: "Kitchen", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
        ]),
        FakeUnit(name: "Unit 7B", rooms: [
            FakeRoom(name: "Living room", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
            FakeRoom(name: "Bedroom 1", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
            FakeRoom(name: "Bedroom 2", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
            FakeRoom(name: "Bathroom", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
            FakeRoom(name: "Kitchen", isChecked: false, photoCount: 0, criticalCount: 0, note: nil),
        ]),
    ]

    static let issues: [FakeIssue] = [
        FakeIssue(
            number: 1, title: "Exposed wiring at socket", room: "7A Kitchen", assignee: "Phuc Electric",
            severity: .critical, due: "2 days late", isLate: true, level: "Level 7", photoVariant: 3, isOpen: true
        ),
        FakeIssue(
            number: 3, title: "Hairline crack by the skirting", room: "7A Living room", assignee: "Tuan’s masonry crew",
            severity: .major, due: "Fri", isLate: false, level: "Level 7", photoVariant: 0, isOpen: true
        ),
        FakeIssue(
            number: 4, title: "Door paint scratched", room: "7B Bedroom 1", assignee: "Painters",
            severity: .minor, due: "", isLate: false, level: "Level 7", photoVariant: 2, isOpen: true
        ),
        FakeIssue(
            number: 9, title: "Stain on bathroom ceiling", room: "8C Bathroom", assignee: "AquaSeal",
            severity: .major, due: "Wed 8 Oct", isLate: false, level: "Level 8", photoVariant: 1, isOpen: true
        ),
        FakeIssue(
            number: 2, title: "Loose socket cover", room: "7A Living room", assignee: "Phuc Electric",
            severity: .minor, due: "", isLate: false, level: "Level 7", photoVariant: 2, isOpen: false
        ),
    ]

    static let plans: [FakePlan] = [
        FakePlan(title: "Level 7 architectural", detail: "PDF · 7 pins"),
        FakePlan(title: "Level 8 architectural", detail: "PDF · 3 pins"),
        FakePlan(title: "Level 9 architectural", detail: "Photo of printed sheet · no pins"),
        FakePlan(title: "Level 7 electrical", detail: "PDF, sheet 2 of 6 · 1 pin"),
    ]

    static let pins: [FakePin] = [
        FakePin(number: 1, severity: .critical, positionX: 0.66, positionY: 0.47),
        FakePin(number: 2, severity: .major, positionX: 0.24, positionY: 0.2),
        FakePin(number: 3, severity: .major, positionX: 0.37, positionY: 0.27),
        FakePin(number: 4, severity: .minor, positionX: 0.75, positionY: 0.18),
        FakePin(number: 5, severity: .resolved, positionX: 0.17, positionY: 0.47),
        FakePin(number: 6, severity: .resolved, positionX: 0.78, positionY: 0.72),
    ]

    static let recentChecklists: [FakeChecklist] = [
        FakeChecklist(title: "Finishing handover", itemCount: 22),
        FakeChecklist(title: "Bathroom waterproofing", itemCount: 12),
    ]

    static let allChecklists: [FakeChecklist] = [
        FakeChecklist(title: "Sockets and switches", itemCount: 15),
        FakeChecklist(title: "Plumbing", itemCount: 18),
        FakeChecklist(title: "Doors and hardware", itemCount: 10),
        FakeChecklist(title: "Fire safety", itemCount: 20),
    ]

    static let checklistItems: [FakeChecklistItem] = [
        FakeChecklistItem(number: 12, text: "Wall surface flat, no cracks"),
        FakeChecklistItem(number: 13, text: "Paint even, no patches"),
        FakeChecklistItem(number: 14, text: "Floor grout even and sealed"),
        FakeChecklistItem(number: 15, text: "Door closes smoothly and locks"),
        FakeChecklistItem(number: 16, text: "Window opens and seals"),
        FakeChecklistItem(number: 17, text: "Sockets flush with the wall"),
    ]

    static let uploadFiles: [FakeUploadFile] = [
        FakeUploadFile(name: "IMG_0931.heic", detail: "7A Living · 3.1 MB", status: "Uploading", kind: .waiting, photoVariant: 0),
        FakeUploadFile(name: "VID_0012.mov", detail: "7A Kitchen · 412 MB", status: "Needs Wi-Fi", kind: .waiting, photoVariant: 3),
        FakeUploadFile(name: "VID_0013.mov", detail: "8C Bath · 288 MB", status: "Needs Wi-Fi", kind: .waiting, photoVariant: 1),
        FakeUploadFile(name: "IMG_0922.heic", detail: "7A Bedroom 1 · 2.8 MB", status: "Failed", kind: .critical, photoVariant: 2),
        FakeUploadFile(name: "IMG_0921.heic", detail: "7A Bedroom 1 · 2.9 MB", status: "Done", kind: .resolved, photoVariant: 0),
        FakeUploadFile(name: "IMG_0920.heic", detail: "7A Bedroom 1 · 3.0 MB", status: "Done", kind: .resolved, photoVariant: 2),
    ]

    static let myDevices: [FakeDevice] = [
        FakeDevice(name: "Leica DISTO D2", detail: "Connected · last reading 3.42 m", isConnected: true),
        FakeDevice(name: "Bosch GLM 50C", detail: "Not nearby", isConnected: false),
    ]

    static let nearbyDevices: [FakeDevice] = [
        FakeDevice(name: "Leica DISTO X3", detail: nil, isConnected: false),
        FakeDevice(name: "Stanley TLM99", detail: "Weak signal, move closer", isConnected: false),
    ]

    static let quickPhrases = ["Wall crack", "Ceiling stain", "Loose tile"]
}
