//
//  Settings.swift
//  clakr
//
//  Created by Kami on 7/4/2024.
//

import Foundation
import KeyboardShortcuts
import SwiftUI

struct SettingsView: View {
  @ObservedObject var autoClicker: AutoClicker
  @Environment(\.presentationMode) var presentationMode
  @AppStorage("playSoundEffects") private var playSoundEffects = false
  @AppStorage("selectedSoundName") private var selectedSoundName = NSSound.systemSounds.first ?? ""

  @State private var selectedTab: SettingsTab? = .general

  private enum SettingsTab: String, CaseIterable, Identifiable {
    case general = "General"
    case hotkeys = "Hotkeys"
    case sound = "Sound"
    case about = "About"

    var id: String { self.rawValue }
  }

  private let frameSize = CGSize(width: 630, height: 500)

  var body: some View {
    NavigationView {
      List {
        ForEach(SettingsTab.allCases, id: \.self) { tab in
          NavigationLink(
            destination: viewFor(tab: tab),
            tag: tab,
            selection: $selectedTab
          ) {
            Text(tab.rawValue)
          }
        }
      }
      .listStyle(SidebarListStyle())
      .frame(minWidth: 150, idealWidth: 200, maxWidth: 450)
      .toolbar {
        ToolbarItem(placement: .navigation) {
          Button(action: {
            presentationMode.wrappedValue.dismiss()
          }) {
            Image(systemName: "xmark.circle.fill")
          }
        }
      }

      viewFor(tab: selectedTab ?? .general)
        .toolbar {
          ToolbarItem(placement: .navigation) {
            Button(action: {
              presentationMode.wrappedValue.dismiss()
            }) {
              Image(systemName: "xmark")
            }
          }
        }
    }
    .frame(width: frameSize.width, height: frameSize.height)
  }

  @ViewBuilder
  private func viewFor(tab: SettingsTab) -> some View {
    switch tab {
    case .general:
      GeneralSettingsView(autoClicker: autoClicker)
    case .hotkeys:
      HotkeysSettingsView()
    case .sound:
      SoundSettingsView(
        playSoundEffects: $playSoundEffects, selectedSoundName: $selectedSoundName,
        autoClicker: autoClicker)
    case .about:
      AboutView()
    }
  }
}

struct SectionHeaderView: View {
  let title: String
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    ZStack {
      Text(title)
        .font(.largeTitle)
        .padding(.top)

      HStack {
        Spacer()
        Button(action: {
          presentationMode.wrappedValue.dismiss()
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
            .padding(8)
            .background(Color.white.opacity(0.2))
            .clipShape(Circle())
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.trailing, 10)
      }
    }
  }
}

struct GeneralSettingsView: View {
  @ObservedObject var autoClicker: AutoClicker
  @Environment(\.presentationMode) var presentationMode

  @AppStorage("isMenuBarModeEnabled") private var menuBarMode = false
  @AppStorage("hideDockIcon") private var hideDockIcon = false

