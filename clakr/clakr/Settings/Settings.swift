//
//  Settings.swift
//  clakr
//
//  Created by Kami on 7/4/2024.
//

import AVFoundation
import AppKit
import Foundation
import KeyboardShortcuts
import Sparkle
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
  @ObservedObject var autoClicker: AutoClicker
  @AppStorage("playSoundEffects") private var playSoundEffects = false
  @AppStorage("selectedSoundName") private var selectedSoundName = NSSound.systemSounds.first ?? ""
  @AppStorage("reducedTransparency") private var reducedTransparency = false

  @State private var selectedTab: SettingsTab = .general

  private enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case hotkeys = "Hotkeys"
    case sound = "Sound"
    case blacklist = "Excluded Apps"
    case about = "About"

    var id: Self { self }

    var localizedTitle: String {
      NSLocalizedString(self.rawValue, comment: "")
    }

    var iconName: String {
      switch self {
      case .general: return "gearshape"
      case .hotkeys: return "keyboard"
      case .sound: return "speaker.wave.2"
      case .blacklist: return "text.and.command.macwindow"
      case .about: return "info.circle"
      }
    }
  }

  var body: some View {
    VStack {
      // Top bar with tabs
      HStack {
        ForEach(SettingsTab.allCases, id: \.self) { tab in
          Button(action: {
            self.selectedTab = tab
          }) {
            VStack {  // Layout icons above text
              Image(systemName: tab.iconName)
                .imageScale(.large)
                .padding(2)
              Text(tab.localizedTitle)
                .fontWeight(self.selectedTab == tab ? .medium : .regular)
                .font(.system(size: 12))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .foregroundColor(self.selectedTab == tab ? Color.white : Color.primary)
            .background(self.selectedTab == tab ? Color.accentColor : Color.clear)
            .cornerRadius(8)
          }
          .buttonStyle(BorderlessButtonStyle())
          .shadow(radius: self.selectedTab == tab ? 1 : 0)
        }
      }
      .padding(.top, 10)
      .padding(.horizontal)
      .fixedSize(horizontal: false, vertical: true)

      Divider()

      // Content below the top bar
      Group {
        switch selectedTab {
        case .general:
          GeneralSettingsView(
            autoClicker: autoClicker, updaterController: MenuManager.shared.updaterController)
        case .hotkeys:
          HotkeysSettingsView()
        case .sound:
          SoundSettingsView(
            playSoundEffects: $playSoundEffects, selectedSoundName: $selectedSoundName,
            autoClicker: autoClicker)
        case .blacklist:
          blacklistSettingsView()
        case .about:
          AboutMenuBarView()
        }
      }
      .padding()
      .transition(.opacity.combined(with: .slide))
      .animation(.easeInOut(duration: 0.2), value: selectedTab)
      .frame(maxHeight: .infinity)
    }
    .frame(
      minWidth: 600, idealWidth: 600, maxWidth: .infinity, minHeight: 500, idealHeight: 650,
      maxHeight: .infinity)
  }
}

// MARK: Common styles
private struct SectionHeader: View {
  let text: String

  var body: some View {
    Text(text)
      .font(.title2)
      .fontWeight(.semibold)
      .padding(.bottom, 5)
  }
}

private struct StyledToggle: View {
  let label: String
  let isOn: Binding<Bool>
  let helpText: String

  var body: some View {
    Toggle(label, isOn: isOn)
      .padding(.vertical, 5)
      .help(helpText)
  }
}

private struct SectionSpacer: View {
  var body: some View {
    Spacer()
      .frame(height: 20)
  }
}
// MARK: STOP

// MARK: General settings
struct GeneralSettingsView: View {
  @ObservedObject var autoClicker: AutoClicker
  @AppStorage("isMenuBarModeEnabled") private var menuBarMode = false
  @AppStorage("hideDockIcon") private var hideDockIcon = false
  @AppStorage("reducedTransparency") private var reducedTransparency = false
  @AppStorage("autoCheckForUpdates") private var autoCheckForUpdates = true

