//
//  Settings.swift
//  clakr
//
//  Created by Kami on 7/4/2024.
//

import AppKit
import AVFoundation
import KeyboardShortcuts
import SwiftUI

// MARK: - SettingsTab

enum SettingsTab: String, CaseIterable, Identifiable {
    case general, hotkeys, sound, blacklist, about

    var id: Self { self }
    var localizedTitle: String { NSLocalizedString(rawValue.capitalized, comment: "") }

    var iconName: String {
        switch self {
        case .general: "gearshape"
        case .hotkeys: "keyboard"
        case .sound: "speaker.wave.2"
        case .blacklist: "text.and.command.macwindow"
        case .about: "info.circle"
        }
    }
}

// MARK: - SettingsView

struct SettingsView: View {
    @ObservedObject var autoClicker: AutoClicker
    @AppStorage("playSoundEffects") private var playSoundEffects = false
    @AppStorage("selectedSoundName") private var selectedSoundName = NSSound.systemSounds.first ?? ""
    @State private var selectedTab: SettingsTab = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(SettingsTab.allCases) { tab in
                tabView(for: tab)
                    .tabItem { Label(tab.localizedTitle, systemImage: tab.iconName) }
                    .tag(tab)
            }
        }
        .frame(width: 600, height: 450)
        .padding()
    }

    @ViewBuilder
    private func tabView(for tab: SettingsTab) -> some View {
        switch tab {
        case .general:
            GeneralSettings(autoClicker: autoClicker)
        case .hotkeys:
            HotkeysSettings()
        case .sound:
            SoundSettings(playSoundEffects: $playSoundEffects, selectedSoundName: $selectedSoundName, autoClicker: autoClicker)
        case .blacklist:
            BlacklistSettings()
        case .about:
            AboutSettings()
        }
    }
}

// MARK: - GeneralSettings

struct GeneralSettings: View {
    @ObservedObject var autoClicker: AutoClicker
    @AppStorage("isMenuBarModeEnabled") private var menuBarMode = false
    @AppStorage("hideDockIcon") private var hideDockIcon = false

    var body: some View {
        Form {
            Toggle("Menu Bar Mode", isOn: $menuBarMode)
                .onChange(of: menuBarMode, perform: handleMenuBarModeChange)

            if menuBarMode {
                Toggle("Hide Dock Icon", isOn: $hideDockIcon)
                    .onChange(of: hideDockIcon) { NSApp.setActivationPolicy($0 ? .accessory : .regular) }
            }
        }
    }

    private func handleMenuBarModeChange(isEnabled: Bool) {
        NSApp.setActivationPolicy(isEnabled && hideDockIcon ? .accessory : .regular)
        NotificationCenter.default.post(name: .toggleMenuBarMode, object: nil)
    }
}

// MARK: - HotkeysSettings

struct HotkeysSettings: View {
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 5) {
                Text("Hotkeys").font(.headline)
                HStack {
                    Text("Toggle Auto Clicker:")
                    Spacer()
                    KeyboardShortcuts.Recorder(for: .toggleAutoClicker)
                        .frame(width: 150)
                        .help("Set a keyboard shortcut to toggle the auto clicker")
                }
                .padding(.vertical, 5)
            }
        }
    }
}

// MARK: - SoundSettings

struct SoundSettings: View {
    @Binding var playSoundEffects: Bool
    @Binding var selectedSoundName: String
    @ObservedObject var autoClicker: AutoClicker
    @State private var importedSounds: [String] = []
    @State private var showAlert = false
    @State private var alertMessage = ""

    private var combinedSounds: [PickerSection] {
        [
            PickerSection(title: "System Sounds", sounds: NSSound.systemSounds),
            PickerSection(title: "Custom Sounds", sounds: NSSound.customSounds),
            PickerSection(title: "Imported Sounds", sounds: importedSounds)
        ]
    }

    private var allSounds: [String] { combinedSounds.flatMap(\.sounds) }

    var body: some View {
        Form {
            Toggle("Enable Sound Effects", isOn: $playSoundEffects)
                .padding([.top, .bottom], 2)

            if playSoundEffects {
                soundPickerSection
                navigationButtons
                importButton
                importedSoundsList
            } else {
                Text("Sound effects are disabled.")
                    .padding()
            }
        }
        .alert("Sound Duration Warning", isPresented: $showAlert, actions: {}, message: { Text(alertMessage) })
        .onAppear { importedSounds = SoundFileManager.shared.loadImportedSounds() }
    }

