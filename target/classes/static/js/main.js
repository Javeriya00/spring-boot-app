document.addEventListener('DOMContentLoaded', function () {
    var learnMoreBtn = document.getElementById('learnMoreBtn');
    var moreContent = document.getElementById('moreContent');
    
    // Check if elements exist before adding event listeners
    if (learnMoreBtn && moreContent) {
        learnMoreBtn.addEventListener('click', function() {
            console.log('Learn More button clicked');  // Debugging log
            // Toggle visibility of the additional content
            if (moreContent.style.display === 'none' || moreContent.style.display === '') {
                moreContent.style.display = 'block';
                this.textContent = 'Learn Less'; // Change button text to "Learn Less"
            } else {
                moreContent.style.display = 'none';
                this.textContent = 'Learn More'; // Change button text back to "Learn More"
            }
        });
    }
});