  var updaterController: SPUStandardUpdaterController?

  var body: some View {
    Form {
      Section {
        Toggle("Menu Bar Mode", isOn: $menuBarMode)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .padding(.vertical, 2)
          .onChange(of: menuBarMode) { isEnabled in
            handleMenuBarModeChange(isEnabled: isEnabled)
          }

        if menuBarMode {
          Toggle("Hide Dock Icon", isOn: $hideDockIcon)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            .padding(.vertical, 2)
            .onChange(of: hideDockIcon) { shouldHide in
              NSApp.setActivationPolicy(shouldHide ? .accessory : .regular)
            }
        }
      }.padding(.vertical, 5)

      Section {
        Toggle("Reduced Transparency", isOn: $reducedTransparency)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .padding(.vertical, 2)

          .padding(.vertical, 2)

        Toggle("Automatically Check for Updates", isOn: $autoCheckForUpdates)
          .toggleStyle(SwitchToggleStyle(tint: .accentColor))
          .padding(.vertical, 2)
      }.padding(.vertical, 5)

      Section {
        Button("Check for Updates Now...") {
          updaterController?.checkForUpdates(nil)
        }
        .disabled(!autoCheckForUpdates)
      }.padding(.vertical, 5)

      updateStatusText
        .padding(.top, 5)
    }
    .frame(width: 400)
    .padding()
  }

  private var updateStatusText: some View {
    Group {
      if autoCheckForUpdates {
        Text("Your app is set to automatically check for updates.")
          .font(.caption)
          .foregroundColor(.secondary)
      } else {
        Text("Automatic updates are disabled. You can check for updates manually.")
          .font(.caption)
          .foregroundColor(.secondary)
      }
    }
  }

  private func handleMenuBarModeChange(isEnabled: Bool) {
    NSApp.setActivationPolicy(isEnabled && hideDockIcon ? .accessory : .regular)
    NotificationCenter.default.post(name: .toggleMenuBarMode, object: nil)
  }
}

// MARK: App Blacklist
struct BlacklistedApp: Codable, Hashable {
  let name: String
  let bundleID: String
}

// NOTE: Early Alpha Stage
// This feature is currently in its early alpha stage. 
// I am exploring its effectiveness and scalability beyond individual use cases.

struct blacklistSettingsView: View {
  @AppStorage("appBlacklistString") private var appBlacklistString: String = ""
  @State private var editableBlacklist: [BlacklistedApp] = []
  @State private var selectedApp: BlacklistedApp?