    private var soundPickerSection: some View {
        Picker("Select Sound:", selection: $selectedSoundName) {
            ForEach(combinedSounds, id: \.title) { section in
                Section(header: Text(section.title).font(.headline).foregroundColor(.gray)) {
                    ForEach(section.sounds, id: \.self) { Text($0).tag($0) }
                }
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: selectedSoundName) { autoClicker.playSound(name: $0) }
        .frame(width: 300)
    }

    private var navigationButtons: some View {
        HStack {
            Button(action: { navigateSound(backward: true) }) { Image(systemName: "backward.fill") }
            Button(action: { autoClicker.playSound(name: selectedSoundName) }) { Image(systemName: "play.circle") }
            Button(action: { navigateSound(backward: false) }) { Image(systemName: "forward.fill") }
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private var importButton: some View {
        Button("Import Sound", action: importSound)
            .padding(.vertical, 5)
    }

    private var importedSoundsList: some View {
        List {
            Section(header: Text("Imported Sounds")) {
                ForEach(importedSounds, id: \.self) { soundName in
                    HStack {
                        Text(soundName)
                        Spacer()
                        Button(action: { deleteImportedSound(named: soundName) }) {
                            Image(systemName: "trash").foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                .onDelete(perform: deleteImportedSound)
            }
        }
    }

    private func navigateSound(backward: Bool) {
        guard let currentIndex = allSounds.firstIndex(of: selectedSoundName) else { return }
        let nextIndex = backward ? (currentIndex - 1 + allSounds.count) % allSounds.count : (currentIndex + 1) % allSounds.count
        selectedSoundName = allSounds[nextIndex]
        autoClicker.playSound(name: selectedSoundName)
    }

    private func importSound() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.mp3]
        panel.begin { response in
            if response == .OK, let selectedFile = panel.url {
                validateAndAddSound(fileURL: selectedFile)
            }
        }
    }

    private func validateAndAddSound(fileURL: URL) {
        SoundFileManager.shared.importSound(fileURL: fileURL) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(savedFileName):
                    importedSounds.append(savedFileName)
                    selectedSoundName = savedFileName
                    checkSoundDuration(fileURL: fileURL)
                case let .failure(error):
                    print("Error importing sound: \(error)")
                }
            }
        }
    }

    private func checkSoundDuration(fileURL: URL) {
        let asset = AVURLAsset(url: fileURL, options: nil)
        let soundDuration = CMTimeGetSeconds(asset.duration)
        if soundDuration > 3 {
            alertMessage = "The selected sound exceeds the recommended maximum duration of 3 seconds. Please be mindful as long playtimes can overlap and may affect performance"
            showAlert = true
        }
    }

    private func deleteImportedSound(named soundName: String) {
        SoundFileManager.shared.deleteImportedSound(named: soundName) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    importedSounds.removeAll { $0 == soundName }
                case let .failure(error):
                    print("Error deleting sound: \(error)")
                }
            }
        }
    }

    private func deleteImportedSound(at offsets: IndexSet) {
        for index in offsets {
            deleteImportedSound(named: importedSounds[index])
        }
    }

    struct PickerSection: Identifiable {
        let title: String
        let sounds: [String]
        var id: String { title }
    }
}

// MARK: - BlacklistSettings

struct BlacklistSettings: View {
    @AppStorage("appBlacklistString") private var appBlacklistString: String = ""
    @State private var editableBlacklist: [BlacklistedApp] = []
    @State private var selectedApp: BlacklistedApp?

