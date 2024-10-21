<div align="center">

# Clakr

Click that, Clakr that!

Clakr is an auto-clicker application developed in Swift, focusing on high-speed automated mouse clicking.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/release/senpaihunters/clakr.svg)](https://github.com/senpaihunters/clakr/releases)
[![Open Issues](https://img.shields.io/github/issues/senpaihunters/clakr.svg)](https://github.com/senpaihunters/clakr/issues)

![clakr Banner](assets/clakr.gif)

---

![Activity](https://repobeats.axiom.co/api/embed/546eacfe73cf9c90c7f2b0056399fa6bc5cbacbc.svg "analytics image")

</div>

> [!NOTE]
>
> The website used for validation is my [auto clicker validator](https://clakr-delta.vercel.app). You can view the [source code here](autoclicker-tests/website).
>
> For a higher quality demonstration, you can download the [MP4 video](/assets/clakr-web.mp4). Please note that GitHub does not natively display MP4 files, so you will need to download and view it locally.

> [!CAUTION]
> Please be aware that by using Clakr, you accept full responsibility for any consequences, such as bans or penalties from software or services that prohibit the use of auto-clickers.

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [Installation](#installation-steps)
- [Performance Insights](#performance-insights)
- [Development or Self-Compiling](#development-or-self-compiling)
- [Troubleshooting Guide](#troubleshooting-guide)
- [Contributing](#contributing)
- [Support](#support)
- [License](#license)
- [Acknowledgments](#acknowledgments)
- [FAQs](#frequently-asked-questions-faqs)

## Features

- **Custom Click Rates**: Define your clicks per second.
- **Start Delay**: Plan when the clicking begins.
- **Auto-Stop Function**: Automate the end of your clicking session.
- **Motion Detection**: Only clicks when the mouse is stationary.

## Quick Start

### Requirements

- macOS version 12.0 or newer.

> [!NOTE]
> Clakr may look different compared to the picture above on macOS 12, the picture is from 14.2

### Installation Steps

You can install Clakr using Homebrew or by downloading it directly from the GitHub releases page.

#### Installing via Homebrew

To install Clakr using Homebrew, run the following command in your terminal:

```bash
brew install --cask --no-quarantine SenpaiHunters/clakr/clakr
```

- It's important to note that passing `--no-quarantine` with brew ensures macOS Gatekeeper is disabled, allowing the app to open even if it's unsigned.

> [!TIP]
>
> The Homebrew cask for Clakr are maintained in a separate repository, which is open-sourced and available [here](https://github.com/SenpaiHunters/homebrew-clakr).

#### Installing from GitHub Releases

Alternatively, you can manually install Clakr by downloading the latest release:

1. Download the latest release from the [Releases page](https://github.com/senpaihunters/clakr/releases).
2. Move the downloaded application to your Applications folder.
3. If macOS prompts you about an unsigned application, right-click on Clakr and choose "Open" to proceed with the installation.

This method allows you to bypass macOS's gatekeeper checks for unsigned applications on the first run.

> [!TIP]
>
> Want to skip needing to reconfirm each update? Run `xattr -d com.apple.quarantine clakr.app`, this will disable quarantine, i.e., Gatekeeper for the app.

## Performance Insights

This has been moved to [Performance.md](Performance.md). For the results, check there!

## Development or Self-Compiling

### Instructions

#### Before You Begin

*Skip this section if you already have an Apple Developer account.*

0. Enroll your account in the Developer Program at [developer.apple.com](https://developer.apple.com/). A free account works just fine; you don't need a paid one.
1. Install Xcode.
2. Add your Developer account to Xcode. To do this, click `Xcode → Preferences` in the Menu bar, and in the window that opens, click `Accounts`. You can add your account there.
3. After adding your account, it will appear in the list of Apple IDs on the left side of the screen. Select your account.
4. At the bottom of the screen, click `Manage Certificates...`.
5. On the bottom left, click the **+** icon and select `Apple Development`.
6. When a new item labeled `Apple Development Certificates` appears in the list, press `Done` to close the account manager.

#### Compiling Clakr

1. Clone this repository using `git clone https://github.com/SenpaiHunters/Clakr.git && cd Clakr && open Clakr.xcodeproj`. Xcode will open the project.
2. Wait until all dependencies are resolved. This should take a couple of minutes at most.
3. In the file browser on the left, click `Clakr` at the very top. It's the icon with the App Store logo.
4. In the pane that opens on the right, click `Signing & Capabilities` at the top.
5. Under `Signing`, change the `Team` dropdown to `None`.
6. Under `Signing → macOS`, change the `Signing Certificate` to `Sign to Run Locally`.
7. In the Menu Bar, click `Product → Archive` and wait for the build to finish.
8. A new window will open. From the list of Clakr entries, select the topmost one, and click `Distribute App`.
9. In the popup that appears, click `Custom`, then click `Next` in the bottom right of the popup.
10. Click `Copy App`.
11. Open the resulting folder. You'll see an app named Clakr. Drag Clakr to your `/Applications/` folder, and you're all set!

## Troubleshooting Guide

If you encounter issues while using Clakr, here are some common problems and their solutions:

- **Application won't start**: Ensure that you have the required macOS version and that you have followed the installation steps correctly. If the issue persists, try restarting your computer. If the problem continues, please submit an issue on our [Issues page](https://github.com/senpaihunters/clakr/issues).

- **Clicks are not registering**: Check if Clakr has the accessibility permissions in your system settings and ensure that no other software is interfering with its operation.

If you encounter further issues, please submit an issue on our [Issues page](https://github.com/senpaihunters/clakr/issues).

## Contributing

We welcome contributions! Feel free to submit pull requests or create issues for any bugs or enhancements.

## Support

If you need help or want to discuss Clakr, check out our [Issues page](https://github.com/senpaihunters/clakr/issues).

## License

This project is licensed under the GNU GPLv3 license. See the [LICENSE](LICENSE.md) file for more details.

## Acknowledgments

- [KawaiiFumiko002](https://github.com/Alessandro15204)
  - [App icon creator](https://github.com/SenpaiHunters/Clakr/tree/main/clakr/clakr/Assets.xcassets/AppIcon.appiconset)

- [Sindre Sorhus](https://github.com/sindresorhus)
  - [Keyboard Shortcuts](https://github.com/sindresorhus/KeyboardShortcuts)

## Explore More

- [Autoclicking Test Site](https://clakr-delta.vercel.app/)
- [Validator Source Code](autoclicker-tests/website/index.html)

## Frequently Asked Questions (FAQs)

<details>
<summary>Click to Expand</summary>

- **Q: Can I use Clakr for gaming?**
  - A: Yes, but you should check the game's terms of service regarding the use of auto-clickers. Clakr will not be held responsible for any consequences, such as bans or penalties, from software or services that prohibit the use of auto-clickers.

- **Q: Does Clakr work on non-macOS systems?**
  - A: Currently, Clakr is only available for macOS version 12.0 or newer.

- **Q: How can I contribute to the development of Clakr?**
  - A: Check out our [Contributing](#contributing) section for guidelines on how to contribute.

- **Q: How much system resources does Clakr use?**
  - A: Clakr uses about 38.7 MB of RAM when open, and depending on the clicks per second (CPS) you set, it consumes approximately 0.7% of your CPU while active (values measured using `btop`).

- **Q: Is Clakr a menu bar app?**
  - A: Yes, Clakr can be configured as a menu bar app or used as a standalone application, whichever you prefer. This option can be found in the settings.

- **Q: Does Clakr support hotkeys?**
  - A: Yes, hotkey activation for Clakr is supported!

- **Q: Do you plan on supporting any lower macOS versions?**
  - A: No, macOS 12 is the minimum version we plan to support. Building Clakr for lower versions may be possible, but it is untested and not officially supported.

- **Q: Is Clakr available through Homebrew?**
  - A: Yes! It can be installed by running `brew install --cask --no-quarantine SenpaiHunters/clakr/clakr`.

- **Q: Am I going to change the name to Clark?**
  - A: Who knows! Maybe, even I don't know!

- **Q: Does Clakr track me?**
  - A: Not at all, it does not even connect to the internet and is completely open-source and sandboxed.

</details>

---

© 2024 Clakr GNU General Public License v3.0.