  var body: some View {
    VStack(spacing: 20) {
      Text("ALPHA")
        .font(.headline)
        .padding(10)
        .foregroundColor(Color(#colorLiteral(red: 0.949, green: 0.639, blue: 0.235, alpha: 1)))
        .cornerRadius(10)
        .overlay(
          RoundedRectangle(cornerRadius: 10)
            .stroke(
              Color(#colorLiteral(red: 0.949, green: 0.639, blue: 0.235, alpha: 1)), lineWidth: 1)
        )

      blacklistSection

      controlButtons
        .padding(.top, 10)
    }
    .padding()
    .onAppear {
      editableBlacklist = Array.from(jsonString: appBlacklistString) ?? []
    }
  }

  private var blacklistSection: some View {
    VStack {
      Text("Excluded Applications")
        .font(.headline)
        .padding(.bottom, 5)
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
                if let appPath = NSWorkspace.shared.urlForApplication(
                  withBundleIdentifier: app.bundleID)?.path
                {
                  Image(nsImage: NSWorkspace.shared.icon(forFile: appPath))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                } else {
                  // Fallback icon or handling if the app path is not found
                  Image(systemName: "questionmark.folder")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                }
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

  private var controlButtons: some View {
    HStack(spacing: 10) {
      Button(action: addAppToBlacklist) {
        Label("Add", systemImage: "plus")
      }
      .buttonStyle(PlainButtonStyle())
      .padding(.vertical, 10)
      .padding(.horizontal)

      Button(action: removeSelectedApp) {
        Label("Remove", systemImage: "minus")
      }
      .buttonStyle(PlainButtonStyle())
      .padding(.vertical, 10)
      .padding(.horizontal)
      // Disable the "Remove" button if no app is selected or if the blacklist is empty
      .disabled(selectedApp == nil || editableBlacklist.isEmpty)
    }
  }

  private func addAppToBlacklist() {
    let panel = NSOpenPanel()
    panel.directoryURL = URL(fileURLWithPath: "/Applications")
    panel.allowsMultipleSelection = false
    panel.canChooseFiles = true
    panel.allowedContentTypes = [.application]

    if panel.runModal() == .OK, let selectedURL = panel.url,
      let bundleID = Bundle(url: selectedURL)?.bundleIdentifier
    {
      let appNameWithExtension = selectedURL.lastPathComponent
      let appName = appNameWithExtension.deletingSuffix(".app")
      let newApp = BlacklistedApp(name: appName, bundleID: bundleID)
      guard !editableBlacklist.contains(newApp) else { return }
      editableBlacklist.append(newApp)
      syncWithAppStorage()
    }
  }

  private func removeSelectedApp() {
    guard let selectedApp = selectedApp, let index = editableBlacklist.firstIndex(of: selectedApp)
    else { return }
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

// MARK: App Hotkeys

/// To Add:
/// Start/Stop Recording (for Macros)
/// Actual macro support apart from an
/// auto-clicker. Although BTT, etc., have this,
/// so hmm, need to make sure if I want
/// to actually implement this.
struct HotkeysSettingsView: View {

  var body: some View {
    VStack {
      SectionHeader(text: NSLocalizedString("Hotkeys", comment: ""))

      VStack(alignment: .leading, spacing: 5) {
        HStack {
          Text("Toggle Auto Clicker:")
          Spacer()
          KeyboardShortcuts.Recorder(for: .toggleAutoClicker)
            .frame(width: 150)
            .help("Set a keyboard shortcut to toggle the auto clicker")
        }
        .padding(.vertical, 5)
      }
      SectionSpacer()
    }
    .padding()
  }
}

// MARK: Clicker sounds
struct SoundSettingsView: View {
  @Binding var playSoundEffects: Bool
  @Binding var selectedSoundName: String
  @ObservedObject var autoClicker: AutoClicker
  @State private var importedSounds: [String] = []
  @State private var showAlert = false
  @State private var alertMessage = ""

  private var combinedSounds: [PickerSection] {
    [
      PickerSection(
        title: NSLocalizedString("System Sounds", comment: "Title for system sounds section"),
        sounds: NSSound.systemSounds),
      PickerSection(
        title: NSLocalizedString("Custom Sounds", comment: "Title for custom sounds section"),
        sounds: NSSound.customSounds),
      PickerSection(
        title: NSLocalizedString("Imported Sounds", comment: "Title for imported sounds section"),
        sounds: importedSounds),
    ]
  }

  private var allSounds: [String] {
    combinedSounds.flatMap { $0.sounds }
  }

  var body: some View {
    VStack {
      Toggle("Enable Sound Effects", isOn: $playSoundEffects)
        .padding([.top, .bottom], 2)
        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        .onChange(of: playSoundEffects) { newValue in
        }

      Divider()

      if playSoundEffects {
        VStack(alignment: .leading) {
          soundPickerSection
          navigationButtons
          importButton
          Spacer()
          importedSoundsList
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.2), value: playSoundEffects)
      } else {
        Text("Sound effects are disabled.")
          .padding()
      }
    }
    .alert(isPresented: $showAlert) {
      Alert(
        title: Text("Sound Duration Warning"), message: Text(alertMessage),
        dismissButton: .default(Text("OK")))
    }
    .padding()
    .onAppear { self.importedSounds = SoundFileManager.shared.loadImportedSounds() }
  }

  private var soundPickerSection: some View {
    return Picker(NSLocalizedString("Select Sound:", comment: ""), selection: $selectedSoundName) {
      ForEach(combinedSounds, id: \.title) { section in
        Section(header: Text(section.title).font(.headline).foregroundColor(.gray)) {
          ForEach(section.sounds, id: \.self) { soundName in
            Text(soundName).tag(soundName)
          }
        }
      }
    }
    .pickerStyle(MenuPickerStyle())
    .onChange(of: selectedSoundName) { newValue in
      autoClicker.playSound(name: newValue)
    }
    .frame(width: 300)
  }

  private var navigationButtons: some View {
    HStack {
      Button(action: { navigateSound(backward: true) }) {
        Image(systemName: "backward.fill")
      }
      Button(action: { autoClicker.playSound(name: selectedSoundName) }) {
        Image(systemName: "play.circle")
      }
      Button(action: { navigateSound(backward: false) }) {
        Image(systemName: "forward.fill")
      }
    }
    .buttonStyle(BorderlessButtonStyle())
  }

  private var importButton: some View {
    Button("Import Sound") { importSound() }
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
        .onDelete(perform: deleteImportedSound(at:))
      }
    }
  }

  private func navigateSound(backward: Bool) {
    guard let currentIndex = allSounds.firstIndex(of: selectedSoundName) else { return }
    let nextIndex = backward ? max(currentIndex - 1, 0) : min(currentIndex + 1, allSounds.count - 1)
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
        self.validateAndAddSound(fileURL: selectedFile)
      }
    }
  }

  private func validateAndAddSound(fileURL: URL) {
    SoundFileManager.shared.importSound(fileURL: fileURL) { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let savedFileName):
          self.importedSounds.append(savedFileName)
          self.selectedSoundName = savedFileName
          self.checkSoundDuration(fileURL: fileURL)
        case .failure(let error):
          print("Error importing sound: \(error)")
        }
      }
    }
  }