    var body: some View {
        Form {
            VStack(spacing: 20) {
                Text("ALPHA")
                    .font(.headline)
                    .padding(10)
                    .foregroundColor(Color(#colorLiteral(red: 0.949, green: 0.639, blue: 0.235, alpha: 1)))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(#colorLiteral(red: 0.949, green: 0.639, blue: 0.235, alpha: 1)), lineWidth: 1)
                    )

                blacklistSection
                controlButtons.padding(.top, 10)
            }
        }
        .onAppear { editableBlacklist = [BlacklistedApp].from(jsonString: appBlacklistString) ?? [] }
    }

    private var blacklistSection: some View {
        VStack {
            Text("Excluded Applications").font(.headline).padding(.bottom, 5)
            Text("Applications in the exclude list are ignored by Clakr.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 10)

            List(selection: $selectedApp) {
                Section(header: Text("Blacklist").font(.headline)) {
                    if editableBlacklist.isEmpty {
                        Text("No Excluded Applications. Press '+' to add an application.")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(editableBlacklist, id: \.self) { app in
                            HStack {
                                appIcon(for: app)
                                Text(app.name.deletingSuffix(".app"))
                                    .padding(.leading, 5)
                            }
                        }
                        .onDelete(perform: removeBlacklistApp)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
    }

    private func appIcon(for app: BlacklistedApp) -> some View {
        Group {
            if let appPath = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleID)?.path {
                Image(nsImage: NSWorkspace.shared.icon(forFile: appPath))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "questionmark.folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
        }
    }

    private var controlButtons: some View {
        HStack(spacing: 10) {
            Button(action: addAppToBlacklist) { Label("Add", systemImage: "plus") }
            Button(action: removeSelectedApp) { Label("Remove", systemImage: "minus") }
                .disabled(selectedApp == nil || editableBlacklist.isEmpty)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 10)
        .padding(.horizontal)
    }

    private func addAppToBlacklist() {
        let panel = NSOpenPanel()
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.application]

        if panel.runModal() == .OK,
           let selectedURL = panel.url,
           let bundleID = Bundle(url: selectedURL)?.bundleIdentifier {
            let appName = selectedURL.lastPathComponent.deletingSuffix(".app")
            let newApp = BlacklistedApp(name: appName, bundleID: bundleID)
            guard !editableBlacklist.contains(newApp) else { return }
            editableBlacklist.append(newApp)
            syncWithAppStorage()
        }
    }

    private func removeSelectedApp() {
        guard let selectedApp,
              let index = editableBlacklist.firstIndex(of: selectedApp) else { return }
        editableBlacklist.remove(at: index)
        syncWithAppStorage()
    }

    private func removeBlacklistApp(at offsets: IndexSet) {
        editableBlacklist.remove(atOffsets: offsets)
        syncWithAppStorage()
    }

    private func syncWithAppStorage() {
        appBlacklistString = editableBlacklist.jsonString() ?? ""
    }
}

// MARK: - AboutSettings

struct AboutSettings: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                appIconSection
                clakrInfoSection
                linksSection
                acknowledgementsSection
            }
            .padding()
        }
    }

    private var appIconSection: some View {
        HStack {
            Image(nsImage: NSImage(named: NSImage.applicationIconName)!)
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            VStack(alignment: .leading) {
                Text("Clakr")
                    .font(.system(size: 28, weight: .bold))
                Text("Version \(Bundle.main.appVersion ?? "Unknown") (\(Bundle.main.appBuild ?? "Unknown"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var clakrInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("© \(formattedYear()) Kami")
                .font(.subheadline)
            Text("Licensed under the GNU General Public License v3.0")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var linksSection: some View {
        HStack(spacing: 20) {
            ForEach(["Privacy Policy", "Visit Website", "Support Development"], id: \.self) { title in
                linkButton(title) {
                    openLink(for: title)
                }
            }
        }
    }

    private var acknowledgementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Acknowledgements")
            acknowledgementLink("KeyboardShortcuts library", url: "https://github.com/sindresorhus/KeyboardShortcuts")
            acknowledgementLink("App icon by Alex20041509", url: "https://www.reddit.com/user/Alex20041509/")
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .padding(.bottom, 4)
    }

    private func linkButton(_ title: String, action: @escaping () -> ()) -> some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.accentColor)
                .underline()
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func acknowledgementLink(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 8) {
                Image(systemName: "link")
                    .foregroundColor(.secondary)
                Text(title)
                    .foregroundColor(.primary)
            }
        }
    }

    private func formattedYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: Date())
    }

    private func openLink(for title: String) {
        let url: String
        switch title {
        case "Privacy Policy":
            url = "https://github.com/SenpaiHunters/Clakr/blob/main/Privacy%20Policy.md"
        case "Visit Website":
            url = "https://clakr-delta.vercel.app/"
        case "Support Development":
            url = "https://buymeacoffee.com/kami.dev"
        default:
            return
        }
        NSWorkspace.shared.open(URL(string: url)!)
    }
}

// MARK: - Helper Structures and Extensions

struct BlacklistedApp: Codable, Hashable {
    let name: String
    let bundleID: String
}

struct SoundFileManager {
    static let shared = SoundFileManager()
    private let fileManager = FileManager.default
    private let soundsDirectory: URL

    init() {
        let appSupportDirectory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.soundsDirectory = appSupportDirectory.appendingPathComponent("userImportedSounds")
        try? fileManager.createDirectory(at: soundsDirectory, withIntermediateDirectories: true, attributes: nil)
    }

    func importSound(fileURL: URL, completion: @escaping (Result<String, Error>) -> ()) {
        let fileName = fileURL.lastPathComponent
        let destinationURL = soundsDirectory.appendingPathComponent(fileName)
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: fileURL, to: destinationURL)
            completion(.success(fileName))
        } catch {
            completion(.failure(error))
        }
    }

    func loadImportedSounds() -> [String] {
        (try? fileManager.contentsOfDirectory(atPath: soundsDirectory.path).filter { $0.lowercased().hasSuffix(".mp3") }) ?? []
    }

    func deleteImportedSound(named soundName: String, completion: @escaping (Result<(), Error>) -> ()) {
        let fileURL = soundsDirectory.appendingPathComponent(soundName)
        do {
            try fileManager.removeItem(at: fileURL)
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }
}

extension Bundle {
    var appName: String { infoDictionary?["CFBundleName"] as? String ?? "" }
    var displayName: String { infoDictionary?["CFBundleDisplayName"] as? String ?? appName }
    var appVersion: String? { infoDictionary?["CFBundleShortVersionString"] as? String }
    var appBuild: String? { infoDictionary?["CFBundleVersion"] as? String }
    var bundleID: String { bundleIdentifier ?? "" }
    var copyright: String { infoDictionary?["NSHumanReadableCopyright"] as? String ?? "" }
}

extension [BlacklistedApp] {
    static func from(jsonString: String) -> [BlacklistedApp]? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode([BlacklistedApp].self, from: data)
    }

    func jsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

#Preview { SettingsView(autoClicker: AutoClicker()) }
