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

// Don't touch these ones now
const sampleSize = clicks.length;
const perfectResult = testParams.duration * testParams.clicksPerSecond;
let sumClicks = 0, sumOfSquares = 0, perfectCount = 0, bestRun = clicks[0], lowestRun = clicks[0];
let outliers = [];

clicks.forEach(click => {
  sumClicks += click;
  sumOfSquares += click * click;
  bestRun = Math.max(bestRun, click);
  lowestRun = Math.min(lowestRun, click);
  if (click === perfectResult) perfectCount++;
});

const average = sumClicks / sampleSize;
const variance = sumOfSquares / sampleSize - average * average;
const stdDev = Math.sqrt(variance);
const outlierThreshold = 3 * stdDev;

clicks.forEach(click => {
  if (Math.abs(click - average) > outlierThreshold) outliers.push(click);
});

const zScores = [jStat.normal.inv(0.975, 0, 1), jStat.normal.inv(0.995, 0, 1)];
const marginOfErrors = zScores.map(z => z * stdDev / Math.sqrt(sampleSize));
const quartiles = jStat.quartiles(clicks);
const stats = {
  sumClicks, perfectCount, bestRun, lowestRun, average, medianClicks: quartiles[1],
  rangeClicks: bestRun - lowestRun, quartiles, iqr: quartiles[2] - quartiles[0],
  perfectResult, sem: stdDev / Math.sqrt(sampleSize),
  percentile10th: jStat.percentile(clicks, 0.1), percentile90th: jStat.percentile(clicks, 0.9),
  variance, mode: jStat.mode(clicks), skewness: jStat.skewness(clicks),
  kurtosis: jStat.kurtosis(clicks), outlierThreshold: 3, outliers,
  probabilityOfPerfect: perfectCount / sampleSize, errorMargin: (stdDev / average) * 100,
  confidence95: [average - marginOfErrors[0], average + marginOfErrors[0]],
  confidence99: [average - marginOfErrors[1], average + marginOfErrors[1]]
};

function generateReport(stats, testParams) {
  const formatter = (num, digits = 2) => num.toFixed(digits);
  const formattedClicks = clicks.map((click, index) => `- Run ${index + 1}: ${click}`).join('\n');

  return `
┌─────────────────── Clakr Test Summary ───────────────────┐

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
  Sum of All Clicks: ${formatter(stats.sumClicks)} clicks
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

Runs (Formatted):
${formattedClicks}

└──────────────────────────────────────────────────────────┘
`.trim();
}

console.log(generateReport(stats, testParams));