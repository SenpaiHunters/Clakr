//
//  ContentView.swift
//  clakr
//
//  Created by Kami on 2/4/2024.
//

import SwiftUI

enum AccentColor {
    static let primary = Color("AccentColor")
}

class LanguageSettings: ObservableObject {
    @Published var currentLanguage: String = Locale.current.languageCode ?? "en"
}

struct ContentView: View {
    // MARK: - Properties

    @StateObject private var autoClicker = AutoClicker()
    @StateObject private var viewModel = ViewModel()
    @StateObject private var languageSettings = LanguageSettings()

    @AppStorage("clicksPerSecond") private var clicksPerSecond: Double = 1
    @AppStorage("startAfterSeconds") private var startAfterSeconds: TimeInterval = 0
    @AppStorage("stopAfterSeconds") private var stopAfterSeconds: TimeInterval = 0
    @AppStorage("stationaryForSeconds") private var stationaryForSeconds: TimeInterval = 0

    @State private var showingSettings = false

    // MARK: - Body

    var body: some View {
        ZStack {
            backgroundGradient
            content
        }
        .frame(width: 340, height: 450)
        .toolbar { settingsButton }
    }

    // MARK: - Subviews

    private var backgroundGradient: some View {
        LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }

    private var content: some View {
        VStack(spacing: 30) {
            HeaderView()
            SettingsGroupView(
                clicksPerSecond: $clicksPerSecond,
                startAfterSeconds: $startAfterSeconds,
                stopAfterSeconds: $stopAfterSeconds,
                stationaryForSeconds: $stationaryForSeconds,
                languageSettings: languageSettings
            )
            StartStopButton(autoClicker: autoClicker, action: toggleClicking)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }

    private var settingsButton: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Button(action: { NSApp.delegate?.perform(#selector(AppDelegate.toggleSettings)) }) {
                Image(systemName: "gear")
                    .font(.headline)
                    .foregroundColor(AccentColor.primary)
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Settings")
        }
    }

    // MARK: - Methods

    private func toggleClicking() {
        withAnimation {
            autoClicker.toggleClicking()
        }
    }
}

// MARK: - Subview Structs

struct HeaderView: View {
    var body: some View {
        Text("Clakr")
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .foregroundColor(AccentColor.primary)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 2)
    }
}

struct SettingsGroupView: View {
    @Binding var clicksPerSecond: Double
    @Binding var startAfterSeconds: TimeInterval
    @Binding var stopAfterSeconds: TimeInterval
    @Binding var stationaryForSeconds: TimeInterval
    @ObservedObject var languageSettings: LanguageSettings

    var body: some View {
        VStack(spacing: 15) {
            SettingTextField(
                title: "Clicks per second:".localized(using: languageSettings.currentLanguage),
                value: $clicksPerSecond
            )
            SettingStepper(
                title: "Start after (seconds):".localized(using: languageSettings.currentLanguage),
                value: $startAfterSeconds
            )
            SettingStepper(
                title: "Stop after (seconds):".localized(using: languageSettings.currentLanguage),
                value: $stopAfterSeconds
            )
            SettingStepper(
                title: "Stationary for (seconds):".localized(using: languageSettings.currentLanguage),
                value: $stationaryForSeconds
            )
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(15)
    }
}

struct StartStopButton: View {
    @ObservedObject var autoClicker: AutoClicker
    var action: () -> ()

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: autoClicker.isClicking ? "stop.fill" : "play.fill")
                    .font(.title2)
                Text(autoClicker.isClicking ? "Stop" : "Start")
                    .fontWeight(.semibold)
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .buttonStyle(PrimaryButtonStyle(isClicking: autoClicker.isClicking))
        .accessibilityLabel(autoClicker.isClicking ? "Stop clicking" : "Start clicking")
    }
}

// MARK: - Supporting Structs

struct PrimaryButtonStyle: ButtonStyle {
    var isClicking: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(isClicking ? .white : .black)
            .background(isClicking ? Color.red : AccentColor.primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed || isClicking)
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
