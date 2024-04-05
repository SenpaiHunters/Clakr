let count = 0;
const counterDisplay = document.getElementById('click-counter');
const clickButton = document.getElementById('click-me');

// Use a more efficient method for high-frequency updates
let lastFrameTime = 0;
function updateDisplay(timestamp) {
    if (timestamp - lastFrameTime >= 16) { // Update at most every 16ms (~60fps)
        counterDisplay.textContent = `Clicks: ${count}`;
        lastFrameTime = timestamp;
    }
    requestAnimationFrame(updateDisplay);
}

clickButton.addEventListener('click', () => {
    count++; // Increment the counter
    // No need to update the display here, it's handled by requestAnimationFrame
});

requestAnimationFrame(updateDisplay);