# clakr

clakr is an auto-clicker application for macOS that simulates mouse clicks at a specified rate. It allows users to configure the number of clicks per second, as well as set a delay for the start and stop of the clicking action. Additionally, users can define a period during which the mouse must remain stationary before the auto-clicking begins.

## Performance Analysis

### Goal

- Target Clicks: 15000

### Test Parameters

- Clicks per second: 1,000
- Start after (seconds): 3
- Stop after (seconds): 15
- Stationary for (seconds): 2

### Results

- Best Run: 14993 clicks
- Lowest Run: 14925 clicks
- Average Clicks: 14980.35
- Error Percentage: 0.13%
- Standard Deviation (± number): 18.59
- Variance: 345.89
- 95% Confidence Interval: 14976.07 to 14984.63
- 99% Confidence Interval: 14974.48 to 14986.22
- Median Clicks: 14979.5
- Range: 68 clicks (14925 to 14993)
- Coefficient of Variation: 0.12%

### Runs

- Run one: 14989
- Run two: 14990
- Run three: 14989
- Run four: 14941
- Run five: 14925
- Run six: 14993
- Run seven: 14974
- Run eight: 14977
- Run nine: 14980
- Run ten: 14973
- Run eleven: 14968
- Run twelve: 14986
- Run thirteen: 14977
- Run fourteen: 14979
- Run fifteen: 14983
- Run sixteen: 14990
- Run seventeen: 14992
- Run eighteen: 14987
- Run nineteen: 14975
- Run twenty: 14987

### Validating results

I use a simple custom made website to get the max pref out of my app, you can validate this here. It might be honest on vercel for future info.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>clakr tester</title>
    <style>
        body {
            background-color: #000000;
            color: #f0f0f0;
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        #click-area {
            margin-top: 50px;
            text-align: center;
        }

        #click-counter {
            font-size: 2rem;
            margin-bottom: 20px;
        }

        #click-me {
            padding: 15px 30px;
            font-size: 1.25rem;
            background-color: #7c47d2;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        #click-me:hover {
            background-color: #7632e2;
        }

        #click-me:active {
            background-color: #6324c7;
        }

        @media (max-width: 768px) {
            #click-counter {
                font-size: 1.5rem;
            }

            #click-me {
                font-size: 1rem;
                padding: 10px 20px;
            }
        }
    </style>
</head>
<body>
    <div id="click-area">
        <div id="click-counter">Clicks: 0</div>
        <button id="click-me">Click Me!</button>
    </div>

    <script>
        let count = 0;
        const counterDisplay = document.getElementById('click-counter');
        const clickButton = document.getElementById('click-me');
    
        clickButton.addEventListener('click', () => {
            count++; // Increment the counter
        });
    
        function updateDisplay() {
            counterDisplay.textContent = `Clicks: ${count}`;
            requestAnimationFrame(updateDisplay);
        }
        updateDisplay();
    </script>
</body>
</html>
```

### Reasons the result was not hit

1. Timer Granularity: The granularity of timers in most operating systems is not fine enough to guarantee exact timing for such high-frequency events. There's a minimum threshold below which the timer cannot accurately measure time, leading to slight deviations.
2. Event Coalescing: Operating systems often optimize for performance by coalescing rapid, successive events into fewer events to reduce the processing load. This can lead to fewer clicks being registered than expected.
3. System Load: The current load on the system can affect the performance of your application. If the CPU is busy with other tasks, it may not be able to process the click events at the desired rate.
4. Thread Scheduling: The operating system's scheduler may not give the thread that's handling the clicking uninterrupted CPU time, especially if the system is under heavy load or if there are higher-priority tasks.
5. API and Driver Overhead: The APIs and drivers that handle mouse events have their own overhead. They are not designed for such high-frequency interaction and may not be able to keep up with the requested rate.
6. Hardware Limitations: The mouse hardware and its driver may not be capable of registering or sending clicks at the desired rate. There's a limit to how quickly the hardware can generate and the system can process input events.
7. Software Limitations: The software stack, including the operating system, windowing system, and application frameworks, is optimized for typical human interaction speeds and may not support extremely high-frequency automated interactions.
8. Precision of Floating-Point Arithmetic: The calculation of intervals and rates involves floating-point arithmetic, which can introduce small rounding errors that accumulate over time and result in fewer clicks.
9. Interrupts and Context Switching: The operating system handles many tasks simultaneously, and interrupts or context switches can delay the processing of click events.
10. Event Processing: Each event must be processed by the system's event loop, and this processing takes time. If events are generated faster than they can be processed, some will inevitably be dropped.

## Features

- **Clicks per second**: Set the number of auto-clicks to be performed in one second.
- **Start after (seconds)**: Delay the start of the auto-clicking by a specified number of seconds.
- **Stop after (seconds)**: Automatically stop clicking after a certain period.
- **Stationary for (seconds)**: Wait for the mouse to be stationary for a specified duration before starting to click.

## Usage

To use clakr, adjust the settings to your preference and click the "Start" button. To stop the auto-clicking, press the "Stop" button or use the designated hotkey. Or, if you have the **Stationary for (seconds)**, simply shake your mouse/cursor.

## Installation

To install clakr, download the latest release from the GitHub repository and run the application on your macOS device.

## Contributing

Contributions to clakr are welcome. Please feel free to submit pull requests or create issues for bugs and feature requests.

## License

clakr is released under the MIT License. See the LICENSE file for more details.
