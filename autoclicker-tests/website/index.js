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