  var body: some View {
    VStack {
      SectionHeaderView(title: "General")

      Divider()

      Form {
        Toggle("Menu Bar Mode", isOn: $menuBarMode)
          .onChange(of: menuBarMode) { isEnabled in
            handleMenuBarModeChange(isEnabled: isEnabled, hideDock: hideDockIcon)
          }
          .padding(.vertical, 5)
          .help("Enable or disable menu bar mode")

        if menuBarMode {
          Toggle("Hide Dock Icon", isOn: $hideDockIcon)
            .onChange(of: hideDockIcon) { shouldHide in
              NSApp.setActivationPolicy(shouldHide ? .accessory : .regular)
            }
            .padding(.vertical, 5)
            .help("Show or hide the dock icon")
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()

      Spacer()
    }
    .padding()
  }

  private func handleMenuBarModeChange(isEnabled: Bool, hideDock: Bool) {
    NSApp.setActivationPolicy(isEnabled ? (hideDock ? .accessory : .regular) : .regular)
    NotificationCenter.default.post(name: .toggleMenuBarMode, object: nil)
  }
}

struct HotkeysSettingsView: View {
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
      SectionHeaderView(title: "Hotkeys")

      Divider()

      VStack(alignment: .leading, spacing: 5) {
        HStack {
          Text("Toggle Auto Clicker:")
            .fontWeight(.semibold)
          Spacer()
          KeyboardShortcuts.Recorder(for: .toggleAutoClicker)
            .frame(width: 150)
            .help("Set a keyboard shortcut to toggle the auto clicker")
        }
        .padding(.vertical, 5)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()

      Spacer()
    }
    .padding()
  }
}

struct SoundSettingsView: View {
  @Binding var playSoundEffects: Bool
  @Binding var selectedSoundName: String
  @ObservedObject var autoClicker: AutoClicker
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack {
      SectionHeaderView(title: "Sounds")

      Divider()

      VStack(alignment: .leading, spacing: 5) {
        Toggle(isOn: $playSoundEffects) {
          Text("Play Sound Effects")
            .fontWeight(.semibold)
        }
        .padding(.vertical, 5)
        .help("Enable or disable sound effects")

        if playSoundEffects {
          Picker("Select Sound:", selection: $selectedSoundName) {
            ForEach(NSSound.systemSounds, id: \.self) { soundName in
              Text(soundName).tag(soundName)
            }
          }
          .onChange(of: selectedSoundName) { newValue in
            autoClicker.playSound(name: newValue)
          }
          .pickerStyle(MenuPickerStyle())
          .help("Choose a sound for the auto clicker")
          .padding(.vertical, 5)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding()

      Spacer()
    }
    .padding()
  }
}

struct AboutView: View {
  @Environment(\.presentationMode) var presentationMode

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      SectionHeaderView(title: "About Clakr")

      Divider()

      aboutClakrSection

      Divider()

      acknowledgementsSection

      Divider()

      copyrightAndVersionSection
    }
    .padding()
  }

  private var acknowledgementsSection: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("Acknowledgements")
        .font(.title2)
        .padding(.bottom, 5)

      HStack {
        Text("Sindre Sorhus")
          .bold()
        Spacer()
        Link(
          "KeyboardShortcuts library",
          destination: URL(string: "https://github.com/sindresorhus/KeyboardShortcuts")!)
      }
      .padding(.bottom, 3)

      HStack {
        Text("KawaiiFumiko002")
          .bold()
        Spacer()
        Text("App icon creator")
      }
    }
    .padding(.vertical)
  }

  private var aboutClakrSection: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text("More about Clakr")
        .font(.title2)
        .padding(.bottom, 2)

      Text("Clakr is a simple, lightweight auto-clicker designed for macOS. It can be used as a menu bar app, or a standalone app, with optional sound effects when the clicker starts.")
      .padding(.bottom, 1)

      Text("Clakr is entirely open-sourced, ensuring user and developer transparency for an up-to-date, free, and fast auto-clicker.")
      .padding(.bottom, 1)

      Text("Please be aware that by using Clakr, you accept full responsibility for any consequences, such as bans or penalties from software or services that prohibit the use of auto-clickers.")
      .padding(.bottom, 1)

      Link("Support Clakr's development", destination: URL(string: "https://www.buymeacoffee.com/kamiamvs")!)
      .padding(.bottom, 1)
    }
    .padding(.vertical)
  }

  private var copyrightAndVersionSection: some View {
    HStack {
      Text("© \(currentYear) Kami. All rights reserved.")
        .font(.footnote)
      Link(
        "MIT License",
        destination: URL(string: "https://github.com/SenpaiHunters/Clakr/blob/main/LICENSE.md")!
      )
      .font(.footnote)
      Spacer()
      Text("\(appVersionAndBuild)")
        .font(.footnote)
      Button(action: copyVersionToClipboard) {
        Image(systemName: "doc.on.doc")
          .foregroundColor(.accentColor)
      }
      .buttonStyle(BorderlessButtonStyle())
      .help("Copy version to clipboard")
    }
    .padding(.vertical)
  }

  private func copyVersionToClipboard() {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(appVersionAndBuild, forType: .string)
  }

  private var currentYear: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: Date())
  }

  private var appVersionAndBuild: String {
    guard
      let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        as? String,
      let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
    else {
      return "Unknown"
    }
    return "Version: \(versionNumber) (\(buildNumber))"
  }
}