  private func checkSoundDuration(fileURL: URL) {
    let asset = AVURLAsset(url: fileURL, options: nil)
    let soundDuration = CMTimeGetSeconds(asset.duration)
    if soundDuration > 3 {
      self.alertMessage = NSLocalizedString(
        "The selected sound exceeds the recommended maximum duration of 3 seconds. Please be mindful as long playtimes can overlap and may affect performance",
        comment: "")
      self.showAlert = true
    }
  }

  private func deleteImportedSound(named soundName: String) {
    SoundFileManager.shared.deleteImportedSound(named: soundName) { result in
      DispatchQueue.main.async {
        switch result {
        case .success():
          self.importedSounds.removeAll { $0 == soundName }
        case .failure(let error):
          print("Error deleting sound: \(error)")
        }
      }
    }
  }

  private func deleteImportedSound(at offsets: IndexSet) {
    offsets.forEach { index in
      let soundName = importedSounds[index]
      deleteImportedSound(named: soundName)
    }
  }

  struct PickerSection: Identifiable {
    let title: String
    let sounds: [String]
    var id: String { title }
  }
}

struct SoundFileManager {
  static let shared = SoundFileManager()
  private let fileManager = FileManager.default
  private let soundsDirectory: URL

  init() {
    let appSupportDirectory = fileManager.urls(
      for: .applicationSupportDirectory, in: .userDomainMask
    ).first!
    soundsDirectory = appSupportDirectory.appendingPathComponent("userImportedSounds")
    createSoundsDirectoryIfNeeded()
  }

  private func createSoundsDirectoryIfNeeded() {
    if !fileManager.fileExists(atPath: soundsDirectory.path) {
      try? fileManager.createDirectory(at: soundsDirectory, withIntermediateDirectories: true)
    }
  }

  func importSound(fileURL: URL, completion: @escaping (Result<String, Error>) -> Void) {
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
    (try? fileManager.contentsOfDirectory(atPath: soundsDirectory.path).filter {
      $0.lowercased().hasSuffix(".mp3")
    }) ?? []
  }

  func deleteImportedSound(
    named soundName: String, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let fileURL = soundsDirectory.appendingPathComponent(soundName)
    do {
      try fileManager.removeItem(at: fileURL)
      completion(.success(()))
    } catch {
      completion(.failure(error))
    }
  }
}
