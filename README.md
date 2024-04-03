# clakr

clakr is a sophisticated auto-clicker application designed for macOS. It simulates mouse clicks at user-defined rates, offering a high degree of customization for automated tasks.

## Key Features

- **Configurable Click Rate**: Define the number of clicks per second.
- **Delayed Start**: Initiate clicking after a set period.
- **Automatic Stop**: Cease clicking after a specified duration.
- **Stationary Detection**: Begin clicking only when the mouse has been still for a defined time.

## Performance Analysis

To verify the performance of clakr, you can use our validator script. Follow these steps:

1. Download the validator script from [here](autoclicker-tests/validator/runcals.js).
2. Ensure you have Node.js installed on your system. If not, download and install it from [Node.js official website](https://nodejs.org/).
3. Open your command-line interface (CLI).
4. Change the directory to where the validator script is located using the `cd` command. For example:

```sh
cd path/to/autoclicker-tests
```

5. Install the `jstat` package, which is required by the validator, by running:

```sh
npm install jstat
```

6. Open the `runcals.js` file in a text editor and enter the test values and parameters as needed.
7. Execute the validator script with Node.js by running:

```sh
node runcals.js
```

> Replace `runcals.js` with the filename if you have renamed the validator script.

### Test Summary

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

## Usage

To start using clakr:

1. Adjust the settings to your preference.
2. Click the "Start" button to initiate auto-clicking.
3. To stop, press the "Stop" button or the designated hotkey.
4. For the **Stationary for (seconds)** feature, simply move the mouse to cease clicking.

## Installation

Download the latest release from the GitHub repository and execute the application on your macOS device.

## Contributing

Your contributions are invaluable to clakr's growth. Feel free to submit pull requests or report issues for enhancements and bug fixes.

## License

clakr is open-sourced under the MIT License. For more details, refer to the LICENSE file.

### Validate Performance

Test clakr's capabilities using our custom-made website:

[Source code](autoclicker-tests/index.html) for the website can be found there

For a full understanding of the test environment and to replicate the performance analysis, visit our [autoclicking test](https://clakr-delta.vercel.app/).
