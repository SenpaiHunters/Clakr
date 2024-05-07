//
//  ContentView.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import SwiftUI

class LanguageSettings: ObservableObject {
  @Published var currentLanguage: String

  init() {
    self.currentLanguage = Locale.current.languageCode ?? "en"
  }
}

struct ContentView: View {
  @StateObject private var autoClicker = AutoClicker()
  @AppStorage("clicksPerSecond") private var clicksPerSecond: Double = 1
  @AppStorage("startAfterSeconds") private var startAfterSeconds: TimeInterval = 0
  @AppStorage("stopAfterSeconds") private var stopAfterSeconds: TimeInterval = 0
  @AppStorage("stationaryForSeconds") private var stationaryForSeconds: TimeInterval = 0
  @AppStorage("reducedTransparency") private var reducedTransparency: Bool = false
  @StateObject var viewModel = ViewModel()
  @State private var showingSettings = false
  @StateObject private var languageSettings = LanguageSettings()

  var body: some View {
    ZStack {
      VisualEffectView(
        material: reducedTransparency ? .windowBackground : .hudWindow, blendingMode: .behindWindow
      )
      .overlay(Color.black.opacity(0.2))
      .edgesIgnoringSafeArea(.all)
      content
    }
    .toolbar { settingsButton }
    .onReceive(NotificationCenter.default.publisher(for: .showSettings)) { _ in
      if !showingSettings {
        showingSettings = true
      }
    }
  }

  private var content: some View {
    VStack(spacing: 20) {
      headerView
      Divider()
      settingsGroup
      Divider()
      startStopButton
    }
    .padding(.horizontal, 20)
  }

  private var settingsButton: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      Button(action: { NSApp.delegate?.perform(#selector(AppDelegate.toggleSettings)) }) {
        Label("Settings", systemImage: "gear")
          .font(.headline)
          .foregroundColor(.primary)
          .padding(.vertical, 2)
          .padding(.horizontal, 20)
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.accentColor, lineWidth: 1)
          )
      }
      .buttonStyle(PlainButtonStyle())
      .accessibilityLabel("Settings")
    }
  }

  private var headerView: some View {
    Text("Clakr")
      .font(.system(size: 36, weight: .bold))
      .foregroundColor(.white)
  }

  private var settingsGroup: some View {
    Group {
      SettingTextField(
        title: "Clicks per second:".localized(using: languageSettings.currentLanguage),
        value: $clicksPerSecond)
      SettingStepper(
        title: "Start after (seconds):".localized(using: languageSettings.currentLanguage),
        value: $startAfterSeconds)
      SettingStepper(
        title: "Stop after (seconds):".localized(using: languageSettings.currentLanguage),
        value: $stopAfterSeconds)
      SettingStepper(
        title: "Stationary for (seconds):".localized(using: languageSettings.currentLanguage),
        value: $stationaryForSeconds)
    }
  }

  private var startStopButton: some View {
    Button(action: toggleClicking) {
      Label {
        Text(autoClicker.isClicking ? "Stop" : "Start")
          .fontWeight(.semibold)
          .font(.title3)
      } icon: {
        Image(systemName: autoClicker.isClicking ? "stop.fill" : "play.fill")
          .font(.title3)
      }
    }
    .buttonStyle(PrimaryButtonStyle(isClicking: autoClicker.isClicking))
    .configureAccessibility(isClicking: autoClicker.isClicking)
  }

  private func toggleClicking() {
    withAnimation {
      autoClicker.toggleClicking()
    }
  }
}

struct PrimaryButtonStyle: ButtonStyle {
  var isClicking: Bool

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 6)
      .padding(.horizontal)
      .foregroundColor(isClicking ? .white : .black)
      .background(
        Capsule()
          .fill(isClicking ? Color.red : Color.white)
      )
      .overlay(
        Capsule()
          .stroke(Color.gray.opacity(0.5), lineWidth: 1)
      )
      .scaleEffect(configuration.isPressed ? 0.96 : 1)
      .animation(
        .easeInOut(duration: 0.2), value: configuration.isPressed || isClicking
      )
  }
}

struct SettingTextField: View {
  var title: String
  @Binding var value: Double

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.primary)
        .font(.system(size: 14))
      Spacer()
      TextField("", value: $value, formatter: NumberFormatter())
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .frame(width: 100)
        .multilineTextAlignment(.trailing)
        .padding(.leading, 10)
        .font(.system(size: 14))
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 20)
  }
}

struct SettingStepper: View {
  var title: String
  @Binding var value: TimeInterval

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.primary)
        .font(.system(size: 14))
      Spacer()
      HStack(spacing: 5) {
        Text("\(Int(value))s")
          .foregroundColor(.primary)
          .frame(width: 50, alignment: .trailing)
          .font(.system(size: 14))
        Stepper("", value: $value, in: 0...Double.infinity, step: 1)
          .labelsHidden()
      }
      .fixedSize()
    }
    .padding(.vertical, 6)
    .padding(.horizontal, 20)
  }
}

struct VisualEffectView: NSViewRepresentable {
  var material: NSVisualEffectView.Material
  var blendingMode: NSVisualEffectView.BlendingMode

  func makeNSView(context: Context) -> NSVisualEffectView {
    let view = NSVisualEffectView()
    view.material = material
    view.blendingMode = blendingMode
    view.state = .active
    return view
  }

  func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
    nsView.material = material
    nsView.blendingMode = blendingMode
  }
}
