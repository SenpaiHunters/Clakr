# clakr

clakr is a sophisticated auto-clicker application designed for macOS. It simulates mouse clicks at user-defined rates, offering a high degree of customization for automated tasks.

## Key Features

- **Configurable Click Rate**: Define the number of clicks per second.
- **Delayed Start**: Initiate clicking after a set period.
- **Automatic Stop**: Cease clicking after a specified duration.
- **Stationary Detection**: Begin clicking only when the mouse has been still for a defined time.

## Performance Analysis

Achieve precision in automated clicking with clakr's robust performance, as evidenced by our comprehensive testing:

- **Target Clicks**: 15,000
- **Click Rate**: 1,000 clicks/second
- **Start Delay**: 3 seconds
- **Stop Time**: 15 seconds
- **Stationary Period**: 2 seconds

### Test Results

- **Best Run**: 14,993 clicks
- **Lowest Run**: 14,925 clicks
- **Average**: 14,980.35 clicks
- **Error Margin**: 0.13%
- **Standard Deviation**: ±18.59
- **Variance**: 345.89
- **95% Confidence Interval**: 14,976.07 - 14,984.63
- **99% Confidence Interval**: 14,974.48 - 14,986.22
- **Median**: 14,979.5 clicks
- **Range**: 68 clicks (14,925 - 14,993)
- **Coefficient of Variation**: 0.12%

### Individual Runs

Detailed run data showcasing the consistency and reliability of clakr:

- Run 1: 14,989
- Run 2: 14,990
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
