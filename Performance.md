# Performance Insights

If you would like to validate the results, they can be found in the [validation section](#validation).

## Factors Affecting Performance

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

## Performance Summary

```mathematica
------------------- Clakr Test Summary ------------------------

Performance:
  Best Run: 15000 clicks
  Slowest Run: 14798 clicks
  Average: 14972.44 clicks
  Median: 14979.00 clicks
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
  Standard Deviation: ±27.07
  Variance: 732.71
  Coefficient of Variation: 0.18%
  Interquartile Range (IQR): 20.00 clicks
  Standard Error of the Mean (SEM): 2.7069

Distribution Shape:
  Skewness: -3.5104
  Kurtosis: 17.0360

Confidence Intervals:
  95%: 14967.13 - 14977.75
  99%: 14965.47 - 14979.41

Outliers:
  Threshold: 3 standard deviations
  Outlier Clicks: 2
  Outlier Values: 14798, 14876.0

--------------------------------------------------------------
```

## Individual Runs

```mathematica
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
- Run 51: 14943
- Run 52: 14936
- Run 53: 14980
- Run 54: 14984
- Run 55: 14971
- Run 56: 14965
- Run 57: 14965
- Run 58: 14957
- Run 59: 14957
- Run 60: 14937
- Run 61: 14980
- Run 62: 14962
- Run 63: 14945
- Run 64: 14968
- Run 65: 14942
- Run 66: 14989
- Run 67: 14987
- Run 68: 14989
- Run 69: 15000
- Run 70: 14798
- Run 71: 14981
- Run 72: 14988
- Run 73: 14964
- Run 74: 14992
- Run 75: 14942
- Run 76: 14893
- Run 77: 14876
- Run 78: 15000
- Run 79: 14972
- Run 80: 14985
- Run 81: 14973
- Run 82: 14977
- Run 83: 14960
- Run 84: 14956
- Run 85: 14999
- Run 86: 14993
- Run 87: 14988
- Run 88: 14976
- Run 89: 14979
- Run 90: 14974
- Run 91: 14981
- Run 92: 14980
- Run 93: 14976
- Run 94: 14990
- Run 95: 14992
- Run 96: 14987
- Run 97: 14989
- Run 98: 14958
- Run 99: 14988
- Run 100: 14995
```

# Validation

Before we start, this requires brew to be installed. If you do not have brew installed you can install it [here](https://brew.sh).

To ensure Clakr's performance, follow these steps:

1. Get the validation script [here](autoclicker-tests/validator/runcals.js).
2. Install prerequisites:

```bash
brew tap oven-sh/bun
brew install bun
bun install jstat
```

3. Navigate to the script directory:

```bash
cd path/to/autoclicker-tests
```

4. Run the script:

```bash
bun runcals.js
```

> [!TIP]
> Input your Clakr test results in the script for automatic analysis.
> If you've renamed `runcals.js`, adjust the command name accordingly.
