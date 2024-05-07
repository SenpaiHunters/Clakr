//
//  AboutView.swift
//  clakr
//
//  Created by Kami on 29/4/2024.
//

import SwiftUI

private struct Constants {
  static let cornerRadius: CGFloat = 10
  static let padding: CGFloat = 20
  static let urls = [
    "visitWebsite": ("Visit Website", URL(string: "https://github.com/SenpaiHunters/clakr")!),
    "keyboardShortcuts": (
      "KeyboardShortcuts library", URL(string: "https://github.com/sindresorhus/KeyboardShortcuts")!
    ),
    "sparkleProject": (
      "Sparkle Project", URL(string: "https://github.com/sparkle-project/Sparkle")!
    ),
    "appIconMaker": (
      "KawaiiFumiko002: App icon creator", URL(string: "https://github.com/Alessandro15204")!
    ),
    "devSupport": (
      "Support development", URL(string: "https://www.buymeacoffee.com/kamiamvs")!
    ),
    "privacyPolicy": (
      "Privacy Policy", URL(string: "https://github.com/SenpaiHunters/clakr/Private%20Policy.md")!
    ),
  ]
  static let licenseUrls = [
    "keyboardShortcuts": URL(
      string: "https://github.com/sindresorhus/KeyboardShortcuts/blob/main/license"),
    "sparkleProject": URL(string: "https://github.com/sparkle-project/Sparkle/blob/master/LICENSE"),
  ]
}

struct AboutMenuBarView: View {
  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 12) {
        appIcon
        appNameAndVersion.padding(.bottom, 5)
        copyright.padding(.bottom, 5)
        websiteAndPrivacyPolicyLinks.padding(.bottom, 5)
        acknowledgments
      }
      .padding(.all, Constants.padding)
      .frame(width: 400)
      .cornerRadius(Constants.cornerRadius)
    }
    .frame(width: 400, height: 400)
  }

  private var appIcon: some View {
    Image(nsImage: NSApplication.shared.applicationIconImage)
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 64, height: 64)
      .cornerRadius(Constants.cornerRadius)
  }

  private var appNameAndVersion: some View {
    VStack {
      Text("Clakr").font(.title).fontWeight(.bold)
      HStack {
        Text(versionText).font(.subheadline)
        Button(action: { copyVersionToClipboard(versionText) }) {
          Image(systemName: "doc.on.doc")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .accessibilityLabel(Text("Copy Version"))
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.leading, 5)
      }
    }
  }

  private var versionText: String {
    let version =
      Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
    return "Version: \(version) (\(build))"
  }

  private func copyVersionToClipboard(_ text: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(text, forType: .string)
  }

  private var copyright: some View {
    VStack {
      Text("© \(currentYear) Kami").font(.footnote)
      Text("Licensed under the GNU General Public License v3.0").font(.footnote)
    }
    .foregroundColor(.secondary)
  }

  // Helper property to get the current year as a string
  private var currentYear: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter.string(from: Date())
  }

  private var websiteAndPrivacyPolicyLinks: some View {
    HStack(spacing: 20) {
      ForEach(["privacyPolicy", "visitWebsite", "devSupport"], id: \.self) { key in
        if let (name, url) = Constants.urls[key] {
          Link(name, destination: url)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .center)
  }

  private var acknowledgments: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text("Acknowledgements").font(.headline)
      VStack(alignment: .leading, spacing: 8) {
        ForEach(["keyboardShortcuts", "sparkleProject", "appIconMaker"], id: \.self) { key in
          if let (name, url) = Constants.urls[key] {
            // Directly access the URL or provide nil if not present, avoiding double optionality
            let licenseUrl: URL? = Constants.licenseUrls[key] ?? nil
            acknowledgmentLink(name: name, url: url, licenseUrl: licenseUrl)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  private func acknowledgmentLink(name: String, url: URL, licenseUrl: URL? = nil) -> some View {
    HStack {
      Link(name, destination: url).font(.body)
      Spacer()
      if let licenseUrl = licenseUrl {
        Button(action: { NSWorkspace.shared.open(licenseUrl) }) {
          Image(systemName: "doc.on.doc")
            .resizable()
            .scaledToFit()
            .frame(width: 16, height: 16)
            .accessibilityLabel(Text("Open License"))
        }
        .buttonStyle(BorderlessButtonStyle())
        .padding(.trailing, 5)
      }
      Button(action: { NSWorkspace.shared.open(url) }) {
        Image(systemName: "arrow.up.right.circle")
          .resizable()
          .scaledToFit()
          .frame(width: 16, height: 16)
          .accessibilityLabel(Text("Open Link"))
      }
      .buttonStyle(BorderlessButtonStyle())
    }
    .padding(.vertical, 4)
  }
}
