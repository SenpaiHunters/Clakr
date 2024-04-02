//
//  ContentView.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var autoClicker = AutoClicker()
    @State private var isClicking = false
    @State private var clicksPerSecond: Double
    @State private var startAfterSeconds: TimeInterval
    @State private var stopAfterSeconds: TimeInterval
    @State private var stationaryForSeconds: TimeInterval
    @State private var hotkey: String

    init() {
        // Load saved values or use default values
        _clicksPerSecond = State(initialValue: UserDefaults.standard.double(forKey: "clicksPerSecond") == 0 ? 1 : UserDefaults.standard.double(forKey: "clicksPerSecond"))
        _startAfterSeconds = State(initialValue: UserDefaults.standard.double(forKey: "startAfterSeconds"))
        _stopAfterSeconds = State(initialValue: UserDefaults.standard.double(forKey: "stopAfterSeconds"))
        _stationaryForSeconds = State(initialValue: UserDefaults.standard.double(forKey: "stationaryForSeconds"))
        _hotkey = State(initialValue: UserDefaults.standard.string(forKey: "hotkey") ?? "")
    }

var body: some View {
    ZStack {
        VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
            .edgesIgnoringSafeArea(.all)

        VStack(spacing: 20) {
            Text("Clakr")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top)

            Divider()

            SettingTextField(title: "Clicks per second:", value: $clicksPerSecond)
            SettingStepper(title: "Start after (seconds):", value: $startAfterSeconds)
            SettingStepper(title: "Stop after (seconds):", value: $stopAfterSeconds)
            SettingStepper(title: "Stationary for (seconds):", value: $stationaryForSeconds)

            Divider()

            // TextField("Record Shortcut", text: $hotkey)
               // .textFieldStyle(RoundedBorderTextFieldStyle())
                // .padding()
                // .background(Color.gray.opacity(0.2))
                // .cornerRadius(8)

            Spacer()

            Button(action: toggleClicking) {
                Text(isClicking ? "Stop" : "Start")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding()
                    .background(isClicking ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .font(.headline)
                    .cornerRadius(8)
                    .shadow(radius: 4)
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.bottom)

            Text("You can pause the auto-clicking by holding the function (fn) key.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .onReceive(autoClicker.$isClicking) { newValue in
        isClicking = newValue
    }
       // Save the values whenever they change
 .onChange(of: clicksPerSecond) { newValue, _ in
 print("Saving clicksPerSecond: \(newValue)")
    UserDefaults.standard.set(newValue, forKey: "clicksPerSecond")
    UserDefaults.standard.synchronize()
}
.onChange(of: startAfterSeconds) { newValue, _ in
    UserDefaults.standard.set(newValue, forKey: "startAfterSeconds")
}
.onChange(of: stopAfterSeconds) { newValue, _ in
    UserDefaults.standard.set(newValue, forKey: "stopAfterSeconds")
}
.onChange(of: stationaryForSeconds) { newValue, _ in
    UserDefaults.standard.set(newValue, forKey: "stationaryForSeconds")
}
.onChange(of: hotkey) { newValue, _ in
    UserDefaults.standard.set(newValue, forKey: "hotkey")
}
}
private func toggleClicking() {
    isClicking.toggle()
    if isClicking {
        // Pass the values from ContentView's state variables to the AutoClicker
        autoClicker.startClicking(
            clicksPerSecond: clicksPerSecond,
            startAfter: startAfterSeconds,
            stopAfter: stopAfterSeconds,
            stationaryFor: stationaryForSeconds
        )
    } else {
        autoClicker.stopClicking()
    }
}
}

struct SettingTextField: View {
    var title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            TextField("", value: $value, formatter: NumberFormatter())
                .frame(width: 80)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .multilineTextAlignment(.trailing)
        }
        .padding()
        .cornerRadius(8)
    }
}

struct SettingStepper: View {
    var title: String
    @Binding var value: TimeInterval

    var body: some View {
        Stepper(value: $value, in: 0...Double.infinity, step: 1) {
            Text("\(title) \(Int(value))")
        }
        .padding()
        .cornerRadius(8)
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

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}