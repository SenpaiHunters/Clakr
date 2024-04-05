<div align="center">

# Clakr

Clakr is an auto-clicker application developed in Swift, focusing on high-speed automated mouse clicking. It has undergone testing across different tasks using intervals of 15 seconds to ensure performance consistency.

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE.md)
[![Latest Release](https://img.shields.io/github/release/senpaihunters/clakr.svg)](https://github.com/senpaihunters/clakr/releases)
[![Open Issues](https://img.shields.io/github/issues/senpaihunters/clakr.svg)](https://github.com/senpaihunters/clakr/issues)
[![Build Status](https://img.shields.io/travis/senpaihunters/clakr/master.svg)](https://travis-ci.org/senpaihunters/clakr)

![clakr Banner](assets/clakr.gif)

</div>

> [!NOTE]
>
> The website used for validation is my [auto clicker validator](https://clakr-delta.vercel.app). You can view the [source code here](autoclicker-tests/website).
>
> For a higher quality demonstration, you can download the [MP4 video](/assets/clakr-web.mp4). Please note that GitHub does not natively display MP4 files, so you will need to download and view it locally.

> [!CAUTION]
> Please be aware that by using Clakr, you accept full responsibility for any consequences, such as bans or penalties from software or services that prohibit the use of auto-clickers.

### Activity

![Activity](https://repobeats.axiom.co/api/embed/546eacfe73cf9c90c7f2b0056399fa6bc5cbacbc.svg "analytics image")

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

1. Grab the latest release from the [Releases page](https://github.com/senpaihunters/clakr/releases).
2. Move the application to your Applications folder.
3. If prompted about an unsigned application, right-click and choose "Open".

### How to Use

1. Open Clakr.
2. Set your preferences.
3. Hit "Start" to begin clicking.
4. Stop manually or let the timer do it for you.

## Performance Insights

> [!IMPORTANT]
> This requires brew to be installed.
> If you do not have brew installed you can install it [here](https://brew.sh).

<details>
<summary>Validation Results (Click to Expand)</summary>

To ensure Clakr's performance, follow these steps:

1. Get the validation script [here](autoclicker-tests/validator/runcals.js).
2. Install prerequisites:

```sh
brew install node
npm install jstat
```

3. Navigate to the script directory:

```sh
cd path/to/autoclicker-tests
```

4. Run the script:

```sh
node runcals.js
```

> Input your Clakr test results in the script for automatic analysis.

> If you've renamed `runcals.js`, adjust the command accordingly.

#### Performance Summary

```sh
------------------- Clakr Test Summary ------------------------

Performance:
  Best Run: 15000 clicks
  Slowest Run: 14798 clicks
  Average: 14972.44 clicks
  Median: 14979.50 clicks
  Range: 202.00 clicks (14798 - 15000)
  Perfect Result: 15000 clicks
  Number of times Perfect Result happened: 2
  Probability of Perfect Result: 2.00%

Sample Statistics:
  Sample Size: 100 clicks
  Test Length: 15 seconds
  Clicks Per Second: 1000
  Start after: 3 seconds
  Stationary for: 2 seconds
  Sum of All Clicks: 1497244.00 clicks
  10th Percentile: 14942.00 clicks
  90th Percentile: 14991.10 clicks
  Mode: 14988,14989 clicks

Variability:
  Error Margin: 0.18%
  Standard Deviation: ±27.20
  Variance: 740.11
  Coefficient of Variation: 0.18%
  Interquartile Range (IQR): 20.00 clicks
  Standard Error of the Mean (SEM): 2.7205

Distribution Shape:
  Skewness: -3.5104
  Kurtosis: 17.0360

Confidence Intervals:
  95%: 14967.11 - 14977.77
  99%: 14965.43 - 14979.45

Outliers:
  Threshold: 3 standard deviations
  Outlier Clicks: 2
  Outlier Values: 14798, 14876.0

--------------------------------------------------------------
```

<details>
    <summary>Individual Runs</summary>

- Run 1: 14989
- Run 2: 14990
- Run 3: 14989
- Run 4: 14941
- Run 5: 14925
- Run 6: 14993
- Run 7: 14974
- Run 8: 14977
- Run 9: 14980
- Run 10: 14973
- Run 11: 14968
- Run 12: 14986
- Run 13: 14977
- Run 14: 14979
- Run 15: 14983
- Run 16: 14990
- Run 17: 14992
- Run 18: 14987
- Run 19: 14975
- Run 20: 14987
- Run 21: 14925
- Run 22: 14970
- Run 23: 14965
- Run 24: 14941
- Run 25: 14964
- Run 26: 14988
- Run 27: 14976
- Run 28: 14985
- Run 29: 14990
- Run 30: 14982
- Run 31: 14978
- Run 32: 14984
- Run 33: 14979
- Run 34: 14981
- Run 35: 14977
- Run 36: 14988
- Run 37: 14973
- Run 38: 14986
- Run 39: 14980
- Run 40: 14992
- Run 41: 14989
- Run 42: 14975
- Run 43: 14987
- Run 44: 14978
- Run 45: 14983
- Run 46: 14991
- Run 47: 14976
- Run 48: 14985
- Run 49: 14974
- Run 50: 14988

</details>

### Factors Affecting Performance

Several technical aspects can influence the click count:

1. **Timer Granularity**
2. **Event Coalescing**
3. **System Load**
4. **Thread Scheduling**
5. **API and Driver Overhead**
6. **Hardware Limitations**
7. **Software Limitations**
8. **Precision of Floating-Point Arithmetic**
9. **Interrupts and Context Switching**
10. **Event Processing**

</details>

## Troubleshooting Guide

If you encounter issues while using Clakr, here are some common problems and their solutions:

- **Application won't start**: Ensure that you have the required macOS version and that you have followed the installation steps correctly. If the issue persists, try restarting your computer, if it further does not work, submit an issue on our [Issues page](https://github.com/senpaihunters/clakr/issues).

- **Clicks are not registering**: Check if Clakr has the accessibilty permissions in your system settings and that no other software is interfering with its operation.

If you have further issues, submit an issue on our [Issues page](https://github.com/senpaihunters/clakr/issues).

## Contributing

We welcome contributions! Please feel free to submit pull requests or create issues for any bugs or enhancements.

## Support

If you need help or want to discuss clakr, check out our [Issues](https://github.com/senpaihunters/clakr/issues) page.

## License

clakr is open-sourced under the MIT License. See the [LICENSE](LICENSE.md) file for more details.

## Explore More

- [Autoclicking Test Site](https://clakr-delta.vercel.app/)
- [Validator Source Code](autoclicker-tests/website/index.html)

## Frequently Asked Questions (FAQs)

<details>
<summary>Click to Expand</summary>

- **Q: Can I use Clakr for gaming?**
  - A: Yes, but be aware of the game's terms of service regarding auto-clickers.

- **Q: Does Clakr work on non-macOS systems?**
  - A: Currently, Clakr is only available for macOS version 12.0 or newer.

- **Q: How can I contribute to the development of Clakr?**
  - A: Check out our [Contributing](#contributing) section for guidelines on how to contribute.

- **Q: How much system resources does Clakr use?**
  - A: About 33mb of RAM when open, and depending on how many clicks per second you define, 10% of your CPU whilst activated.

- **Q: Is Clakr a menu bar app?**
  - A: Currently, no Clakr is only an app without a menu bar applicate, this may change later, but as of now, its pretty basic.

- **Q: Does Clakr support Hotkeys?**
  - A: Not yet, but i may add hotkey support in a later release.

- **Q: Do you plan on supporting any lower macOS version?**
  - A: No, macOS 12 is the lowest i plan to support, however, you may be able to build it for lower.

- **Q: Is Clakr available through Homebrew?**
  - A: Currently, Clakr is not available as a Homebrew cask. The project has not yet met the criteria for inclusion in the main Homebrew repository. However, adding Clakr to Homebrew is on our roadmap. If you're experienced with creating Homebrew casks and would like to contribute, we welcome pull requests or direct guidance on this matter! If you require anything for us, feel free to send me a message.

</details>

---

© 2024 clakr. All rights reserved.
