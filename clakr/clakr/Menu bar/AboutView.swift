//
//  AboutView.swift
//  clakr
//
//  Created by Kami on 29/4/2024.
//

import SwiftUI

private enum Constants {
    static let cornerRadius: CGFloat = 10
    static let padding: CGFloat = 20
    static let frameSize = CGSize(width: 400, height: 400)
    static let iconSize: CGFloat = 64
    static let buttonSize: CGFloat = 16

    static let urls: [URLType: URL] = [
        .website: URL(string: "https://github.com/SenpaiHunters/clakr")!,
        .keyboardShortcuts: URL(string: "https://github.com/sindresorhus/KeyboardShortcuts")!,
        .appIconMaker: URL(string: "https://github.com/Alessandro15204")!,
        .devSupport: URL(string: "https://www.buymeacoffee.com/kamiamvs")!,
        .privacyPolicy: URL(string: "https://github.com/SenpaiHunters/clakr/Private%20Policy.md")!,
        .keyboardShortcutsLicense: URL(string: "https://github.com/sindresorhus/KeyboardShortcuts/blob/main/license")!
    ]
}

enum URLType {
    case website, keyboardShortcuts, appIconMaker, devSupport, privacyPolicy, keyboardShortcutsLicense

    var displayName: String {
        switch self {
        case .website: "Visit Website"
        case .keyboardShortcuts: "KeyboardShortcuts library"
        case .appIconMaker: "KawaiiFumiko002: App icon creator"
        case .devSupport: "Support development"
        case .privacyPolicy: "Privacy Policy"
        case .keyboardShortcutsLicense: "KeyboardShortcuts License"
        }
    }
}

struct AboutMenuBarView: View {
    @State private var currentYear = Calendar.current.component(.year, from: Date())

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 12) {
                appIcon
                appNameAndVersion
                copyright
                websiteAndPrivacyPolicyLinks
                acknowledgments
            }
            .padding(.all, Constants.padding)
            .frame(width: Constants.frameSize.width)
            .cornerRadius(Constants.cornerRadius)
        }
        .frame(width: Constants.frameSize.width, height: Constants.frameSize.height)
    }

    private var appIcon: some View {
        Image(nsImage: NSApplication.shared.applicationIconImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.iconSize, height: Constants.iconSize)
            .cornerRadius(Constants.cornerRadius)
    }

    private var appNameAndVersion: some View {
        VStack {
            Text("Clakr").font(.title).fontWeight(.bold)
            HStack {
                Text(versionText).font(.subheadline)
                CopyButton(text: versionText)
            }
        }
        .padding(.bottom, 5)
    }

    private var versionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
        return "Version: \(version) (\(build))"
    }

    private var copyright: some View {
        VStack {
            Text("© \(currentYear) Kami")
            Text("Licensed under the GNU General Public License v3.0")
        }
        .font(.footnote)
        .foregroundColor(.secondary)
        .padding(.bottom, 5)
    }

    private var websiteAndPrivacyPolicyLinks: some View {
        HStack(spacing: 20) {
            ForEach([URLType.privacyPolicy, .website, .devSupport], id: \.self) { urlType in
                Link(urlType.displayName, destination: Constants.urls[urlType]!)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 5)
    }

    private var acknowledgments: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Acknowledgements").font(.headline)
            VStack(alignment: .leading, spacing: 8) {
                ForEach([URLType.keyboardShortcuts, .appIconMaker], id: \.self) { urlType in
                    AcknowledgmentLink(
                        name: urlType.displayName,
                        url: Constants.urls[urlType]!,
                        licenseUrl: urlType == .keyboardShortcuts ? Constants.urls[.keyboardShortcutsLicense] : nil
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct CopyButton: View {
    let text: String

    var body: some View {
        Button(action: copyToClipboard) {
            Image(systemName: "doc.on.doc")
                .resizable()
                .scaledToFit()
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                .accessibilityLabel(Text("Copy Version"))
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.leading, 5)
    }

    private func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

struct AcknowledgmentLink: View {
    let name: String
    let url: URL
    let licenseUrl: URL?

    var body: some View {
        HStack {
            Link(name, destination: url).font(.body)
            Spacer()
            if let licenseUrl {
                LinkButton(url: licenseUrl, iconName: "doc.on.doc", label: "Open License")
                    .padding(.trailing, 5)
            }
            LinkButton(url: url, iconName: "arrow.up.right.circle", label: "Open Link")
        }
        .padding(.vertical, 4)
    }
}

struct LinkButton: View {
    let url: URL
    let iconName: String
    let label: String

    var body: some View {
        Button(action: { NSWorkspace.shared.open(url) }) {
            Image(systemName: iconName)
                .resizable()
                .scaledToFit()
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                .accessibilityLabel(Text(label))
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
