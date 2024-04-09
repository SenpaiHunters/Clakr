//
//  ContentView.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var autoClicker = AutoClicker()
  @AppStorage("clicksPerSecond") private var clicksPerSecond: Double = 1
  @AppStorage("startAfterSeconds") private var startAfterSeconds: TimeInterval = 0
  @AppStorage("stopAfterSeconds") private var stopAfterSeconds: TimeInterval = 0
  @AppStorage("stationaryForSeconds") private var stationaryForSeconds: TimeInterval = 0
  @StateObject var viewModel = ViewModel()
  @State private var showingSettings = false

  var body: some View {
    ZStack {
      VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        .edgesIgnoringSafeArea(.all)
      content
    }
    .toolbar { settingsButton }
    .onReceive(NotificationCenter.default.publisher(for: .showSettings)) { _ in
      if !showingSettings {
        showingSettings = true
      }
    }
    .sheet(isPresented: $showingSettings) {
      SettingsView(autoClicker: autoClicker)
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
    .padding(.horizontal, 10)
  }

  private var settingsButton: some ToolbarContent {
    ToolbarItem(placement: .principal) {
      Button(action: { showingSettings.toggle() }) {
        Label("Settings", systemImage: "gear")
          .font(.headline)
          .foregroundColor(.primary)
          .padding(.vertical, 2)
          .padding(.horizontal, 20)
          .background(showingSettings ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
          .cornerRadius(10)
          .overlay(
            RoundedRectangle(cornerRadius: 10)
              .stroke(Color.accentColor, lineWidth: 1)
          )
          .scaleEffect(showingSettings ? 1.05 : 1.0)
          .animation(.easeInOut(duration: 0.2), value: showingSettings)
          .padding(.bottom, 2)
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
      SettingTextField(title: "Clicks per second:", value: $clicksPerSecond)
      SettingStepper(title: "Start after (seconds):", value: $startAfterSeconds)
      SettingStepper(title: "Stop after (seconds):", value: $stopAfterSeconds)
      SettingStepper(title: "Stationary for (seconds):", value: $stationaryForSeconds)
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
      autoClicker.toggleClicking()  // This will handle the sound as well
      if autoClicker.isClicking {
        autoClicker.startClicking(
          clicksPerSecond: clicksPerSecond, startAfter: startAfterSeconds,
          stopAfter: stopAfterSeconds, stationaryFor: stationaryForSeconds)
      } else {
        autoClicker.stopClicking()
      }
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
        .foregroundColor(.secondary)
      Spacer()
      TextField("", value: $value, formatter: Self.decimalFormatter)
        .frame(width: 80)
        .multilineTextAlignment(.trailing)
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(10)
  }

  private static var decimalFormatter: NumberFormatter {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    return formatter
  }
}

struct SettingStepper: View {
  var title: String
  @Binding var value: TimeInterval

  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.secondary)
      Spacer()
      Text("\(Int(value))")
        .foregroundColor(.primary)
        .frame(width: 50, alignment: .trailing)
      Stepper("", value: $value, in: 0...Double.infinity, step: 1)
        .labelsHidden()
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.1))
    .cornerRadius(10)
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
