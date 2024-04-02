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

  @State private var isClicking = false

  var body: some View {
    ZStack {
      VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
        .edgesIgnoringSafeArea(.all)

      VStack(spacing: 20) { 
        headerView
        Divider()
        settingsGroup
        Divider()
        startStopButton
      }
      .padding(.horizontal, 10)
      .padding(.top, -5)
    }
    .frame(
      minWidth: 320, idealWidth: 320, maxWidth: 340, minHeight: 450, idealHeight: 450,
      maxHeight: 460
    )
    .onReceive(autoClicker.$isClicking) { isClicking = $0 }
  }

  private var headerView: some View {
    Text("Clakr")
      .font(.system(size: 36, weight: .bold))
      .foregroundColor(.accentColor)
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
        Text(isClicking ? "Stop" : "Start")
          .fontWeight(.semibold)
          .font(.title3)
      } icon: {
        Image(systemName: isClicking ? "stop.fill" : "play.fill")
          .font(.title3)
      }
    }
    .buttonStyle(PrimaryButtonStyle(isClicking: isClicking))
    .accessibilityLabel(isClicking ? "Stop clicking" : "Start clicking")
    .accessibilityHint("Toggles the auto-clicker on or off")
    .accessibilityAddTraits(.isButton)
  }
  private func toggleClicking() {
    isClicking.toggle()
    if isClicking {
      autoClicker.startClicking(
        clicksPerSecond: clicksPerSecond, startAfter: startAfterSeconds,
        stopAfter: stopAfterSeconds, stationaryFor: stationaryForSeconds)
    } else {
      autoClicker.stopClicking()
    }
  }

  struct PrimaryButtonStyle: ButtonStyle {
    var isClicking: Bool
    @State private var isHovering = false

    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .padding()
        .foregroundColor(.white)
        .background(
          LinearGradient(
            gradient: Gradient(colors: [
              isClicking ? .red : .blue, isHovering ? .gray : (isClicking ? .orange : .purple),
            ]),
            startPoint: .leading,
            endPoint: .trailing
          )
        )
        .cornerRadius(15)
        .scaleEffect(configuration.isPressed ? 0.96 : (isHovering ? 1.04 : 1))
        .shadow(color: isHovering ? .gray : (isClicking ? .red : .blue), radius: 2, x: 0, y: 2)
        .overlay(
          RoundedRectangle(cornerRadius: 15)
            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
        )
        .animation(.easeInOut, value: isHovering)
        .animation(.easeInOut, value: configuration.isPressed)
        .animation(.easeInOut, value: isClicking)
        #if os(macOS)
          .onHover { hover in
            isHovering = hover
          }
        #endif
    }
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
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .multilineTextAlignment(.trailing)
        #if canImport(UIKit)
          .keyboardType(.decimalPad)
        #endif
    }
    .padding(.vertical, 8)
    .padding(.horizontal)
    .background(Color.gray.opacity(0.2))
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
    .background(Color.gray.opacity(0.2))
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
