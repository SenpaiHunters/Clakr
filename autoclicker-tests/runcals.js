// jStat library is used for statistical calculations (https://jstat.github.io/)
const jStat = require('jstat').jStat;

// Array of click counts from your Clakr results
const clicks = [
  14989, 14990, 14989, 14941, 14925, 14993, 14974, 14977, 14980, 14973,
  14968, 14986, 14977, 14979, 14983, 14990, 14992, 14987, 14975, 14987,
  14925, 14970, 14965, 14941, 14964, 14988, 14976, 14985, 14990, 14982,
  14978, 14984, 14979, 14981, 14977, 14988, 14973, 14986, 14980, 14992,
  14989, 14975, 14987, 14978, 14983, 14991, 14976, 14985, 14974, 14988,
  14943, 14936, 14980, 14984, 14971, 14965, 14965, 14957, 14957, 14937,
  14980, 14962, 14945, 14968, 14942, 14989, 14987, 14989, 15000, 14798,
  14981, 14988, 14964, 14992, 14942, 14893, 14876, 15000, 14972, 14985,
  14973, 14977, 14960, 14956, 14999, 14993, 14988, 14976, 14979, 14974,
  14981, 14980, 14976, 14990, 14992, 14987, 14989, 14958, 14988, 14995
];

const testParams = {
  duration: 15, // Duration of test in seconds [DEFAULT: 15]
  clicksPerSecond: 1000, // Expected clicks per second [DEFAULT: 1000]
  startAfter: 3, // Delay before test starts in seconds [DEFAULT: 3]
  stationaryFor: 2, // Time to remain stationary in seconds [DEFAULT: 2]
};

const sampleSize = clicks.length;
const sumClicks = jStat.sum(clicks);
const average = sumClicks / sampleSize;
const stdDev = jStat.stdev(clicks, true);
const perfectResult = testParams.duration * testParams.clicksPerSecond;

const stats = {
  bestRun: jStat.max(clicks),
  lowestRun: jStat.min(clicks),
  average: average,
  medianClicks: jStat.median(clicks),
  rangeClicks: jStat.range(clicks),
  quartiles: jStat.quartiles(clicks),
  iqr: jStat.quartiles(clicks)[2] - jStat.quartiles(clicks)[0],
  perfectResult: perfectResult,
  sem: stdDev / Math.sqrt(sampleSize),
  percentile10th: jStat.percentile(clicks, 0.1),
  percentile90th: jStat.percentile(clicks, 0.9),
  variance: jStat.variance(clicks, true),
  mode: jStat.mode(clicks),
  skewness: jStat.skewness(clicks),
  kurtosis: jStat.kurtosis(clicks),
  outlierThreshold: 3,
  perfectCount: clicks.filter(click => click === perfectResult).length,
  outliers: clicks.filter(click => Math.abs(click - average) > 3 * stdDev)
};

stats.probabilityOfPerfect = stats.perfectCount / sampleSize;
stats.errorMargin = (stdDev / average) * 100;
stats.confidence95 = confidenceInterval(0.95, average, stdDev, sampleSize);
stats.confidence99 = confidenceInterval(0.99, average, stdDev, sampleSize);

function confidenceInterval(confidenceLevel, mean, standardDeviation, size) {
  const z = jStat.normal.inv((1 + confidenceLevel) / 2, 0, 1);
  const marginOfError = z * standardDeviation / Math.sqrt(size);
  return [mean - marginOfError, mean + marginOfError];
}

function toFixed(num, digits = 2) {
  return num.toFixed(digits);
}

// Output results
console.log(generateReport(stats, testParams, toFixed));

function generateReport(stats, testParams, formatter) {
  return `
------------------- Clakr Test Summary ------------------------

Performance:
  Best Run: ${(stats.bestRun)} clicks
  Slowest Run: ${(stats.lowestRun)} clicks
  Average: ${formatter(stats.average)} clicks
  Median: ${formatter(stats.medianClicks)} clicks
  Range: ${formatter(stats.rangeClicks)} clicks (${(stats.lowestRun)} - ${(stats.bestRun)})
  Perfect Result: ${(stats.perfectResult)} clicks
  Number of times Perfect Result happened: ${stats.perfectCount}
  Probability of Perfect Result: ${formatter(stats.probabilityOfPerfect * 100)}%

Sample Statistics:
  Sample Size: ${sampleSize} clicks
  Test Length: ${testParams.duration} seconds
  Clicks Per Second: ${testParams.clicksPerSecond}
  Start after: ${testParams.startAfter} seconds
  Stationary for: ${testParams.stationaryFor} seconds
  Sum of All Clicks: ${formatter(sumClicks)} clicks
  10th Percentile: ${formatter(stats.percentile10th)} clicks
  90th Percentile: ${formatter(stats.percentile90th)} clicks
  Mode: ${stats.mode} clicks

Variability:
  Error Margin: ${formatter(stats.errorMargin)}%
  Standard Deviation: ±${formatter(stdDev)}
  Variance: ${formatter(stats.variance)}
  Coefficient of Variation: ${formatter(stats.errorMargin)}%
  Interquartile Range (IQR): ${formatter(stats.iqr)} clicks
  Standard Error of the Mean (SEM): ${formatter(stats.sem, 4)}

Distribution Shape:
  Skewness: ${formatter(stats.skewness, 4)}
  Kurtosis: ${formatter(stats.kurtosis, 4)}

Confidence Intervals:
  95%: ${formatter(stats.confidence95[0])} - ${formatter(stats.confidence95[1])}
  99%: ${formatter(stats.confidence99[0])} - ${formatter(stats.confidence99[1])}

Outliers:
  Threshold: ${stats.outlierThreshold} standard deviations
  Outlier Clicks: ${stats.outliers.length}
  Outlier Values: ${stats.outliers.map(formatter).join(', ')}

--------------------------------------------------------------
`.trim();
}